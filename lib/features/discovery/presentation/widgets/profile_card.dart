import 'package:dately/app/theme/app_colors.dart';
import 'package:dately/features/discovery/domain/profile.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileCard extends StatelessWidget {
  final Profile profile;

  const ProfileCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(
          32,
        ), // User requested reduce radius slightly? kept 32 as balanced
        image: DecorationImage(
          image: CachedNetworkImageProvider(
            profile.imageUrls.isNotEmpty
                ? profile.imageUrls.first
                : AppColors.getDefaultAvatarUrl(profile.name),
          ),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                stops: const [0.6, 1.0],
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${profile.name}, ${profile.age}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28, // Reduced slightly from 32
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (profile.isVerified) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.verified, color: Colors.blue, size: 24),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                if (profile.motherTongue?.isNotEmpty ?? false)
                  Row(
                    children: [
                      const Icon(
                        Icons.language,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        profile.motherTongue!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (profile.occupation != null &&
                        profile.occupation!.isNotEmpty)
                      _buildChip(Icons.work, profile.occupation!),
                    if (profile.education != null &&
                        profile.education!.isNotEmpty)
                      _buildChip(Icons.school, profile.education!),
                    if (profile.height != null && profile.height!.isNotEmpty)
                      _buildChip(Icons.height, profile.height!),
                    if (profile.petPreference != null &&
                        profile.petPreference!.isNotEmpty)
                      _buildChip(Icons.pets, profile.petPreference!),
                    if (profile.drinkingHabit != null &&
                        profile.drinkingHabit!.isNotEmpty)
                      _buildChip(Icons.wine_bar, profile.drinkingHabit!),
                    if (profile.motherTongue?.isNotEmpty ?? false)
                      _buildChip(Icons.language, profile.motherTongue!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
