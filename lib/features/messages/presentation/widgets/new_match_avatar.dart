import 'package:dately/features/discovery/domain/profile.dart';
import 'package:flutter/material.dart';

class NewMatchAvatar extends StatelessWidget {
  final Profile profile;
  final VoidCallback onTap;

  const NewMatchAvatar({super.key, required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // Gold ring container
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: const BoxDecoration(
              color: Color(0xFFFFB800),
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
                image: profile.imageUrls.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(profile.imageUrls[0]),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: profile.imageUrls.isEmpty
                  ? const Icon(Icons.person, size: 36)
                  : null,
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
