import 'package:dately/app/theme/app_colors.dart';
import 'package:dately/features/discovery/domain/profile.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MatchDialog extends StatelessWidget {
  final Profile matchedProfile;
  final String matchId;

  const MatchDialog({
    super.key,
    required this.matchedProfile,
    required this.matchId,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "It's a Match!",
              style: TextStyle(
                fontFamily:
                    'Pacifico', // Or any cursive font if available, fallback to system
                fontSize: 36,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "You and ${matchedProfile.name} liked each other.",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Profile Photos (Overlapping avatars maybe? For now simple single avatar)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 4),
                image: matchedProfile.imageUrls.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(matchedProfile.imageUrls.first),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: matchedProfile.imageUrls.isEmpty
                  ? Icon(Icons.person, size: 60, color: Colors.grey.shade400)
                  : null,
            ),
            const SizedBox(height: 32),

            // Send Message Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  context.pop(); // Close dialog
                  // Navigate to chat
                  // We need to pass conversation object or just ID
                  context.push(
                    '/chat/$matchId',
                    extra:
                        matchedProfile, // Pass profile as conversationData fallback
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Send a Message',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Keep Swiping Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  context.pop(); // Close dialog
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                  side: const BorderSide(color: Colors.transparent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Keep Swiping',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
