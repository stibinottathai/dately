import 'package:dately/features/messages/domain/message.dart';
import 'package:dately/app/theme/app_colors.dart';
import 'package:dately/features/messages/presentation/widgets/audio_message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final String? senderAvatarUrl;

  const MessageBubble({super.key, required this.message, this.senderAvatarUrl});

  String _formatTime(DateTime timestamp) {
    return DateFormat('h:mm a').format(timestamp.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final isSent = message.isSentByMe;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isSent
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSent && senderAvatarUrl != null) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 12, bottom: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(senderAvatarUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ] else if (!isSent)
            const SizedBox(width: 44),

          Flexible(
            child: Column(
              crossAxisAlignment: isSent
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: message.type == MessageType.image
                      ? const EdgeInsets.all(4)
                      : const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                  decoration: BoxDecoration(
                    gradient: isSent
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.primary, Color(0xFFC41D65)],
                          )
                        : null,
                    color: isSent ? null : const Color(0xFFF4F0F2),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isSent
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                      bottomRight: isSent
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
                    ),
                    boxShadow: isSent
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: message.type == MessageType.image
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            message.content,
                            width: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox(
                                width: 200,
                                height: 200,
                                child: Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return SizedBox(
                                width: 200,
                                height: 200,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : message.type == MessageType.audio
                      ? AudioMessageBubble(
                          audioUrl: message.content,
                          isSentByMe: isSent,
                        )
                      : Text(
                          message.content,
                          style: TextStyle(
                            fontSize: 14,
                            color: isSent ? Colors.white : Colors.black87,
                            height: 1.4,
                          ),
                        ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: EdgeInsets.only(
                    left: isSent ? 0 : 4,
                    right: isSent ? 4 : 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isSent
                            ? (message.status == MessageStatus.read
                                  ? 'Read ${_formatTime(message.timestamp)}'
                                  : message.status == MessageStatus.delivered
                                  ? 'Delivered ${_formatTime(message.timestamp)}'
                                  : 'Sent ${_formatTime(message.timestamp)}')
                            : _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (isSent) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.status == MessageStatus.read
                              ? Icons.done_all
                              : Icons.done,
                          size: 14,
                          color: message.status == MessageStatus.read
                              ? AppColors.primary
                              : Colors.grey.shade500,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (isSent) const SizedBox(width: 12),
        ],
      ),
    );
  }
}
