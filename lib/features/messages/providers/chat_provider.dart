import 'package:dately/features/messages/domain/message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatState {
  final List<Message> messages;
  final bool isLoading;

  ChatState({this.messages = const [], this.isLoading = false});
}

class ChatNotifier extends StateNotifier<ChatState> {
  final String matchId;
  RealtimeChannel? _subscription;

  ChatNotifier(this.matchId) : super(ChatState()) {
    fetchMessages();
    subscribeToMessages();
  }

  Future<void> fetchMessages() async {
    state = ChatState(isLoading: true, messages: state.messages);
    try {
      final response = await Supabase.instance.client
          .from('messages')
          .select()
          .eq('match_id', matchId)
          .order('created_at', ascending: false);

      final messages = (response as List)
          .map((data) => _mapMessage(data))
          .toList();
      state = ChatState(messages: messages, isLoading: false);
    } catch (e) {
      print('Error fetching messages: $e');
      state = ChatState(isLoading: false);
    }
  }

  void subscribeToMessages() {
    _subscription = Supabase.instance.client
        .channel('public:messages:match_id=eq.$matchId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'match_id',
            value: matchId,
          ),
          callback: (payload) {
            final newMessage = _mapMessage(payload.newRecord);
            state = ChatState(
              messages: [newMessage, ...state.messages],
              isLoading: state.isLoading,
            );
          },
        )
        .subscribe();
  }

  Future<void> sendMessage(String content) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await Supabase.instance.client.from('messages').insert({
        'match_id': matchId,
        'sender_id': userId,
        'content': content,
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Message _mapMessage(Map<String, dynamic> data) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final senderId = data['sender_id'];
    return Message(
      id: data['id'],
      conversationId: data['match_id'],
      senderId: senderId,
      receiverId:
          '', // Ideally we know this from match context, but optional for display
      content: data['content'],
      timestamp: DateTime.parse(data['created_at']),
      status: data['read_at'] != null ? MessageStatus.read : MessageStatus.sent,
      isSentByMe: senderId == userId,
    );
  }

  @override
  void dispose() {
    _subscription?.unsubscribe();
    super.dispose();
  }
}

final chatProvider = StateNotifierProvider.autoDispose
    .family<ChatNotifier, ChatState, String>((ref, matchId) {
      return ChatNotifier(matchId);
    });
