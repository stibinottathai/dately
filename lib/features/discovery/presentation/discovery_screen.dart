import 'package:dately/app/theme/app_colors.dart';
import 'package:dately/app/widgets/app_bottom_nav.dart';

import 'package:dately/features/discovery/domain/profile.dart';
import 'package:dately/features/discovery/presentation/advanced_filters_screen.dart';
import 'package:dately/features/discovery/presentation/profile_detail_screen.dart';
import 'package:dately/features/discovery/presentation/widgets/profile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dately/features/discovery/presentation/widgets/match_dialog.dart';
import 'package:dately/features/discovery/providers/discovery_provider.dart';
import 'package:dately/features/discovery/providers/filter_provider.dart';
import 'package:dately/features/discovery/providers/search_history_provider.dart';
import 'package:dately/features/likes/providers/likes_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiscoveryScreen extends ConsumerStatefulWidget {
  final bool showBottomNav;

  const DiscoveryScreen({super.key, this.showBottomNav = true});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen>
    with TickerProviderStateMixin {
  List<Profile> _profiles = [];
  bool _isLoading = true;

  // Animation State
  Offset _dragPosition = Offset.zero;
  double _angle = 0;

  // To handle programmatic swipes
  late AnimationController _swipeController;
  late Animation<Offset> _swipeAnimation;
  bool _isAnimatingOut = false;

  // Love button animation
  late AnimationController _loveButtonController;
  late Animation<double> _loveButtonScale;

  // Reset animation
  late AnimationController _resetController;
  late Animation<Offset> _resetAnimation;
  late Animation<double> _resetAngleAnimation;

  // Search State
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // No manual load needed, ref.listen in build will handle it.
    // However, we want to ensure the provider is hot so we might want to read it once or just let the build method handle subscription.

    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_swipeController);

    _swipeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _removeTopCard();
      }
    });

    // Love button animation controller
    _loveButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loveButtonScale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _loveButtonController, curve: Curves.elasticOut),
    );

    // Reset animation controller
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _resetAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _resetController, curve: Curves.easeOutBack),
        );
    _resetAngleAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.easeOutBack),
    );
  }

  Future<void> _refreshProfiles() async {
    // Invalidate the RAW provider to force network fetch
    ref.invalidate(rawProfilesProvider);
    // discoveryProvider will automatically update
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _loveButtonController.dispose();
    _resetController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _removeTopCard() {
    setState(() {
      _profiles.removeAt(0);
      _resetSwipeState();
    });
  }

  void _resetSwipeState() {
    _dragPosition = Offset.zero;
    _angle = 0;
    _isAnimatingOut = false;
    _swipeController.reset();
  }

  void _onPanStart(DragStartDetails details) {
    if (_isAnimatingOut || _profiles.isEmpty) return;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isAnimatingOut || _profiles.isEmpty) return;
    setState(() {
      _dragPosition += details.delta;
      // Rotation based on x position
      _angle = (_dragPosition.dx / MediaQuery.of(context).size.width) * 0.5;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isAnimatingOut || _profiles.isEmpty) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.3; // Swipe threshold

    if (_dragPosition.dx.abs() > threshold) {
      final isRight = _dragPosition.dx > 0;
      _animateCardOut(isRight);

      if (isRight) {
        final profile = _profiles.first;
        _handleLike(profile);
      }
    } else {
      _resetPosition();
    }
  }

  Future<void> _handleLike(Profile profile) async {
    final matchId = await ref.read(likesProvider.notifier).likeUser(profile.id);
    if (matchId != null && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            MatchDialog(matchedProfile: profile, matchId: matchId),
      );
    }
  }

  void _resetPosition() {
    // Animate back to center with spring effect
    _resetAnimation = Tween<Offset>(begin: _dragPosition, end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _resetController, curve: Curves.easeOutBack),
        );

    _resetAngleAnimation = Tween<double>(begin: _angle, end: 0).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.easeOutBack),
    );

    _resetController.forward(from: 0).then((_) {
      setState(() {
        _dragPosition = Offset.zero;
        _angle = 0;
      });
    });
  }

  void _animateCardOut(bool isRight) {
    _isAnimatingOut = true;
    final screenWidth = MediaQuery.of(context).size.width;
    final endX = isRight ? screenWidth * 1.5 : -screenWidth * 1.5;

    _swipeAnimation = Tween<Offset>(
      begin: _dragPosition,
      end: Offset(endX, _dragPosition.dy),
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.easeOut));

    _swipeController.forward();
  }

  void _swipeProgrammatically(bool isRight) {
    if (_isAnimatingOut || _profiles.isEmpty) return;

    if (isRight) {
      final profile = _profiles.first;
      _handleLike(profile);
    }

    _isAnimatingOut = true;
    final screenWidth = MediaQuery.of(context).size.width;
    final endX = isRight ? screenWidth * 1.5 : -screenWidth * 1.5;

    // Add haptic feedback
    HapticFeedback.lightImpact();

    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(endX, 0),
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.easeOut));

    _swipeController.forward();
  }

  void _onLoveButtonPressed() {
    // Trigger love button animation
    _loveButtonController.forward().then((_) {
      _loveButtonController.reverse();
    });

    // Like the user
    if (_profiles.isNotEmpty) {
      // Just swipe programmatically, it handles the like
      _swipeProgrammatically(true);
    }
  }

  void _onFilterPressed() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AdvancedFiltersScreen(),
    );
  }

  void _openProfileDetails(Profile profile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileDetailScreen(profile: profile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<Profile>>>(discoveryProvider, (previous, next) {
      if (next.isLoading) {
        setState(() => _isLoading = true);
      } else if (next.hasValue) {
        setState(() {
          _profiles = next.value ?? [];
          _isLoading = false;
        });
      } else if (next.hasError) {
        setState(() => _isLoading = false);
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Header
          _buildHeader(),

          // Main Card Stack
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _profiles.isEmpty
                ? _buildEmptyState()
                : _isSearchVisible
                ? _searchController.text.isEmpty
                      ? _buildSearchHistory()
                      : _buildSearchResults()
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Render cards from back to front (reversed order for z-index)
                          for (int i = _profiles.length - 1; i >= 0; i--)
                            if (i == 0)
                              _buildTopCard(_profiles[i], constraints)
                            else if (i <= 2)
                              _buildBackgroundCard(
                                _profiles[i],
                                i,
                                constraints,
                              ),
                        ],
                      );
                    },
                  ),
          ),

          const SizedBox(height: 24),

          // Action Buttons (Floating)
          if (!_isLoading && _profiles.isNotEmpty && !_isSearchVisible)
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton(
                    icon: Icons.close,
                    color: Colors.grey.shade400,
                    size: 64,
                    onTap: () => _swipeProgrammatically(false),
                  ),
                  const SizedBox(width: 24),
                  _buildActionButton(
                    icon: Icons.star,
                    color: const Color(0xFF9B51E0),
                    size: 56,
                    onTap: () {}, // Super like logic
                  ),
                  const SizedBox(width: 24),
                  _buildActionButton(
                    icon: Icons.favorite,
                    color: Colors.white,
                    size: 80,
                    isPrimary: true,
                    onTap: _onLoveButtonPressed,
                    animationController: _loveButtonController,
                    scaleAnimation: _loveButtonScale,
                  ),
                ],
              ),
            ),

          // Bottom Navigation
          // Bottom Navigation
          if (widget.showBottomNav)
            const AppBottomNav(currentTab: AppTab.explore),
        ],
      ),
    );
  }

  Widget _buildTopCard(Profile profile, BoxConstraints constraints) {
    return AnimatedBuilder(
      animation: Listenable.merge([_swipeController, _resetController]),
      builder: (context, child) {
        final offset = _isAnimatingOut
            ? _swipeAnimation.value
            : (_resetController.isAnimating
                  ? _resetAnimation.value
                  : _dragPosition);
        final angle = _isAnimatingOut
            ? (offset.dx / constraints.maxWidth) * 0.5
            : (_resetController.isAnimating
                  ? _resetAngleAnimation.value
                  : _angle);

        // Calculate overlay opacity based on drag distance
        final swipeProgress = (offset.dx / constraints.maxWidth).clamp(
          -1.0,
          1.0,
        );
        final likeOpacity = swipeProgress > 0 ? swipeProgress : 0.0;
        final nopeOpacity = swipeProgress < 0 ? -swipeProgress : 0.0;

        return Positioned.fill(
          child: Align(
            alignment: Alignment.topCenter,
            child: Transform.translate(
              offset: Offset(offset.dx, offset.dy * 0.2),
              child: Transform.rotate(
                angle: angle,
                child: GestureDetector(
                  onTap: () => _openProfileDetails(profile),
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: SizedBox(
                    width: constraints.maxWidth * 0.9,
                    height: constraints.maxHeight * 0.95,
                    child: Stack(
                      children: [
                        ProfileCard(profile: profile),
                        // LIKE overlay
                        if (likeOpacity > 0)
                          Positioned.fill(
                            child: Opacity(
                              opacity: likeOpacity,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(
                                    color: Colors.green,
                                    width: 6,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Transform.rotate(
                                      angle: -0.3,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.green,
                                            width: 4,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Text(
                                          'LIKE',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // NOPE overlay
                        if (nopeOpacity > 0)
                          Positioned.fill(
                            child: Opacity(
                              opacity: nopeOpacity,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(
                                    color: Colors.red,
                                    width: 6,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Transform.rotate(
                                      angle: 0.3,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.red,
                                            width: 4,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Text(
                                          'NOPE',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackgroundCard(
    Profile profile,
    int index,
    BoxConstraints constraints,
  ) {
    // Calculate scale and offset based on position
    final scale = 1.0 - (index * 0.05);
    final offsetY = index * 10.0;

    return Positioned.fill(
      child: Align(
        alignment: Alignment.topCenter,
        child: Transform.translate(
          offset: Offset(0, offsetY),
          child: Transform.scale(
            scale: scale,
            child: SizedBox(
              width: constraints.maxWidth * 0.9,
              height: constraints.maxHeight * 0.95,
              child: IgnorePointer(child: ProfileCard(profile: profile)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.2),
                ),
                child: const Icon(
                  Icons.radar,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "That's everyone for now",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "We've run out of potential matches in your area. Check back later or adjust your filters.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _refreshProfiles,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 24,
        right: 24,
        bottom: 8,
      ),
      child: _isSearchVisible
          ? Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Search people...',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            // Reset filter
                            ref
                                .read(filterProvider.notifier)
                                .setSearchQuery('');
                            // Hide search
                            setState(() => _isSearchVisible = false);
                            // No need to manually refresh - provider updates automatically
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        ref.read(filterProvider.notifier).setSearchQuery(value);
                        setState(
                          () {},
                        ); // Rebuild to show/hide history based on text
                      },
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          ref
                              .read(searchHistoryProvider.notifier)
                              .addSearch(value);
                        }
                      },
                    ),
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Transform.rotate(
                      angle: 0.2,
                      child: const Icon(
                        Icons.water_drop,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(-6, 0),
                      child: const Text(
                        '_RK',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Dately',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() => _isSearchVisible = true);
                        _searchFocusNode.requestFocus();
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        elevation: 1,
                        shadowColor: Colors.black.withOpacity(0.1),
                        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                      ),
                      icon: const Icon(Icons.search),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _onFilterPressed,
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        elevation: 1,
                        shadowColor: Colors.black.withOpacity(0.1),
                        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                      ),
                      icon: const Icon(Icons.tune),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required double size,
    required VoidCallback onTap,
    bool isPrimary = false,
    AnimationController? animationController,
    Animation<double>? scaleAnimation,
  }) {
    Widget button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isPrimary
            ? AppColors.primary
            : Theme.of(context).colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: isPrimary
                ? AppColors.primary.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: isPrimary ? 40 : 32),
    );

    if (scaleAnimation != null) {
      button = AnimatedBuilder(
        animation: scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: scaleAnimation.value, child: child);
        },
        child: button,
      );
    }

    return GestureDetector(onTap: onTap, child: button);
  }

  Widget _buildSearchHistory() {
    final history = ref.watch(searchHistoryProvider);

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No recent searches',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  ref.read(searchHistoryProvider.notifier).clearHistory();
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final query = history[index];
              return ListTile(
                leading: const Icon(Icons.history, color: Colors.grey),
                title: Text(query),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                  onPressed: () {
                    ref
                        .read(searchHistoryProvider.notifier)
                        .removeSearch(query);
                  },
                ),
                onTap: () {
                  _searchController.text = query;
                  ref.read(filterProvider.notifier).setSearchQuery(query);
                  // Add to history again to move to top
                  ref.read(searchHistoryProvider.notifier).addSearch(query);
                  setState(() {});
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _profiles.length,
      itemBuilder: (context, index) {
        final profile = _profiles[index];
        return Card(
          elevation: 0,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(
                profile.imageUrls.isNotEmpty
                    ? profile.imageUrls.first
                    : 'https://placeholder.com/150',
              ),
              backgroundColor: Colors.grey.shade200,
            ),
            title: Text(
              '${profile.name}, ${profile.age}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (profile.occupation != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.work_outline,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        profile.occupation!,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      profile.motherTongue != null
                          ? Icons.translate
                          : Icons.location_on_outlined,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      profile.motherTongue ?? profile.location,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
            onTap: () {
              if (_searchController.text.isNotEmpty) {
                ref
                    .read(searchHistoryProvider.notifier)
                    .addSearch(_searchController.text);
              }
              _openProfileDetails(profile);
            },
          ),
        );
      },
    );
  }
}
