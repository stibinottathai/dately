import 'package:dately/app/widgets/app_bottom_nav.dart';

import 'package:dately/features/messages/presentation/widgets/conversation_card.dart';
import 'package:dately/features/messages/presentation/widgets/new_match_avatar.dart';
import 'package:dately/features/messages/providers/matches_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  final bool showBottomNav;

  const MessagesScreen({super.key, this.showBottomNav = true});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matchesState = ref.watch(matchesProvider);

    final allMatches = matchesState.matches;
    final searchQuery = _searchController.text.toLowerCase();

    final filteredMatches = _isSearching && searchQuery.isNotEmpty
        ? allMatches
              .where(
                (m) => m.otherUser.name.toLowerCase().contains(searchQuery),
              )
              .toList()
        : allMatches;

    final newMatches = filteredMatches.take(10).toList();
    final conversations = filteredMatches;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!matchesState.isLoading &&
              matchesState.hasMore &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
              !_isSearching) {
            ref.read(matchesProvider.notifier).fetchMatches();
          }
          return false;
        },
        child: matchesState.isLoading && matchesState.matches.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Top App Bar
                  _buildTopAppBar(context),

                  // Scrollable Content
                  Expanded(
                    child:
                        _isSearching &&
                            searchQuery.isNotEmpty &&
                            filteredMatches.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No match found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await ref
                                  .read(matchesProvider.notifier)
                                  .fetchMatches(refresh: true);
                            },
                            child: _buildBody(
                              filteredMatches,
                              newMatches,
                              conversations,
                              context,
                              matchesState,
                            ),
                          ),
                  ),
                ],
              ),
      ),

      // Bottom Navigation
      bottomNavigationBar: widget.showBottomNav
          ? const AppBottomNav(currentTab: AppTab.messages)
          : null,
    );
  }

  Widget _buildBody(
    List<dynamic> filteredMatches,
    List<dynamic> newMatches,
    List<dynamic> conversations,
    BuildContext context,
    MatchesState matchesState,
  ) {
    if (filteredMatches.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No chats yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start matching with people\nto see them here!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // New Matches Section
          if (newMatches.isNotEmpty)
            Container(
              color: Colors.grey.shade50,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'New Matches',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: newMatches.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 24),
                      itemBuilder: (context, index) {
                        final match =
                            newMatches[index]; // Dynamic typing, cast if needed or rely on dynamic
                        return NewMatchAvatar(
                          profile: match.otherUser,
                          isNew: match.isNewMatch,
                          onTap: () {
                            context.push('/chat/${match.id}', extra: match);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Conversations Section
          if (conversations.isNotEmpty) ...[
            Container(
              color: Colors.grey.shade50,
              padding: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Conversations',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
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
          ],

          if (matchesState.isLoading && matchesState.matches.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),

          // Bottom Padding for Navigation Bar
          const SizedBox(height: 80),
        ],
      ),
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
          // Search Mode: Back Button + Field
          if (_isSearching) ...[
            GestureDetector(
              onTap: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                });
              },
              child: const Icon(Icons.arrow_back_ios, size: 24),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search chats...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                  ),
                  style: const TextStyle(fontSize: 18),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _searchController.clear();
                  });
                },
                child: const Icon(Icons.close, size: 24),
              ),
          ] else ...[
            // Normal Mode: Settings + Title + Search Icon
            Text(
              'Messages',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),

            Container(
              width: 48,
              height: 48,
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.search),
                iconSize: 28,
                onPressed: () {
                  setState(() {
                    _isSearching = true;
                  });
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
