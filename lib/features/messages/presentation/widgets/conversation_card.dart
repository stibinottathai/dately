import 'package:dately/features/messages/domain/conversation.dart';
import 'package:dately/features/messages/domain/message.dart';
import 'package:dately/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dately/app/widgets/cached_image.dart';

class ConversationCard extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const ConversationCard({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 20) {
      return 'Now';
    } else if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRecent =
        conversation.lastMessage != null &&
        DateTime.now().difference(conversation.lastMessage!.timestamp).inHours <
            6;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
          ),
        ),
        child: Row(
          children: [
            // Profile Photo with Online Indicator
            Stack(
              children: [
                CachedImage(
                  width: 64,
                  height: 64,
                  imageUrl: conversation.otherUser.imageUrls.isNotEmpty
                      ? conversation.otherUser.imageUrls[0]
                      : AppColors.getDefaultAvatarUrl(
                          conversation.otherUser.name,
                        ),
                  shape: BoxShape.circle,
                  fit: BoxFit.cover,
                ),
                if (conversation.isOnline)
                  Positioned(
                    bottom: 2,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 16),

            // Message Preview
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.otherUser.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.lastMessage?.type == MessageType.image
                        ? 'Sent an image 📷'
                        : conversation.lastMessage?.type == MessageType.audio
                        ? 'Sent an audio 🎤'
                        : conversation.lastMessage?.content ?? 'New match!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: conversation.hasUnread
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: conversation.hasUnread
                          ? Theme.of(context).textTheme.bodyMedium?.color
                          : Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Timestamp
            if (conversation.lastMessage != null)
              Text(
                _formatTimestamp(conversation.lastMessage!.timestamp),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isRecent ? FontWeight.bold : FontWeight.w500,
                  color: isRecent ? AppColors.primary : Colors.grey.shade500,
                ),
              ),
            if (conversation.hasUnread)
              Container(
                margin: const EdgeInsets.only(left: 8),
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
