import 'package:dately/app/theme/app_colors.dart';
import 'package:dately/features/discovery/data/dummy_profiles.dart';
import 'package:dately/features/discovery/domain/profile.dart';
import 'package:dately/features/discovery/presentation/advanced_filters_screen.dart';
import 'package:dately/features/discovery/presentation/widgets/profile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen>
    with TickerProviderStateMixin {
  final List<Profile> _profiles = List.from(dummyProfiles);

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

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _swipeController.dispose();
    _loveButtonController.dispose();
    _resetController.dispose();
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
      _animateCardOut(_dragPosition.dx > 0);
    } else {
      _resetPosition();
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
    // Then swipe right
    _swipeProgrammatically(true);
  }

  void _onFilterPressed() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AdvancedFiltersScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Header
          _buildHeader(),

          // Main Card Stack
          Expanded(
            child: _profiles.isEmpty
                ? _buildEmptyState()
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        alignment: Alignment.center,
                        children: _profiles.reversed.map((profile) {
                          final isTop = profile == _profiles.first;
                          return isTop
                              ? _buildTopCard(profile, constraints)
                              : _buildBackgroundCard(profile, constraints);
                        }).toList(),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 24),

          // Action Buttons (Floating)
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
          _buildBottomNav(),
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

  Widget _buildBackgroundCard(Profile profile, BoxConstraints constraints) {
    // Simple logic to just show one card behind reduced
    final index = _profiles.indexOf(profile);
    if (index > 1) return const SizedBox.shrink(); // Only show next card

    return Positioned.fill(
      child: Align(
        alignment: Alignment.topCenter,
        child: Transform.translate(
          offset: const Offset(0, 20),
          child: Transform.scale(
            scale: 0.95,
            child: SizedBox(
              width: constraints.maxWidth * 0.9,
              height: constraints.maxHeight * 0.95,
              child: Opacity(
                opacity: 0.6,
                child: ProfileCard(profile: profile),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No more profiles nearby!',
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 24,
        right: 24,
        bottom: 16,
      ),
      child: Row(
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

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.explore, true),
            _buildNavItem(Icons.grid_view, false),
            _buildNavItem(Icons.chat_bubble, false),
            _buildNavItem(Icons.person, false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive) {
    return Icon(
      icon,
      color: isActive ? AppColors.primary : Colors.grey.shade400,
      size: 32,
    );
  }
}
