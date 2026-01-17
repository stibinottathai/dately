import 'package:dately/app/theme/app_colors.dart';
import 'package:dately/features/discovery/domain/profile.dart';
import 'package:dately/features/messages/domain/conversation.dart';
import 'package:flutter/material.dart';

import 'package:dately/features/likes/providers/likes_provider.dart';

import 'package:dately/features/messages/providers/matches_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileDetailScreen extends ConsumerStatefulWidget {
  final Profile profile;
  final String? matchId;

  const ProfileDetailScreen({super.key, required this.profile, this.matchId});

  @override
  ConsumerState<ProfileDetailScreen> createState() =>
      _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends ConsumerState<ProfileDetailScreen> {
  int _currentPhotoIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Check if matched
    final matchesState = ref.watch(matchesProvider);
    final match = matchesState.matches.firstWhere(
      (m) => m.otherUser.id == widget.profile.id,
      orElse: () => Conversation(
        id: widget.matchId ?? '',
        otherUser: widget.profile,
        unreadCount: 0,
        isNewMatch: false,
        isOnline: false,
      ),
    );
    final isMatched = match.id.isNotEmpty;

    // Check if like sent
    final likesState = ref.watch(likesProvider);
    final sentLike = likesState.sentLikes
        .where((l) => l.profile.id == widget.profile.id)
        .firstOrNull;
    final isLikeSent = sentLike != null;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBasicInfo(),
                      const SizedBox(height: 24),
                      _buildAboutMe(),
                      const SizedBox(height: 24),
                      _buildDetails(),
                      const SizedBox(height: 24),
                      if (widget.profile.interests.isNotEmpty)
                        _buildInterests(),
                      const SizedBox(height: 32),
                      if (isMatched)
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Unmatch User?'),
                                  content: const Text(
                                    'Are you sure you want to unmatch? This action cannot be undone.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('Unmatch'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await ref
                                    .read(matchesProvider.notifier)
                                    .unmatchUser(match.id);
                                if (mounted) {
                                  context.pop(); // Close profile details
                                }
                              }
                            },
                            icon: const Icon(Icons.person_remove),
                            label: const Text('Unmatch & Remove'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red.shade400,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.red.shade100),
                              ),
                              backgroundColor: Colors.red.shade50,
                            ),
                          ),
                        ),
                      const SizedBox(height: 100), // Space for bottom buttons
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.4),
              child: IconButton(
                icon: const Icon(Icons.arrow_downward, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          // Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0),
                    Colors.white,
                    Colors.white,
                  ],
                  stops: const [0.0, 0.2, 1.0],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (isMatched) {
                          // Navigate to Chat
                          if (match.id == widget.matchId) {
                            // If we are using the passed matchID (and not a full conversation from provider)
                            // We should pass profile as extra so ChatScreen handles it essentially as a new match
                            context.push(
                              '/chat/${match.id}',
                              extra: widget.profile,
                            );
                          } else {
                            context.push('/chat/${match.id}', extra: match);
                          }
                        } else if (isLikeSent) {
                          // Retract Like
                          await ref
                              .read(likesProvider.notifier)
                              .unlikeUser(sentLike.id);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Like Retracted')),
                            );
                          }
                        } else {
                          // Like User
                          final matchId = await ref
                              .read(likesProvider.notifier)
                              .likeUser(widget.profile.id);

                          if (mounted) {
                            if (matchId != null) {
                              // It's a match!
                              // Maybe show match dialog here?
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('It\'s a Match! 🎉'),
                                ),
                              );
                              // Refresh matches to ensure we get the ID next time
                              ref.read(matchesProvider.notifier).fetchMatches();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Like Sent! ❤️')),
                              );
                            }
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isMatched
                            ? AppColors.primary
                            : isLikeSent
                            ? Colors.grey.shade300
                            : const Color(0xFFE94057),
                        foregroundColor: isLikeSent
                            ? Colors.black87
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        elevation: isLikeSent ? 0 : 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isMatched
                                ? Icons.chat_bubble_outline
                                : isLikeSent
                                ? Icons.undo
                                : Icons.favorite,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isMatched
                                ? 'Message'
                                : isLikeSent
                                ? 'Retract'
                                : 'Like',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 500,
      pinned: true,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: widget.profile.imageUrls.isNotEmpty
                  ? widget.profile.imageUrls.length
                  : 1,
              onPageChanged: (index) =>
                  setState(() => _currentPhotoIndex = index),
              itemBuilder: (context, index) {
                if (widget.profile.imageUrls.isEmpty) {
                  return Image.network(
                    AppColors.getDefaultAvatarUrl(widget.profile.name),
                    fit: BoxFit.cover,
                  );
                }
                return Image.network(
                  widget.profile.imageUrls[index],
                  fit: BoxFit.cover,
                );
              },
            ),
            // Photo indicators
            if (widget.profile.imageUrls.length > 1)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_currentPhotoIndex + 1}/${widget.profile.imageUrls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${widget.profile.name}, ${widget.profile.age}',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            if (widget.profile.isVerified) ...[
              const SizedBox(width: 8),
              const Icon(Icons.verified, color: Colors.blue, size: 28),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              '${widget.profile.location} • ${widget.profile.distanceMiles} miles away',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutMe() {
    if (widget.profile.bio.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About Me',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          widget.profile.bio,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDetails() {
    final details =
        [
              {'icon': Icons.work, 'text': widget.profile.occupation},
              {'icon': Icons.school, 'text': widget.profile.education},
              {'icon': Icons.height, 'text': widget.profile.height},
              {'icon': Icons.church, 'text': widget.profile.religion},
              {'icon': Icons.pets, 'text': widget.profile.petPreference},
              {'icon': Icons.wine_bar, 'text': widget.profile.drinkingHabit},
            ]
            .where(
              (item) =>
                  item['text'] != null && (item['text'] as String).isNotEmpty,
            )
            .toList();

    if (details.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: details.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item['icon'] as IconData, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(item['text'] as String),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInterests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Interests',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: widget.profile.interests.map((interest) {
            return Chip(
              label: Text(interest),
              backgroundColor: Colors.grey.shade100,
            );
          }).toList(),
        ),
      ],
    );
  }
}
