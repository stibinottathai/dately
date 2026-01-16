import 'package:dately/features/discovery/domain/profile.dart';
import 'package:dately/features/messages/domain/conversation.dart';
import 'package:dately/features/messages/domain/message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MatchesState {
  final List<Conversation> matches;
  final bool isLoading;

  MatchesState({this.matches = const [], this.isLoading = false});
}

class MatchesNotifier extends StateNotifier<MatchesState> {
  MatchesNotifier() : super(MatchesState()) {
    fetchMatches();
    _subscribeToMessages();
  }

  Future<void> fetchMatches() async {
    state = MatchesState(isLoading: true, matches: state.matches);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      state = MatchesState(isLoading: false);
      return;
    }

    try {
      // Fetch matches where I am user1 or user2
      // We need to join profiles for both user1 and user2 to decide which one is "other"

      final response = await Supabase.instance.client
          .from('matches')
          .select(
            '*, user1:profiles!user1_id(*), user2:profiles!user2_id(*), messages(id, content, sender_id, created_at, match_id, message_type)',
          )
          .or('user1_id.eq.$userId,user2_id.eq.$userId')
          .order('created_at', ascending: false);

      final prefs = await SharedPreferences.getInstance();

      final matches = (response as List).map((data) {
        final user1Id = data['user1_id'];

        final isUser1Me = user1Id == userId;
        final otherUserData = isUser1Me ? data['user2'] : data['user1'];

        if (otherUserData == null) {
          return Conversation(
            id: data['id'],
            otherUser: Profile(
              id: 'unknown',
              name: 'Unknown User',
              age: 0,
              bio: '',
              location: '',
              distanceMiles: 0,
              imageUrls: [],
              interests: [],
            ),
            unreadCount: 0,
            isNewMatch: false,
            isOnline: false,
          );
        }

        final otherProfile = Profile.fromMap(otherUserData);
        final matchId = data['id'];

        // Message Logic
        final messagesData = data['messages'] as List?;
        Message? lastMessage;

        if (messagesData != null && messagesData.isNotEmpty) {
          // Sort to find latest
          messagesData.sort(
            (a, b) => DateTime.parse(
              b['created_at'],
            ).compareTo(DateTime.parse(a['created_at'])),
          );
          final lastMsgData = messagesData.first;
          final senderId = lastMsgData['sender_id'];

          lastMessage = Message(
            id: lastMsgData['id'],
            conversationId: lastMsgData['match_id'],
            senderId: senderId,
            receiverId: senderId == userId
                ? otherProfile.id
                : userId, // Derived
            content: lastMsgData['content'],
            timestamp: DateTime.parse(lastMsgData['created_at']),
            status: MessageStatus.sent,
            isSentByMe: senderId == userId,
            type: (lastMsgData['message_type'] as String?) == 'image'
                ? MessageType.image
                : MessageType.text,
          );
        }

        final lastReadStr = prefs.getString('last_read_$matchId');
        final lastReadTime = lastReadStr != null
            ? DateTime.parse(lastReadStr)
            : DateTime.fromMillisecondsSinceEpoch(0);

        bool isUnread = false;
        if (lastReadStr == null) {
          // New match, never opened
          isUnread = true;
        } else if (lastMessage != null && !lastMessage.isSentByMe) {
          // Check if last message is newer than last read
          // Adding 1 second buffer to avoid equality issues with precision
          if (lastMessage.timestamp.isAfter(lastReadTime)) {
            isUnread = true;
          }
        }

        return Conversation(
          id: matchId,
          otherUser: otherProfile,
          lastMessage: lastMessage,
          unreadCount: isUnread ? 1 : 0,
          isNewMatch: isUnread,
          isOnline: false,
        );
      }).toList();

      state = MatchesState(matches: matches, isLoading: false);
    } catch (e) {
      print('Error fetching matches: $e');
      state = MatchesState(isLoading: false);
    }
  }

  Future<void> markAsRead(String matchId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'last_read_$matchId',
      DateTime.now().toIso8601String(),
    );

    // Update local state
    final updatedMatches = state.matches.map((m) {
      if (m.id == matchId) {
        return Conversation(
          id: m.id,
          otherUser: m.otherUser,
          lastMessage: m.lastMessage,
          unreadCount: 0,
          isNewMatch: false,
          isOnline: m.isOnline,
          lastActiveTime: m.lastActiveTime,
        );
      }
      return m;
    }).toList();

    state = MatchesState(matches: updatedMatches, isLoading: state.isLoading);
  }

  RealtimeChannel? _subscription;

  void _subscribeToMessages() {
    _subscription = Supabase.instance.client
        .channel('public:messages')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) async {
            final newRecord = payload.newRecord;
            final matchId = newRecord['match_id'];
            final userId = Supabase.instance.client.auth.currentUser?.id;

            if (userId == null) return;

            // Check if we have this match
            final index = state.matches.indexWhere((c) => c.id == matchId);
            if (index == -1) {
              // Might be a new match, refresh all
              fetchMatches();
              return;
            }

            final currentMatch = state.matches[index];
            final senderId = newRecord['sender_id'];
            final content = newRecord['content'];
            final createdAt = DateTime.parse(newRecord['created_at']);

            // Create Message
            final newMessage = Message(
              id: newRecord['id'],
              conversationId: matchId,
              senderId: senderId,
              receiverId: senderId == userId
                  ? currentMatch.otherUser.id
                  : userId,
              content: content,
              timestamp: createdAt,
              status: MessageStatus.delivered,
              isSentByMe: senderId == userId,
              type: (newRecord['message_type'] as String?) == 'image'
                  ? MessageType.image
                  : MessageType.text,
            );

            // Calculate Unread
            // If sent by me, read. If sent by them, unread (unless we just marked it?)
            // We need to check prefs
            final prefs = await SharedPreferences.getInstance();
            final lastReadStr = prefs.getString('last_read_$matchId');
            final lastReadTime = lastReadStr != null
                ? DateTime.parse(lastReadStr)
                : DateTime.fromMillisecondsSinceEpoch(0);

            bool isUnread = false;
            // Buffer logic same as fetch
            if (!newMessage.isSentByMe) {
              if (newMessage.timestamp.isAfter(lastReadTime)) {
                isUnread = true;
              }
            }

            // Update State
            final updatedMatches = List<Conversation>.from(state.matches);
            updatedMatches[index] = Conversation(
              id: currentMatch.id,
              otherUser: currentMatch.otherUser,
              lastMessage: newMessage,
              unreadCount: isUnread ? 1 : 0,
              isNewMatch: isUnread,
              isOnline: currentMatch.isOnline,
            );

            // Re-sort matches? Usually latest message moves to top.
            updatedMatches.sort((a, b) {
              final tA = a.lastMessage?.timestamp ?? DateTime(2000);
              final tB = b.lastMessage?.timestamp ?? DateTime(2000);
              return tB.compareTo(tA);
            });

            state = MatchesState(
              matches: updatedMatches,
              isLoading: state.isLoading,
            );
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'matches',
          callback: (payload) {
            final u1 = payload.newRecord['user1_id'];
            final u2 = payload.newRecord['user2_id'];
            final myId = Supabase.instance.client.auth.currentUser?.id;
            if (u1 == myId || u2 == myId) {
              fetchMatches();
            }
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _subscription?.unsubscribe();
    super.dispose();
  }
}

final matchesProvider =
    StateNotifierProvider.autoDispose<MatchesNotifier, MatchesState>((ref) {
      return MatchesNotifier();
    });
