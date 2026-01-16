import 'package:dately/app/theme/app_colors.dart';
import 'package:dately/features/likes/providers/likes_provider.dart';
import 'package:dately/features/messages/providers/matches_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum AppTab { explore, likes, messages, profile }

class AppBottomNav extends ConsumerWidget {
  final AppTab currentTab;

  const AppBottomNav({super.key, required this.currentTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers for badges
    final likesState = ref.watch(likesProvider);
    final matchesState = ref.watch(matchesProvider);

    final newLikesCount = likesState.receivedLikes.length;
    final unreadChats = matchesState.matches.where((m) => m.isNewMatch).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(context, Icons.explore, AppTab.explore, '/counter'),
            _buildNavItem(
              context,
              Icons.favorite,
              AppTab.likes,
              '/likes',
              badgeCount: newLikesCount,
              isAlert: true, // Alert icon
            ),
            _buildNavItem(
              context,
              Icons.chat_bubble,
              AppTab.messages,
              '/messages',
              badgeCount: unreadChats,
            ),
            _buildNavItem(context, Icons.person, AppTab.profile, '/profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    AppTab tab,
    String route, {
    int badgeCount = 0,
    bool isAlert = false,
  }) {
    final isActive = currentTab == tab;

    return GestureDetector(
      onTap: () {
        if (!isActive) {
          context.go(route);
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? AppColors.primary : Colors.grey.shade400,
                size: 32,
              ),
              if (isActive)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),

          // Badge Logic
          if (badgeCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: EdgeInsets.all(isAlert ? 4 : 5),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: isAlert
                    ? const Icon(
                        Icons.priority_high,
                        size: 10,
                        color: Colors.white,
                      )
                    : Text(
                        badgeCount > 9 ? '9+' : '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
