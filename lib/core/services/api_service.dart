import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:wordivate/models/wordrespons.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  // Private members
  GenerativeModel? _model;
  final Map<String, WordResponse> _definitionCache = {};
  bool _isInitialized = false;
  
  ApiService._internal();
  
  // Initialize the API client
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('ERROR: Gemini API key is missing in .env file');
      throw Exception('API key is missing. Please check your .env file.');
    }
    
    try {
      // Create the model with the provided API key
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.2,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        ),
      );
      
      _isInitialized = true;
      debugPrint('Gemini API initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Gemini API: $e');
      throw Exception('Failed to initialize Gemini API: $e');
    }
  }
  
  // Get word definition
  Future<WordResponse> getDefinition(String word) async {
    // Make sure the client is initialized
    if (!_isInitialized) {
      await initialize();
    }
    
    if (_model == null) {
      throw Exception('Gemini model not initialized properly');
    }
    
    // Normalize the word
    final normalizedWord = word.trim().toLowerCase();
    
    // Check cache
    if (_definitionCache.containsKey(normalizedWord)) {
      debugPrint('Cache hit for word: $normalizedWord');
      return _definitionCache[normalizedWord]!;
    }
    
    try {
      debugPrint('Fetching definition for: $normalizedWord');
      
      // Construct the prompt
      final promptText = '''
You are a dictionary API. Provide information about the word "$normalizedWord" in valid JSON format with these fields:
- definition: The primary meaning of the word.
- use_context: How and when to use this word.
- example: A sentence demonstrating proper usage.
- suggested_category: A category this word belongs to.

You must respond with ONLY a raw JSON object. No explanations, markdown formatting, or code blocks.
Example format: {"definition":"meaning of word","use_context":"how to use","example":"example sentence","suggested_category":"category"}
''';

      // Generate content
      final content = [Content.text(promptText)];
      final response = await _model!.generateContent(content);
      
      // Extract text from response
      final responseText = response.text;
      
      if (responseText == null || responseText.isEmpty) {
        throw Exception('Empty response from Gemini API');
      }
      
      debugPrint('Raw Gemini response: $responseText');
      
      // Parse the response
      final wordResponse = _parseGeminiResponse(responseText, normalizedWord);
      
      // Cache the result
      _definitionCache[normalizedWord] = wordResponse;
      
      return wordResponse;
    } catch (e) {
      debugPrint('Error fetching definition: $e');
      throw Exception('Failed to get definition: $e');
    }
  }
  
  // Parse Gemini response with multiple fallback approaches
  WordResponse _parseGeminiResponse(String textContent, String originalWord) {
    // Try direct JSON parsing first
    try {
      final cleanedText = textContent.trim();
      final wordData = json.decode(cleanedText);
      return WordResponse.fromJson(wordData);
    } catch (directJsonError) {
      debugPrint('Direct JSON parsing failed: $directJsonError');
      
      // Try to extract JSON from markdown code blocks
      try {
        final RegExp codeBlockRegex = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```');
        final Match? codeBlockMatch = codeBlockRegex.firstMatch(textContent);
        
        if (codeBlockMatch != null && codeBlockMatch.groupCount >= 1) {
          final String jsonContent = codeBlockMatch.group(1)!.trim();
          final wordData = json.decode(jsonContent);
          return WordResponse.fromJson(wordData);
        }
      } catch (codeBlockError) {
        debugPrint('Code block JSON parsing failed: $codeBlockError');
      }
      
      // Try to find any JSON object in the text
      try {
        final RegExp jsonObjectRegex = RegExp(r'\{[^{}]*\}');
        final Match? objectMatch = jsonObjectRegex.firstMatch(textContent);
        
        if (objectMatch != null) {
          final String jsonContent = objectMatch.group(0)!;
          final wordData = json.decode(jsonContent);
          return WordResponse.fromJson(wordData);
        }
      } catch (jsonObjectError) {
        debugPrint('JSON object extraction failed: $jsonObjectError');
      }
      
      // Last resort: manually extract fields using regex
      debugPrint('Falling back to regex extraction for text: $textContent');
      
      final String definition = _extractField(textContent, 'definition') ?? 
                               'No definition available for $originalWord';
                               
      final String useContext = _extractField(textContent, 'use_context') ?? 
                               _extractField(textContent, 'usage') ?? 
                               'Used in various contexts';
                               
      final String example = _extractField(textContent, 'example') ?? 
                            'No example available';
                            
      final String category = _extractField(textContent, 'suggested_category') ?? 
                             _extractField(textContent, 'category') ?? 
                             'General';
      
      return WordResponse(
        definition: definition,
        useContext: useContext,
        example: example,
        suggestedCategory: category,
      );
    }
  }
  
  // Helper method to extract fields from text using regex
  String? _extractField(String text, String fieldName) {
    final RegExp fieldRegex = RegExp(
      '[\'"]*$fieldName[\'"]*\\s*[:=]\\s*[\'"](.+?)[\'"]', 
      caseSensitive: false
    );
    
    final Match? match = fieldRegex.firstMatch(text);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)?.trim();
    }
    
    // Try alternative format
    final RegExp altRegex = RegExp(
      '$fieldName:\\s*(.+?)(?:\\n|)',
      caseSensitive: false
    );
    
    final Match? altMatch = altRegex.firstMatch(text);
    if (altMatch != null && altMatch.groupCount >= 1) {
      return altMatch.group(1)?.trim();
    }
    
    return null;
  }
}