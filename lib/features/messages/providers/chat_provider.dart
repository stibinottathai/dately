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
            final newMessage = _mapMessage(payload.newRecord!);
            state = ChatState(
              messages: [newMessage, ...state.messages],
              isLoading: state.isLoading,
            );

            // If message is not sent by me, mark as delivered
            if (!newMessage.isSentByMe) {
              markAsDelivered(newMessage.id, newMessage);
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'match_id',
            value: matchId,
          ),
          callback: (payload) {
            final updatedMessage = _mapMessage(payload.newRecord!);
            state = ChatState(
              messages: state.messages
                  .map((m) => m.id == updatedMessage.id ? updatedMessage : m)
                  .toList(),
              isLoading: state.isLoading,
            );
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'messages',
          // No filter for DELETE because match_id might not be in the payload
          callback: (payload) {
            final deletedId = payload.oldRecord?['id'] as String?;
            if (deletedId != null) {
              // Only remove if it exists in our list (avoids irrelevant deletes)
              if (state.messages.any((m) => m.id == deletedId)) {
                state = ChatState(
                  messages: state.messages
                      .where((m) => m.id != deletedId)
                      .toList(),
                  isLoading: state.isLoading,
                );
              }
            }
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
    // Optimistic update
    final previousMessages = state.messages;
    state = ChatState(
      messages: state.messages.where((m) => m.id != messageId).toList(),
      isLoading: state.isLoading,
    );

    try {
      await Supabase.instance.client
          .from('messages')
          .delete()
          .eq('id', messageId);
    } catch (e) {
      print('Error deleting message: $e');
      // Revert on error
      state = ChatState(messages: previousMessages, isLoading: state.isLoading);
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

  Future<void> sendAudioMessage(String audioPath, Duration duration) async {
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
      rethrow;
    }
  }

  Future<void> sendImageMessage(String imagePath) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Optimistic update
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final tempMessage = Message(
        id: tempId,
        conversationId: matchId,
        senderId: userId,
        receiverId: '',
        content: imagePath,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
        isSentByMe: true,
        type: MessageType.image,
      );

      state = ChatState(
        messages: [tempMessage, ...state.messages],
        isLoading: state.isLoading,
      );

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

      // Remove temp message after successful insert
      // The real message will come via subscription
      state = ChatState(
        messages: state.messages.where((m) => m.id != tempId).toList(),
        isLoading: state.isLoading,
      );
    } catch (e) {
      print('Error sending image: $e');
      // Remove temp message on error
      state = ChatState(
        messages: state.messages
            .where((m) => !m.id.startsWith('temp_'))
            .toList(),
        isLoading: state.isLoading,
      );
    }
  }

  Future<void> markAsRead(String messageId) async {
    try {
      await Supabase.instance.client
          .from('messages')
          .update({'read_at': DateTime.now().toIso8601String()})
          .eq('id', messageId);
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  Future<void> markAsDelivered(String messageId, Message message) async {
    if (message.status == MessageStatus.read ||
        message.status == MessageStatus.delivered)
      return;

    try {
      final currentMetadata = message.metadata ?? {};
      await Supabase.instance.client
          .from('messages')
          .update({
            'metadata': {
              ...currentMetadata,
              'delivered_at': DateTime.now().toIso8601String(),
            },
          })
          .eq('id', messageId);
    } catch (e) {
      print('Error marking as delivered: $e');
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

    final metadata = data['metadata'] as Map<String, dynamic>?;
    MessageStatus status = MessageStatus.sent;

    if (data['read_at'] != null) {
      status = MessageStatus.read;
    } else if (metadata != null && metadata['delivered_at'] != null) {
      status = MessageStatus.delivered;
    }

    return Message(
      id: data['id'],
      conversationId: data['match_id'],
      senderId: senderId,
      receiverId:
          '', // Ideally we know this from match context, but optional for display
      content: data['content'],
      timestamp: DateTime.parse(data['created_at']),
      status: status,
      isSentByMe: senderId == userId,
      type: type,
      metadata: metadata,
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
