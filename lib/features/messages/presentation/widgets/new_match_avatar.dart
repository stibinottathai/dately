import 'package:dately/app/theme/app_colors.dart';
import 'package:dately/features/discovery/domain/profile.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NewMatchAvatar extends StatelessWidget {
  final Profile profile;
  final bool isNew;
  final VoidCallback onTap;

  const NewMatchAvatar({
    super.key,
    required this.profile,
    this.isNew = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // Gold ring container
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: isNew ? const Color(0xFFFFB800) : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 2,
                ),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(
                    profile.imageUrls.isNotEmpty
                        ? profile.imageUrls[0]
                        : AppColors.getDefaultAvatarUrl(profile.name),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            profile.name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
