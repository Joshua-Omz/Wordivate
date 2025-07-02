import 'package:flutter/material.dart';
import 'package:wordivate/core/constants/app_colors.dart';
import 'package:wordivate/models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final Function(String) onSaveWord;
  final bool showTimestamp;
  
  const ChatBubble({
    Key? key,
    required this.message,
    required this.onSaveWord,
    this.showTimestamp = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if we're in dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: message.sender == MessageSender.user 
            ? CrossAxisAlignment.end 
            : CrossAxisAlignment.start,
        children: [
          // Message bubble
          _buildMessageContent(context, isDarkMode),
          
          // Optional timestamp
          if (showTimestamp) 
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? AppColors.textLight.withOpacity(0.7) : AppColors.textLight,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, bool isDarkMode) {
    // Handle different message types
    switch (message.type) {
      case MessageType.wordDefinition:
        return _buildWordDefinitionBubble(context, isDarkMode);
      case MessageType.text:
      default:
        return _buildTextBubble(context, isDarkMode);
    }
  }

  Widget _buildTextBubble(BuildContext context, bool isDarkMode) {
    final isUser = message.sender == MessageSender.user;
    final isError = message.status == MessageStatus.error;
    final isLoading = message.status == MessageStatus.sending;
    
    // Adjust colors based on dark mode
    final botBubbleColor = isDarkMode 
        ? AppColors.primaryDark.withOpacity(0.3)  // Darker for dark mode
        : AppColors.surfaceLight;
    
    final botTextColor = isDarkMode 
        ? Colors.white.withOpacity(0.9)  // Lighter text for dark mode
        : AppColors.textPrimary;
    
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: isUser 
            ? AppColors.primary 
            : (isError 
                ? (isDarkMode ? AppColors.error.withOpacity(0.3) : AppColors.error.withOpacity(0.1)) 
                : botBubbleColor),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isUser ? 20 : 4),
          topRight: Radius.circular(isUser ? 4 : 20),
          bottomLeft: const Radius.circular(20),
          bottomRight: const Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: isLoading 
          ? _buildLoadingBubble(isDarkMode) 
          : Text(
              message.text,
              style: TextStyle(
                color: isUser ? AppColors.textOnPrimary : botTextColor,
                fontSize: 16,
              ),
            ),
    );
  }

  Widget _buildLoadingBubble(bool isDarkMode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              isDarkMode ? Colors.white70 : AppColors.primary
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          message.text,
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildWordDefinitionBubble(BuildContext context, bool isDarkMode) {
    final definition = message.wordDefinition!;
    
    // Adjust colors for dark mode
    final cardBackground = isDarkMode ? AppColors.primaryDark.withOpacity(0.3) : AppColors.surfaceLight;
    final borderColor = isDarkMode ? Colors.grey[700]! : AppColors.divider;
    final textColor = isDarkMode ? Colors.white.withOpacity(0.9) : AppColors.textPrimary;
    final secondaryTextColor = isDarkMode ? Colors.white70 : AppColors.textSecondary;
    
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.85,
      ),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bot header with logo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Wordivate",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),

          // Word title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          
          Divider(color: borderColor),
          
          // Definition
          _buildDefinitionSection("Definition", definition.definition, isDarkMode: isDarkMode),
          
          // Context
          _buildDefinitionSection("Context", definition.useContext, isDarkMode: isDarkMode),
          
          // Example
          _buildDefinitionSection(
            "Example", 
            definition.example,
            isItalic: true,
            isDarkMode: isDarkMode,
          ),
          
          // Category
          _buildDefinitionSection(
            "Category", 
            definition.suggestedCategory,
            isCategory: true,
            isDarkMode: isDarkMode,
          ),
          
          // Save button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: message.isSaved
                ? OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.check, color: AppColors.success),
                    label: const Text(
                      "Saved to Words",
                      style: TextStyle(color: AppColors.success),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.success),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: () => onSaveWord(message.id),
                    icon: const Icon(Icons.add),
                    label: const Text("Save to My Words"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefinitionSection(String title, String content, {
    bool isItalic = false,
    bool isCategory = false,
    required bool isDarkMode,
  }) {
    // Adjust text colors for dark mode
    final titleColor = isDarkMode ? Colors.white70 : AppColors.textSecondary;
    final contentColor = isCategory 
        ? AppColors.primary
        : (isDarkMode ? Colors.white.withOpacity(0.9) : AppColors.textPrimary);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              color: contentColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}