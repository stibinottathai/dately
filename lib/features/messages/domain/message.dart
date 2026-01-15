import 'package:equatable/equatable.dart';

enum MessageStatus { sent, delivered, read }

class Message extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final MessageStatus status;
  final bool isSentByMe;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.status,
    this.isSentByMe = false,
  });

  @override
  List<Object?> get props => [
    id,
    conversationId,
    senderId,
    receiverId,
    content,
    timestamp,
    status,
    isSentByMe,
  ];
}
