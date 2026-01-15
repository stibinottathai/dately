import 'package:dately/app/theme/app_colors.dart';
import 'package:dately/features/discovery/presentation/discovery_screen.dart';
import 'package:dately/features/likes/presentation/likes_screen.dart';
import 'package:dately/features/messages/presentation/messages_screen.dart';
import 'package:dately/features/profile/presentation/profile_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          DiscoveryScreen(showBottomNav: false),
          LikesScreen(showBottomNav: false),
          MessagesScreen(showBottomNav: false),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.explore, 0, 'Discover'),
            _buildNavItem(Icons.favorite, 1, 'Likes'),
            _buildNavItem(Icons.chat_bubble, 2, 'Messages'),
            _buildNavItem(Icons.person, 3, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
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
                width: 6,
                height: 6,
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
