import 'package:dately/app/theme/app_colors.dart';
import 'package:dately/features/likes/domain/like.dart';
import 'package:flutter/material.dart';

class LikeCardWidget extends StatelessWidget {
  final Like like;
  final VoidCallback onAction;
  final VoidCallback? onIgnore;

  const LikeCardWidget({
    super.key,
    required this.like,
    required this.onAction,
    this.onIgnore,
  });

  @override
  Widget build(BuildContext context) {
    final isSent = like.direction == LikeDirection.sent;
    final isSuperLike = like.type == LikeType.superLike;
    final profile = like.profile;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSent
            ? Theme.of(context).colorScheme.surface.withOpacity(0.6)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Photo
          _buildProfilePhoto(
            profile.imageUrls.isNotEmpty
                ? profile.imageUrls[0]
                : AppColors.getDefaultAvatarUrl(profile.name),
          ),
          const SizedBox(width: 16),

          // Profile Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${profile.name}, ${profile.age}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (isSuperLike && isSent)
                  Text(
                    'SUPER LIKED',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color(0xFFD4AF37),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  )
                else
                  Text(
                    profile.interests.take(3).join(', '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Action Button
          _buildActionButton(context, isSent),
        ],
      ),
    );
  }

  Widget _buildProfilePhoto(String imageUrl) {
    return Stack(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 2,
            ),
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
              colorFilter: like.direction == LikeDirection.sent
                  ? ColorFilter.mode(
                      Colors.grey.withOpacity(0.3),
                      BlendMode.saturation,
                    )
                  : null,
            ),
          ),
        ),
        // Super Like Badge
        if (like.type == LikeType.superLike &&
            like.direction == LikeDirection.sent)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFFD4AF37),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: const Icon(Icons.star, size: 16, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, bool isSent) {
    if (isSent && like.isMatched) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: Colors.grey.shade100,
          disabledForegroundColor: Colors.grey.shade400,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          minimumSize: const Size(84, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: const Text(
          'Matched',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      );
    }

    if (!isSent && onIgnore != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onIgnore,
            icon: Icon(Icons.close, color: Colors.grey.shade400),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: AppColors.primary.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              minimumSize: const Size(84, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'Match',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    }

    return ElevatedButton(
      onPressed: onAction,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSent
            ? Theme.of(context).colorScheme.surface
            : AppColors.primary,
        foregroundColor: isSent
            ? Theme.of(context).textTheme.bodyMedium?.color
            : Colors.white,
        elevation: isSent ? 0 : 4,
        shadowColor: AppColors.primary.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        minimumSize: const Size(84, 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Text(
        isSent ? 'Retract' : 'Match',
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSent ? FontWeight.w500 : FontWeight.bold,
        ),
      ),
    );
  }
}
