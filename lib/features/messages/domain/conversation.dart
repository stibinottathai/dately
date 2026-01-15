import 'package:dately/features/discovery/domain/profile.dart';
import 'package:dately/features/messages/domain/message.dart';
import 'package:equatable/equatable.dart';

class Conversation extends Equatable {
  final String id;
  final Profile otherUser;
  final Message? lastMessage;
  final int unreadCount;
  final bool isNewMatch;
  final bool isOnline;
  final DateTime? lastActiveTime;

  const Conversation({
    required this.id,
    required this.otherUser,
    this.lastMessage,
    this.unreadCount = 0,
    this.isNewMatch = false,
    this.isOnline = false,
    this.lastActiveTime,
  });

  bool get hasUnread => unreadCount > 0;

  String get lastActiveText {
    if (isOnline) return 'Active now';
    if (lastActiveTime == null) return 'Offline';

    final now = DateTime.now();
    final difference = now.difference(lastActiveTime!);

    if (difference.inMinutes < 60) {
      return 'Active ${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return 'Active ${difference.inHours}h ago';
    } else {
      return 'Active ${difference.inDays}d ago';
    }
  }

  @override
  List<Object?> get props => [
    id,
    otherUser,
    lastMessage,
    unreadCount,
    isNewMatch,
    isOnline,
    lastActiveTime,
  ];
}
