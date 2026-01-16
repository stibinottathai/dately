import 'package:equatable/equatable.dart';

enum MessageStatus { sent, delivered, read }

enum MessageType { text, image }

class Message extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final MessageStatus status;
  final bool isSentByMe;
  final MessageType type;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.status,
    this.isSentByMe = false,
    this.type = MessageType.text,
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
    type,
  ];
}
