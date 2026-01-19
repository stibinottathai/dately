import 'dart:async';
import 'dart:io';

import 'package:dately/app/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dately/features/discovery/domain/profile.dart';
import 'package:dately/features/messages/domain/conversation.dart';

import 'package:dately/features/messages/presentation/widgets/message_bubble.dart';
import 'package:dately/app/widgets/cached_image.dart';
import 'package:dately/features/messages/providers/chat_provider.dart';
import 'package:dately/features/messages/providers/matches_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

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

class _ChatScreenState extends ConsumerState<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late Profile otherUser;
  bool isOnline = false;
  String lastActiveText = 'Active now';

  // Audio Recording
  late AudioRecorder _audioRecorder;
  bool _isRecording = false;
  Timer? _timer;
  int _recordDuration = 0;
  String? _audioPath;

  // Animation
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _initializeChat();
    // Mark as read
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(matchesProvider.notifier).markAsRead(widget.conversationId);
    });

    // Animation initialization
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation =
        Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0, -5), // Fly up
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
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
    _timer?.cancel();
    _audioRecorder.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      ref
          .read(chatProvider(widget.conversationId).notifier)
          .sendImageMessage(image.path);
    }
  }

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission required')),
      );
      return;
    }

    final directory = await getTemporaryDirectory();
    final filePath =
        '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _audioRecorder.start(const RecordConfig(), path: filePath);

    setState(() {
      _isRecording = true;
      _audioPath = filePath;
      _recordDuration = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _recordDuration++;
        });
      }
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    if (!_isRecording) return;

    final path = await _audioRecorder.stop();
    if (path != null && _recordDuration > 0) {
      // Play animation
      await _animationController.forward();

      // Send audio
      try {
        await ref
            .read(chatProvider(widget.conversationId).notifier)
            .sendAudioMessage(path, Duration(seconds: _recordDuration));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to send audio: $e')));
        }
      }
    }

    if (mounted) {
      setState(() {
        _isRecording = false;
        _recordDuration = 0;
      });
      _animationController.reset();
    }
  }

  Future<void> _cancelRecording() async {
    _timer?.cancel();
    if (!_isRecording) return;

    await _audioRecorder.stop();
    // Delete file if exists? audioRecorder.stop returns path, we can delete it.
    // Assuming framework handles temp shuffle, or we can explicity delete.
    if (_audioPath != null) {
      final file = File(_audioPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }

    setState(() {
      _isRecording = false;
      _audioPath = null;
      _recordDuration = 0;
    });
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
                      return GestureDetector(
                        onLongPress: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              title: const Row(
                                children: [
                                  Icon(Icons.delete_outline, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete Message',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                              content: const Text(
                                'Are you sure you want to delete this message? This action cannot be undone.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              actionsPadding: const EdgeInsets.fromLTRB(
                                24,
                                0,
                                24,
                                24,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => context.pop(false),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.grey.shade600,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => context.pop(true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade50,
                                    foregroundColor: Colors.red,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            ref
                                .read(
                                  chatProvider(widget.conversationId).notifier,
                                )
                                .deleteMessage(message.id);
                          }
                        },
                        child: MessageBubble(
                          message: message,
                          senderAvatarUrl: message.isSentByMe
                              ? null
                              : (otherUser.imageUrls.isNotEmpty
                                    ? otherUser.imageUrls[0]
                                    : AppColors.getDefaultAvatarUrl(
                                        otherUser.name,
                                      )),
                        ),
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
      decoration: const BoxDecoration(color: Colors.white),
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
              GestureDetector(
                onTap: () {
                  if (otherUser.imageUrls.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: EdgeInsets.zero,
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: InteractiveViewer(
                                child: CachedImage(
                                  imageUrl: otherUser.imageUrls[0],
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 40,
                              right: 20,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
                child: CachedImage(
                  width: 40,
                  height: 40,
                  imageUrl: otherUser.imageUrls.isNotEmpty
                      ? otherUser.imageUrls[0]
                      : AppColors.getDefaultAvatarUrl(otherUser.name),
                  shape: BoxShape.circle,
                  fit: BoxFit.cover,
                ),
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
            child: GestureDetector(
              onTap: () {
                context.push('/profile-detail', extra: otherUser);
              },
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
          ),

          // Action Buttons
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),

          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'clear_chat') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    title: const Row(
                      children: [
                        Icon(Icons.delete_sweep_outlined, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Clear Chat',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    content: const Text(
                      'This will delete all messages in this conversation. This cannot be undone.',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    actions: [
                      TextButton(
                        onPressed: () => context.pop(false),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade600,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => context.pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Delete All',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  ref
                      .read(chatProvider(widget.conversationId).notifier)
                      .clearChat();
                }
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'clear_chat',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Clear Chat', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.more_vert),
            ),
          ),
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
          CachedImage(
            width: 80,
            height: 80,
            imageUrl: otherUser.imageUrls.isNotEmpty
                ? otherUser.imageUrls[0]
                : AppColors.getDefaultAvatarUrl(otherUser.name),
            shape: BoxShape.circle,
            fit: BoxFit.cover,
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
      decoration: const BoxDecoration(color: Colors.white),
      child: SafeArea(
        child: Row(
          children: [
            // Add Button
            if (!_isRecording) ...[
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
                  onPressed: _pickImage,
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 8),
            ],

            // Text Input Field or Recording Indicator
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: _isRecording
                      ? Colors.red.shade50
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: _isRecording
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.mic, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(
                              _formatDuration(_recordDuration),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'Release to send',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : Row(
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

            // Microphone Button (Hold to Record)
            GestureDetector(
              onLongPressStart: (_) => _startRecording(),
              onLongPressEnd: (_) => _stopRecording(),
              onLongPressCancel: () => _cancelRecording(),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return SlideTransition(
                    position: _slideAnimation,
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _isRecording ? Colors.red : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mic,
                    color: _isRecording ? Colors.white : Colors.black87,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }
}
