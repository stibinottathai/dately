import 'package:dately/app/theme/app_colors.dart';
import 'package:dately/features/messages/presentation/widgets/conversation_card.dart';
import 'package:dately/features/messages/presentation/widgets/new_match_avatar.dart';
import 'package:dately/features/messages/providers/matches_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MessagesScreen extends ConsumerWidget {
  final bool showBottomNav;

  const MessagesScreen({super.key, this.showBottomNav = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesState = ref.watch(matchesProvider);
    // Split matches into 'new' and 'conversations'
    // For now, we put all in 'new' if no last message, and 'conversations' if has message?
    // Or just put all in 'New Matches' separate from 'Conversations' list?
    // The design usually has horizontal list for new matches and vertical for chats.
    // I'll put recent matches (last 24h?) in top.

    // Simplification: All matches in top list, and all matches in bottom list too for now?
    // Or just top list.

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: matchesState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Top App Bar
                _buildTopAppBar(context),

                // Scrollable Content
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await ref.read(matchesProvider.notifier).fetchMatches();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // New Matches Section
                          if (matchesState.matches.isNotEmpty)
                            Container(
                              color: Colors.grey.shade50,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      'New Matches',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 19,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 110,
                                    child: ListView.separated(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: matchesState.matches.length,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(width: 24),
                                      itemBuilder: (context, index) {
                                        final match =
                                            matchesState.matches[index];
                                        return NewMatchAvatar(
                                          profile: match.otherUser,
                                          onTap: () {
                                            context.push(
                                              '/chat/${match.id}',
                                              extra: match,
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Conversations Section
                          Container(
                            color: Colors.grey.shade50,
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'Conversations',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19,
                                    ),
                              ),
                            ),
                          ),

                          // Conversations List
                          Container(
                            color: Colors.white,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: matchesState.matches.length,
                              itemBuilder: (context, index) {
                                final conversation =
                                    matchesState.matches[index];
                                return ConversationCard(
                                  conversation: conversation,
                                  onTap: () {
                                    context.push(
                                      '/chat/${conversation.id}',
                                      extra: conversation,
                                    );
                                  },
                                );
                              },
                            ),
                          ),

                          // Bottom Padding for Navigation Bar
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

      // Bottom Navigation
      bottomNavigationBar: showBottomNav ? _buildBottomNav(context) : null,
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
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
          // Settings Icon
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.centerLeft,
            child: const Icon(Icons.settings, size: 28),
          ),

          // Title
          Text(
            'Messages',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
          ),

          // Search Button
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.search),
              iconSize: 28,
              onPressed: () {
                // TODO: Implement search
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.explore, false, '/counter', context),
            _buildNavItem(Icons.search, false, null, context),
            _buildNavItem(Icons.chat_bubble, true, null, context),
            _buildNavItem(Icons.favorite, false, '/likes', context),
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
              width: 6,
              height: 6,
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
