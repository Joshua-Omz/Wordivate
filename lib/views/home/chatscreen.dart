import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wordivate/core/constants/app_colors.dart';
import 'package:wordivate/models/chat_message.dart';
import 'package:wordivate/models/wordrespons.dart';
import 'package:wordivate/providers/word_provider.dart';
import 'package:wordivate/views/components/chat_bubble.dart';
import 'package:wordivate/views/components/input.dart';
import 'package:wordivate/providers/wordlistprovider.dart';
import 'package:wordivate/views/categories/wordlistscreen.dart';
import 'package:wordivate/views/components/app_drawer.dart';
import 'package:wordivate/core/constants/text_styles.dart';
import 'package:wordivate/providers/navigation_provider.dart';
import 'package:wordivate/views/categories/categorywordlistscreen.dart';
import 'package:wordivate/views/settings/settings_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isFirstMessage = true;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();

    // Setup animation controller
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Add welcome message
    _addBotMessage(
      "Welcome to Wordivate! Enter any word to get its definition, context, examples, and suggested category.",
      isDelayed: false,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    final String word = text.trim();
    final userMessage = ChatMessage.userQuery(word);

    setState(() {
      _messages.add(userMessage);

      // Add a "Thinking..." message that will be replaced later
      if (!_isFirstMessage) {
        _messages.add(ChatMessage.loading());
      }
      _isFirstMessage = false;
    });

    _textController.clear();
    _scrollToBottom();

    try {
      // Show typing indicator for a moment to create a more natural feel
      await Future.delayed(const Duration(milliseconds: 500));

      // Process the word
      final wordProvider = ref.read(wordsProvider.notifier);
      final WordResponse response = await wordProvider.processWordFromInput(
        word,
      );

      // Remove loading message if it exists
      setState(() {
        _messages.removeWhere(
          (msg) =>
              msg.status == MessageStatus.sending &&
              msg.sender == MessageSender.bot,
        );
      });

      // Add the bot response with the word definition
      final botMessage = ChatMessage.botResponse(word, response);
      setState(() {
        _messages.add(botMessage);
      });

      _scrollToBottom();
    } catch (e) {
      // Remove loading message
      setState(() {
        _messages.removeWhere(
          (msg) =>
              msg.status == MessageStatus.sending &&
              msg.sender == MessageSender.bot,
        );

        // Add error message
        _messages.add(
          ChatMessage.error(
            "Sorry, I couldn't fetch the meaninig of the word. Please try again.",
          ),
        );
      });

      _scrollToBottom();
    }
  }

  void _addBotMessage(String text, {bool isDelayed = true}) async {
    if (isDelayed) {
      // Add a small delay to simulate typing
      await Future.delayed(const Duration(milliseconds: 500));
    }

    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          sender: MessageSender.bot,
          status: MessageStatus.sent,
        ),
      );
    });

    _scrollToBottom();
  }

  void _saveWord(String messageId) async {
    final index = _messages.indexWhere((msg) => msg.id == messageId);
    if (index == -1) return;

    final message = _messages[index];
    if (message.type != MessageType.wordDefinition ||
        message.wordDefinition == null)
      return;

    // Save the word
    final wordProvider = ref.read(wordsProvider.notifier);
    await wordProvider.saveWord(message.text, message.wordDefinition!);

    // Update the message to show it's been saved
    setState(() {
      _messages[index] = message.copyWith(isSaved: true);
    });

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("'${message.text}' has been saved to your collection"),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the navigation provider to get the current index
    final selectedIndex = ref.watch(navigationProvider);
    
    // Define all screens for navigation
    final List<Widget> screens = [
      _buildChatScreenContent(), // Chat screen content
      WordListScreen(
        category: 'all',
        onFavoriteToggle: (id) => ref.read(wordsProvider.notifier).toggleFavorite(id),
        onDelete: (id) => ref.read(wordsProvider.notifier).deleteWord(id),
      ),
      WordListScreen(
        category: 'favorites',
        onFavoriteToggle: (id) => ref.read(wordsProvider.notifier).toggleFavorite(id),
        onDelete: (id) => ref.read(wordsProvider.notifier).deleteWord(id),
      ),
      WordListScreen(
        category: 'recent',
        onFavoriteToggle: (id) => ref.read(wordsProvider.notifier).toggleFavorite(id),
        onDelete: (id) => ref.read(wordsProvider.notifier).deleteWord(id),
      ),
      CategoryWordlistScreen(
        categoryName: 'General',
        categoryColor: context.colorScheme.primary,
        categoryIcon: Icons.category,
      ),
      const SettingsScreen(),
    ];
    
    // Get title based on selected index
    String getTitle() {
      switch (selectedIndex) {
        case 0:
          return 'Wordivate';
        case 1:
          return 'All Words';
        case 2:
          return 'Favorites';
        case 3:
          return 'Recent Words';
        case 4:
          return 'Categories';
        case 5:
          return 'Settings';
        default:
          return 'Wordivate';
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: selectedIndex == 0 
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    size: 20,
                    color: context.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Wordivate',
                  style: context.titleLarge.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            )
          : Text(getTitle(), style: context.titleLarge),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: context.colorScheme.onSurface,
        centerTitle: selectedIndex != 0,
        actions: selectedIndex == 0 ? [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              icon: Icon(Icons.book_outlined, color: context.primaryIconColor),
              tooltip: 'My Word List',
              onPressed: () {
                ref.read(navigationProvider.notifier).state = 1; // Navigate to All Words
              },
            ),
          ),
        ] : null,
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
    );
  }

  // New method to extract the chat screen content
  Widget _buildChatScreenContent() {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Chat messages
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      // Add entrance animation for new messages
                      final isLastMessage = index == _messages.length - 1;

                      if (isLastMessage) {
                        _fadeController.forward(from: 0.0);
                      }

                      return isLastMessage
                          ? FadeTransition(
                              opacity: _fadeController,
                              child: ChatBubble(
                                message: _messages[index],
                                onSaveWord: _saveWord,
                                showTimestamp:
                                    index > 0 &&
                                    _shouldShowTimestamp(
                                      _messages[index],
                                      _messages[index - 1],
                                    ),
                              ),
                            )
                          : ChatBubble(
                              message: _messages[index],
                              onSaveWord: _saveWord,
                              showTimestamp:
                                  index > 0 &&
                                  _shouldShowTimestamp(
                                    _messages[index],
                                    _messages[index - 1],
                                  ),
                            );
                    },
                  ),
          ),

          // Fix for keyboard overlap
          ModernChatInputField(
            controller: _textController,
            onSubmitted: _handleSubmitted,
            isLoading: ref.watch(wordsProvider).isLoading,
            focusNode: FocusNode()
          ),
        ],
      ),
    );
  }

  bool _shouldShowTimestamp(ChatMessage current, ChatMessage previous) {
    // Show timestamp if messages are from different senders or if more than 5 minutes apart
    return current.sender != previous.sender ||
        current.timestamp.difference(previous.timestamp).inMinutes > 5;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: context.colorScheme.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 60,
              color: context.colorScheme.primary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Expand Your Vocabulary",
            style: context.headingMedium,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Type any word to get its definition, context, and examples",
              textAlign: TextAlign.center,
              style: context.bodyMedium.copyWith(
                color: context.colorScheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 36),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.colorScheme.outline.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Try typing ",
                  style: context.bodyMedium.copyWith(
                    color: context.colorScheme.onSurface.withOpacity(0.7)
                  ),
                ),
                Text(
                  "serendipity",
                  style: context.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


