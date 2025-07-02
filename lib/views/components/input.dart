import 'package:flutter/material.dart';
import 'package:wordivate/core/constants/app_colors.dart';
// --- Placeholder AppColors ---
// Replace with your actual color constants.

/// A redesigned, modern chat input field widget.
///
/// This widget features a clean, pill-shaped design with a background that
/// subtly changes on focus. The send button smoothly animates into view when
/// the user types a message, and it's replaced by a loading indicator when
// an operation is in progress.
class ModernChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;
  final bool isLoading;
  final FocusNode focusNode;
 

  const ModernChatInputField({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.focusNode,
    this.isLoading = false,
  });

  @override
  State<ModernChatInputField> createState() => _ModernChatInputFieldState();
}

class _ModernChatInputFieldState extends State<ModernChatInputField> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    // Add listener to the controller to update the UI based on text input
    widget.controller.addListener(_onTextChanged);
    // Add listener to the focus node to rebuild on focus changes
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    // Clean up listeners to prevent memory leaks
    widget.controller.removeListener(_onTextChanged);
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  /// Rebuilds the widget when focus changes to update the border color.
  void _onFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Checks if the text field has any text and updates the state.
  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    // Only update the state if it has actually changed
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtain the current theme
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      // Use Material to provide a background color and elevation shadow
      child: Material(
        borderRadius: BorderRadius.circular(30.0),
        // Use theme-aware color for the background
        color: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
        elevation: 1.0,
        shadowColor: theme.shadowColor.withOpacity(0.1), // Use themed shadow color
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            // The border provides a subtle visual cue when the field is focused.
            border: Border.all(
              // Use theme-aware colors for the border
              color: widget.focusNode.hasFocus
                  ? theme.colorScheme.primary  // Focused border color
                  : (theme.inputDecorationTheme.enabledBorder?.borderSide.color ?? theme.colorScheme.outline), // Non-focused border color
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 16),
              // The TextField is expanded to take up all available horizontal space.
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  // Use theme-aware text color
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    // Use theme-aware hint text color
                    hintStyle: theme.inputDecorationTheme.hintStyle ?? TextStyle(color: theme.hintColor),
                    // No border is needed as the parent container provides it.
                    border: InputBorder.none,
                    // Remove all default padding to have full control.
                    contentPadding: EdgeInsets.zero,
                  ),
                  // Standard text input configurations
                  maxLines: 5,
                  minLines: 1,

                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.send,
                  enabled: !widget.isLoading,
                  // The onSubmitted callback is triggered when the user presses the 'send' action.
                  onSubmitted: (text) {
                    if (_hasText && !widget.isLoading) {
                      widget.onSubmitted(text);
                    }
                  },
                ),
              ),
              // The trailing action widget (send button or loading indicator)
              _buildTrailingAction(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the widget that appears at the end of the input field.
  ///
  /// This will be a send button, a loading indicator, or nothing,
  /// depending on the current state.
  Widget _buildTrailingAction() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      // AnimatedSwitcher provides a smooth transition between the loading
      // indicator and the send button.
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) {
          // Use a combination of scale and fade for a polished look.
          return ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child:
            widget.isLoading
                // If loading, show a progress indicator.
                ? _buildLoadingIndicator()
                // If not loading, show the send button (if there's text).
                : _buildSendButton(),
      ),
    );
  }

  /// A simple circular progress indicator.
Widget _buildLoadingIndicator() {
  final primaryColor = Theme.of(context).colorScheme.primary;
  return SizedBox(
    width: 40,
    height: 40,
    child: Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      ),
    ),
  );
}

  /// The send button, which is only visible when there is text.
  Widget _buildSendButton() {
    return SizedBox(
      key: const ValueKey('send_button'),
      width: 40,
      height: 40,
      child:
          _hasText
              // If there is text, show an enabled IconButton.
              ? IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
                icon: const Icon(Icons.send_rounded, size: 20),
                onPressed: () => widget.onSubmitted(widget.controller.text),
              )
              // If there is no text, show a disabled placeholder icon.
              // This keeps the layout consistent.
              : const Icon(
                Icons.send_rounded,
                color: Colors.transparent, // Hidden but occupies space
              ),
    );
  }
}

// Example usage of the ModernChatInputField
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;
  final List<String> _messages = [];

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _messages.add(text);
    });

    // Simulate a network request
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _controller.clear();
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modern Chat UI'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              reverse: true, // To show latest messages at the bottom
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                // Display messages in reverse order
                final message = _messages[_messages.length - 1 - index];
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          // The main chat input field at the bottom of the screen.
          SafeArea(
            child: ModernChatInputField(
              controller: _controller,
              focusNode: _focusNode,
              onSubmitted: _handleSubmitted,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }
}

// Main function to run the example
void main() {
  runApp(
    MaterialApp(
      title: 'Chat UI Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ChatScreen(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
