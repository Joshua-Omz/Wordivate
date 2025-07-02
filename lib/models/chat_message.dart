import 'package:wordivate/models/wordrespons.dart';
import 'dart:convert';

/// Enum defining the type of message sender
enum MessageSender {
  user,
  bot,
}

/// Enum defining the message status
enum MessageStatus {
  sending,
  sent,
  error,
}

/// Enum defining the type of message content
enum MessageType {
  text,
  wordDefinition,
}

/// Model class for chat messages
class ChatMessage {
  /// Unique identifier for the message
  final String id;
  
  /// Content of the message
  final String text;
  
  /// Type of the sender (user or bot)
  final MessageSender sender;
  
  /// Current status of the message
  final MessageStatus status;
  
  /// Type of message content
  final MessageType type;
  
  /// Timestamp when the message was created
  final DateTime timestamp;
  
  /// Word definition data (null for regular text messages)
  final WordResponse? wordDefinition;
  
  
  /// Whether this message has been saved to user's word list
  final bool isSaved;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    this.status = MessageStatus.sent,
    this.type = MessageType.text,
    DateTime? timestamp,
    this.wordDefinition,
    this.isSaved = false,
  }) : this.timestamp = timestamp ?? DateTime.now();

  /// Create a new instance with updated properties
  ChatMessage copyWith({
    String? id,
    String? text,
    MessageSender? sender,
    MessageStatus? status,
    MessageType? type,
    DateTime? timestamp,
    WordResponse? wordDefinition,
    
    bool? isSaved,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      status: status ?? this.status,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      wordDefinition: wordDefinition ?? this.wordDefinition,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  /// Create a user message with a word query
  factory ChatMessage.userQuery(String text) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      sender: MessageSender.user,
      status: MessageStatus.sent,
      type: MessageType.text,
    );
  }

  /// Create a message from the bot with a word definition
  factory ChatMessage.botResponse(String text, WordResponse definition) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      sender: MessageSender.bot,
      status: MessageStatus.sent,
      type: MessageType.wordDefinition,
      wordDefinition: definition,
    );
  }

  /// Create a loading message while waiting for the bot's response
  factory ChatMessage.loading() {
    return ChatMessage(
      id: 'loading-${DateTime.now().millisecondsSinceEpoch}',
      text: 'Thinking...',
      sender: MessageSender.bot,
      status: MessageStatus.sending,
      type: MessageType.text,
    );
  }

  /// Create an error message when API request fails
  factory ChatMessage.error(String errorMessage) {
    return ChatMessage(
      id: 'error-${DateTime.now().millisecondsSinceEpoch}',
      text: 'Error: $errorMessage',
      sender: MessageSender.bot,
      status: MessageStatus.error,
      type: MessageType.text,
    );
  }

  /// Convert message to JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'sender': sender.toString(),
      'status': status.toString(),
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
      'wordDefinition': wordDefinition?.toJson(),
      'isSaved': isSaved,
    };
  }

  /// Create message from JSON data
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      text: json['text'] as String,
      sender: MessageSender.values.firstWhere(
        (e) => e.toString() == json['sender'],
        orElse: () => MessageSender.user,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => MessageType.text,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      wordDefinition: json['wordDefinition'] != null
          ? WordResponse.fromJson(json['wordDefinition'])
          : null,
      isSaved: json['isSaved'] as bool? ?? false,
    );
  }
}