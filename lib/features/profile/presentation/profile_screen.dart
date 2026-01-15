import 'package:dately/app/theme/app_colors.dart';
import 'package:dately/features/profile/data/current_user.dart';
import 'package:dately/features/profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserProfile profile = currentUserProfile;
  int _currentPhotoIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top App Bar
                _buildTopAppBar(),

                // Main Photo Section
                _buildMainPhoto(),

                // Name and Headline
                _buildNameSection(),

                // Bio Section
                _buildBioSection(),

                // Personality Prompts
                _buildPersonalityPrompts(),

                // Details Grid
                _buildDetailsGrid(),

                // Spotify Section
                if (profile.topArtistImages != null) _buildSpotifySection(),

                // Secondary Photos
                _buildSecondaryPhotos(),

                // Bottom Spacing
                const SizedBox(height: 100),
              ],
            ),
          ),

          // Floating Edit Button
          _buildFloatingEditButton(),
        ],
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.centerLeft,
            child: const Icon(Icons.arrow_back_ios_new),
          ),
          Text(
            'Profile Preview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainPhoto() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 500,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Photo
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: profile.photos.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(profile.photos[_currentPhotoIndex]),
                        fit: BoxFit.cover,
                      )
                    : null,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black54,
                  ],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),

            // Indicators
            Positioned(
              top: 16,
              left: 16,
              child: Row(
                children: [
                  if (profile.isVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 8),
                  if (profile.isOnline)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Online Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Photo Counter
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentPhotoIndex + 1} / ${profile.photos.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Pagination Dots
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  profile.photos.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == _currentPhotoIndex ? 24 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: index == _currentPhotoIndex
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${profile.name}, ${profile.age}',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          if (profile.mbtiType != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                profile.mbtiType!,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBioSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        profile.bio,
        style: const TextStyle(fontSize: 16, height: 1.5),
      ),
    );
  }

  Widget _buildPersonalityPrompts() {
    return Container(
      height: 140,
      margin: const EdgeInsets.only(top: 24, bottom: 24),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: [
          if (profile.spontaneousPrompt != null)
            _buildPromptCard(
              'The most spontaneous thing I\'ve done',
              profile.spontaneousPrompt!,
            ),
          if (profile.idealSundayPrompt != null)
            _buildPromptCard('My ideal Sunday', profile.idealSundayPrompt!),
        ],
      ),
    );
  }

  Widget _buildPromptCard(String title, String content) {
    return Container(
      width: 256,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsGrid() {
    final details = [
      if (profile.occupation != null) ('work', profile.occupation!),
      if (profile.height != null) ('straighten', profile.height!),
      if (profile.education != null) ('school', profile.education!),
      if (profile.religion != null) ('church', profile.religion!),
      if (profile.petPreference != null) ('pets', profile.petPreference!),
      if (profile.drinkingHabit != null) ('wine_bar', profile.drinkingHabit!),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About Me',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3,
            ),
            itemCount: details.length,
            itemBuilder: (context, index) {
              final detail = details[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getIconData(detail.$1),
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        detail.$2,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'work':
        return Icons.work_outline;
      case 'straighten':
        return Icons.straighten;
      case 'school':
        return Icons.school_outlined;
      case 'church':
        return Icons.church_outlined;
      case 'pets':
        return Icons.pets;
      case 'wine_bar':
        return Icons.wine_bar_outlined;
      default:
        return Icons.circle;
    }
  }

  Widget _buildSpotifySection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Top Artists',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuD2SAAAwRbIbeqoPkHOvHGhN2cqx62N60X6G-hxLliK7LEl08Y6V_2E8l3G8zRSyjES_RAKLROvCDFcpQCu-rO2GomDS1gcWOX0D_2RrGKZDljVndYpmVlgH5uwE3uf-57r7hKHH9PL9O35x6FZ7vIFticTfXEV5C0NeKjnKtbWMoJiF9N8Ow9_alQjZ4gkd0dV6S8l7D98sPmZinaECSd6HHo2p24N_SpgN0zqKo8C_lOhCmXgnfXD58-LkBEd1bdp1HK0MIEAZ60',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Spotify',
                    style: TextStyle(
                      color: Color(0xFF1DB954),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(
                    profile.topArtistImages!.length.clamp(0, 3),
                    (index) => Container(
                      margin: EdgeInsets.only(left: index > 0 ? 0 : 0),
                      child: Transform.translate(
                        offset: Offset(-12.0 * index, 0),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            image: DecorationImage(
                              image: NetworkImage(
                                profile.topArtistImages![index],
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        profile.musicTaste ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        profile.artistsList ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryPhotos() {
    if (profile.photos.length <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(profile.photos[1]),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingEditButton() {
    return Positioned(
      bottom: 32,
      left: 32,
      right: 32,
      child: ElevatedButton(
        onPressed: () {
          context.push('/edit-profile');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 8,
          shadowColor: AppColors.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit),
            SizedBox(width: 8),
            Text(
              'Edit Your Profile',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
