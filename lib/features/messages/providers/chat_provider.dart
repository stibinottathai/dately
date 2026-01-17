import 'dart:io';
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

  Future<void> deleteMessage(String messageId) async {
    try {
      await Supabase.instance.client
          .from('messages')
          .delete()
          .eq('id', messageId);

      state = ChatState(
        messages: state.messages.where((m) => m.id != messageId).toList(),
        isLoading: state.isLoading,
      );
    } catch (e) {
      print('Error deleting message: $e');
    }
  }

  Future<void> clearChat() async {
    try {
      await Supabase.instance.client
          .from('messages')
          .delete()
          .eq('match_id', matchId);

      state = ChatState(messages: [], isLoading: state.isLoading);
    } catch (e) {
      print('Error clearing chat: $e');
    }
  }

  Future<void> sendAudioMessage(String audioPath) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$userId.m4a';
      final file = File(audioPath);

      // Upload to Supabase Storage
      await Supabase.instance.client.storage
          .from('chat_audio')
          .upload(fileName, file);

      final audioUrl = Supabase.instance.client.storage
          .from('chat_audio')
          .getPublicUrl(fileName);

      await Supabase.instance.client.from('messages').insert({
        'match_id': matchId,
        'sender_id': userId,
        'content': audioUrl,
        'message_type': 'audio',
      });
    } catch (e) {
      print('Error sending audio message: $e');
    }
  }

  Future<void> sendImageMessage(String imagePath) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$userId.jpg';
      final file = File(imagePath);

      // Upload to Supabase Storage
      await Supabase.instance.client.storage
          .from('chat_images')
          .upload(fileName, file);

      final imageUrl = Supabase.instance.client.storage
          .from('chat_images')
          .getPublicUrl(fileName);

      await Supabase.instance.client.from('messages').insert({
        'match_id': matchId,
        'sender_id': userId,
        'content': imageUrl,
        'message_type': 'image',
      });
    } catch (e) {
      print('Error sending image: $e');
    }
  }

  Message _mapMessage(Map<String, dynamic> data) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final senderId = data['sender_id'];
    final typeStr = data['message_type'] as String? ?? 'text';
    final type = typeStr == 'image'
        ? MessageType.image
        : typeStr == 'audio'
        ? MessageType.audio
        : MessageType.text;

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
      type: type,
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
