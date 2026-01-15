import 'package:dately/app/theme/app_colors.dart';
import 'package:dately/features/likes/data/dummy_likes.dart';
import 'package:dately/features/likes/domain/like.dart';
import 'package:dately/features/likes/presentation/widgets/like_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LikesScreen extends StatefulWidget {
  final bool showBottomNav;

  const LikesScreen({super.key, this.showBottomNav = true});

  @override
  State<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> {
  int _selectedTabIndex = 0;
  late List<Like> _receivedLikes;
  late List<Like> _sentLikes;

  @override
  void initState() {
    super.initState();
    _receivedLikes = dummyLikes
        .where((like) => like.direction == LikeDirection.received)
        .toList();
    _sentLikes = dummyLikes
        .where((like) => like.direction == LikeDirection.sent)
        .toList();
  }

  List<Like> get _currentLikes =>
      _selectedTabIndex == 0 ? _receivedLikes : _sentLikes;

  void _handleLikeAction(Like like) {
    setState(() {
      if (like.direction == LikeDirection.received) {
        _receivedLikes.remove(like);
        // TODO: Implement match logic
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Matched with ${like.profile.name}! 💕'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        _sentLikes.remove(like);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Retracted like for ${like.profile.name}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // Top App Bar
          _buildTopAppBar(),

          // Segmented Buttons (Tabs)
          _buildTabs(),

          // Content Area
          Expanded(
            child: _currentLikes.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: _currentLikes.length,
                    itemBuilder: (context, index) {
                      return LikeCardWidget(
                        like: _currentLikes[index],
                        onAction: () => _handleLikeAction(_currentLikes[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
      // Bottom Navigation
      bottomNavigationBar: widget.showBottomNav ? _buildBottomNav() : null,
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Profile Icon
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.centerLeft,
            child: const Icon(Icons.person, size: 28),
          ),

          // Title
          Text(
            'Likes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          // Filter Button
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.tune),
              onPressed: () {
                // TODO: Implement filter functionality
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _buildTabButton('Likes Me', 0),
            _buildTabButton('Sent Likes', 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.black87 : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _selectedTabIndex == 0 ? Icons.favorite_border : Icons.send,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            _selectedTabIndex == 0 ? 'No likes yet' : 'No sent likes',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedTabIndex == 0
                ? 'Keep swiping to find your match!'
                : 'Start liking profiles to see them here',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.explore, false, '/counter', context),
            _buildNavItem(Icons.favorite, true, null, context),
            _buildNavItem(Icons.chat_bubble, false, '/messages', context),
            _buildNavItem(Icons.person, false, null, context),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    bool isActive,
    String? route,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: route != null ? () => context.go(route) : null,
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
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
