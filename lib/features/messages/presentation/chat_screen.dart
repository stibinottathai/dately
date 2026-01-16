import 'package:dately/app/theme/app_colors.dart';
import 'package:dately/features/discovery/domain/profile.dart';
import 'package:dately/features/messages/domain/conversation.dart';

import 'package:dately/features/messages/presentation/widgets/message_bubble.dart';
import 'package:dately/features/messages/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final dynamic conversationData;

  const ChatScreen({
    super.key,
    required this.conversationId,
    this.conversationData,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late Profile otherUser;
  bool isOnline = false;
  String lastActiveText = 'Active now';

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    // Check if we got conversation data directly
    if (widget.conversationData is Conversation) {
      final conversation = widget.conversationData as Conversation;
      otherUser = conversation.otherUser;
      isOnline = conversation.isOnline;
      lastActiveText = conversation.lastActiveText;
    } else if (widget.conversationData is Profile) {
      // New match scenario (passed Profile directly)
      otherUser = widget.conversationData as Profile;
      isOnline = true; // Assuming active if just matched
    } else {
      // Fallback or loading state if data missing?
      // For now assume passed correctly.
      // Ideally we fetch profile if missing.
      otherUser = Profile(
        id: 'unknown',
        name: 'User',
        age: 25,
        bio: '',
        location: '',
        distanceMiles: 0,
        imageUrls: [],
        interests: [],
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    ref.read(chatProvider(widget.conversationId).notifier).sendMessage(text);
    _messageController.clear();

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0, // Reverse list, so 0 is bottom
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider(widget.conversationId));
    final messages = chatState.messages;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top App Bar
          _buildTopAppBar(context),

          // Messages Area
          Expanded(
            child: chatState.isLoading && messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    reverse:
                        true, // Show newest at bottom (which is top of list in reverse)
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length + 1, // +1 for date separator
                    itemBuilder: (context, index) {
                      if (index == messages.length) {
                        // Date separator at end of list (top physically)
                        return _buildDateSeparator();
                      }
                      final message = messages[index];
                      return MessageBubble(
                        message: message,
                        senderAvatarUrl: message.isSentByMe
                            ? null
                            : (otherUser.imageUrls.isNotEmpty
                                  ? otherUser.imageUrls[0]
                                  : null),
                      );
                    },
                  ),
          ),

          // Input Area
          _buildInputArea(context),
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
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 20),
            ),
          ),

          const SizedBox(width: 12),

          // Profile Photo with Online Indicator
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  image: otherUser.imageUrls.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(otherUser.imageUrls[0]),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: otherUser.imageUrls.isEmpty
                    ? const Icon(Icons.person)
                    : null,
              ),
              if (isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 12),

          // Name and Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  otherUser.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  lastActiveText,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Action Buttons
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildDateSeparator() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'TODAY',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
            letterSpacing: 1,
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: otherUser.imageUrls.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(otherUser.imageUrls[0]),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: otherUser.imageUrls.isEmpty
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            'You matched with ${otherUser.name}!',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Say hi to start the conversation',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Add Button
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.add),
                iconSize: 24,
                onPressed: () {},
                padding: EdgeInsets.zero,
              ),
            ),

            const SizedBox(width: 8),

            // Text Input Field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    // Send Button
                    Container(
                      margin: const EdgeInsets.all(4),
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send),
                        iconSize: 16,
                        color: Colors.white,
                        onPressed: _sendMessage,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Microphone Button
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.mic),
                iconSize: 24,
                onPressed: () {},
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
