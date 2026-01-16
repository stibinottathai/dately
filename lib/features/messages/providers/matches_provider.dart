import 'package:dately/features/discovery/domain/profile.dart';
import 'package:dately/features/messages/domain/conversation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MatchesState {
  final List<Conversation> matches;
  final bool isLoading;

  MatchesState({this.matches = const [], this.isLoading = false});
}

class MatchesNotifier extends StateNotifier<MatchesState> {
  MatchesNotifier() : super(MatchesState()) {
    fetchMatches();
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
          .select('*, user1:profiles!user1_id(*), user2:profiles!user2_id(*)')
          .or('user1_id.eq.$userId,user2_id.eq.$userId')
          .order('created_at', ascending: false);

      final matches = (response as List).map((data) {
        final user1Id = data['user1_id'];

        final isUser1Me = user1Id == userId;
        final otherUserData = isUser1Me ? data['user2'] : data['user1'];

        if (otherUserData == null) {
          // Handle case where profile is not found (deleted user or bad join)
          // Return a placeholder or skip?
          // For now, return a placeholder to avoid crash, or skipmap by returning null and filtering
          // But map expects non-null. Let's return a dummy profile.
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

        return Conversation(
          id: data['id'],
          otherUser: otherProfile,
          // lastMessage: null, // TODO: Fetch last message
          unreadCount: 0,
          isNewMatch: true, // You might want logic for this based on created_at
          isOnline: false,
        );
      }).toList();

      state = MatchesState(matches: matches, isLoading: false);
    } catch (e) {
      print('Error fetching matches: $e');
      state = MatchesState(isLoading: false);
    }
  }
}

final matchesProvider =
    StateNotifierProvider.autoDispose<MatchesNotifier, MatchesState>((ref) {
      return MatchesNotifier();
    });
