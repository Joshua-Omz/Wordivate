import 'package:wordivate/providers/word_provider.dart';
class WordResponse {
  final String definition;
  final String useContext;
  final String example;
  final String suggestedCategory;

  WordResponse({
    required this.definition,
    required this.useContext,
    required this.example,
    required this.suggestedCategory,
  });

  Map<String, dynamic> toJson() {
    return {
      'definition': definition,
      'use_context': useContext,
      'example': example,
      'suggested_category': suggestedCategory,
    };
  }

  factory WordResponse.fromJson(Map<String, dynamic> json) {
    return WordResponse(
      definition: json['definition'] ?? '',
      useContext: json['use_context'] ?? '',
      example: json['example'] ?? '',
      suggestedCategory: json['suggested_category'] ?? '',
    );
  }

}
