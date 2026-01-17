import 'package:dately/features/discovery/presentation/profile_detail_screen.dart';
import 'package:dately/features/discovery/presentation/widgets/match_dialog.dart';
import 'package:dately/features/likes/domain/like.dart';
import 'package:dately/features/likes/presentation/widgets/like_card_widget.dart';
import 'package:dately/features/likes/providers/likes_provider.dart';
import 'package:dately/features/messages/providers/matches_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dately/app/theme/app_colors.dart';
import 'package:dately/app/widgets/app_bottom_nav.dart';

class LikesScreen extends ConsumerStatefulWidget {
  final bool showBottomNav;

  const LikesScreen({super.key, this.showBottomNav = true});

  @override
  ConsumerState<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends ConsumerState<LikesScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final likesState = ref.watch(likesProvider);

    // Filter based on tab
    final currentLikes = _selectedTabIndex == 0
        ? likesState.receivedLikes
        : likesState.sentLikes;

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
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(likesProvider.notifier).refreshLikes();
              },
              child: likesState.isLoading && currentLikes.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : currentLikes.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 8, bottom: 80),
                      itemCount: currentLikes.length,
                      itemBuilder: (context, index) {
                        final like = currentLikes[index];
                        return GestureDetector(
                          onTap: () => _handleCardTap(like),
                          child: LikeCardWidget(
                            like: like,
                            onAction: () => _handleLikeAction(like),
                            onIgnore: () => _handleIgnoreLike(like),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      // Bottom Navigation
      bottomNavigationBar: widget.showBottomNav
          ? const AppBottomNav(currentTab: AppTab.likes)
          : null,
    );
  }

  Future<void> _handleLikeAction(Like like) async {
    if (like.direction == LikeDirection.received) {
      // Accepting a received like -> Automatic Match
      final matchId = await ref
          .read(likesProvider.notifier)
          .likeUser(like.profile.id);
      if (matchId != null && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              MatchDialog(matchedProfile: like.profile, matchId: matchId),
        );
      }
    } else {
      // Retract like
      await ref.read(likesProvider.notifier).unlikeUser(like.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Retracted like for ${like.profile.name}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _handleIgnoreLike(Like like) async {
    await ref.read(likesProvider.notifier).ignoreLike(like.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Like ignored'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleCardTap(Like like) {
    if (like.isMatched) {
      if (like.matchId != null) {
        context.push('/chat/${like.matchId}', extra: like.profile);
      } else {
        // Fallback checks matchesProvider (legacy/safety)
        final matchesState = ref.read(matchesProvider);
        try {
          final match = matchesState.matches.firstWhere(
            (m) => m.otherUser.id == like.profile.id,
          );
          context.push('/chat/${match.id}', extra: match);
        } catch (e) {
          // Fallback to profile
          _openProfileDetails(like);
        }
      }
    } else {
      _openProfileDetails(like);
    }
  }

  void _openProfileDetails(Like like) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ProfileDetailScreen(profile: like.profile, matchId: like.matchId),
      ),
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Profile Icon

          // Title
          Text(
            'Likes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          // Filter Button
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
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
            ),
          ),
        );
      },
    );
  }
}
