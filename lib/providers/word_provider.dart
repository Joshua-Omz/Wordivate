import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wordivate/core/services/api_service.dart';
import 'package:wordivate/models/word_model.dart';
import 'package:wordivate/models/wordrespons.dart';
import 'package:wordivate/core/services/storage_service.dart';
import 'package:wordivate/providers/storageServiceProvider.dart';
import 'dart:convert';

// Define our state class
class WordsState {
  final List<Word> words;
  final List<Word> favoriteWords;
  final Word? currentWord;
  final bool isLoading;
  final String? error;

  const WordsState({
    this.words = const [],
    this.favoriteWords = const [],
    this.currentWord,
    this.isLoading = false,
    this.error,
  });
  
  // Factory method to create initial state
  static WordsState initial() {
    return const WordsState();
  }

  // Create a copy of the state with new values
  WordsState copyWith({
    List<Word>? words,
    List<Word>? favoriteWords,
    Word? currentWord,
    bool? isLoading,
    String? error,
  }) {
    return WordsState(
      words: words ?? this.words,
      favoriteWords: favoriteWords ?? this.favoriteWords,
      currentWord: currentWord ?? this.currentWord,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}


// Manual API service provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Example for WordProvider
final wordsProvider = StateNotifierProvider<WordsNotifier, WordsState>((ref) {
  return WordsNotifier(ref)..loadWords();
});

class WordsNotifier extends StateNotifier<WordsState> {
  final Ref _ref;
  late StorageService _storage;
  
  
  WordsNotifier(this._ref) : super(WordsState.initial()) {
    _storage = _ref.read(storageServiceProvider);
  }

  Future<WordResponse> processWordFromInput(String word) async {
    // Set loading state
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Get the API service and fetch the definition
      final apiService = _ref.read(apiServiceProvider);
      final wordResponse = await apiService.getDefinition(word);
      
      // Update state with success
      state = state.copyWith(isLoading: false);
      
      // Return the word response
      return wordResponse;
    } catch (e) {
      // Update state with error
      state = state.copyWith(
        isLoading: false, 
        error: 'Failed to get definition: ${e.toString()}'
      );
      
      // Re-throw to allow the UI to handle the error
      rethrow;
    }
  }
  // Update a word's category
void updateWordCategory(String wordId, String newCategory) {
  final updatedWords = [...state.words];
  final wordIndex = updatedWords.indexWhere((w) => w.id == wordId);
  
  if (wordIndex != -1) {
    updatedWords[wordIndex] = updatedWords[wordIndex].copyWith(
      category: newCategory,
    );
    
    state = state.copyWith(
      words: updatedWords,
    );
    saveWords();
  }
}
// Save a word from text and response
Future<void> saveWord([String? text, WordResponse? response, String? customCategory]) async {
  if (text == null || response == null) return;
  
  // Create a new Word object
  final newWord = Word(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    text: text,
    definitions: [response.definition],
    examples: response.example.isNotEmpty ? [response.example] : [],
    category: customCategory ?? response.suggestedCategory ?? 'General',
    timestamp: DateTime.now(),
  );
  
  // Add to state
  state = state.copyWith(words: [...state.words, newWord]);
  await saveWords();
}

// Delete a word by ID
void deleteWord(String wordId) {
  final updatedWords = state.words.where((word) => word.id != wordId).toList();
  state = state.copyWith(words: updatedWords);
  saveWords();
}

// Get all unique categories from words
List<String> getAllCategories() {
  final Set<String> categories = {};
  for (final word in state.words) {
    if (word.category.isNotEmpty) {
      categories.add(word.category);
    }
  }
  return categories.toList()..sort();
}
  // Toggle favorite status of a word
  void toggleFavorite(String wordId) {
    final updatedWords = [...state.words];
    final wordIndex = updatedWords.indexWhere((w) => w.id == wordId);
    
    if (wordIndex != -1) {
      // Toggle the isFavorite status
      updatedWords[wordIndex] = updatedWords[wordIndex].copyWith(
        isFavorite: !updatedWords[wordIndex].isFavorite,
      );
      
      // Update favorite words list
      final updatedFavorites = updatedWords
          .where((word) => word.isFavorite)
          .toList();
      
      state = state.copyWith(
        words: updatedWords,
        favoriteWords: updatedFavorites,
      );
      
      // Persist changes
      saveWords();
    }
  }
  Future<void> loadWords() async {
    print('📚 Loading words from storage');
    if (!_storage.isInitialized) await _storage.initialize();
    
    final wordsJson = _storage.read('saved_words');
    if (wordsJson != null && wordsJson is String && wordsJson.isNotEmpty) {
      try {
        final List<dynamic> decodedList = jsonDecode(wordsJson);
        final words = decodedList.map((json) => Word.fromJson(json)).toList();
        state = state.copyWith(words: words);
        print('📚 Loaded ${words.length} words from storage');
      } catch (e) {
        print('⚠️ Error parsing saved words: $e');
      }
    } else {
      print('📚 No saved words found in storage');
    }
  }
  
  // Update saveWords method to persist changes
  Future<void> saveWords() async {
    try {
      final wordsJson = jsonEncode(state.words.map((w) => w.toJson()).toList());
      await _storage.saveString('saved_words', wordsJson);
      print('💾 Saved ${state.words.length} words to storage');
    } catch (e) {
      print('⚠️ Error saving words: $e');
    }
  }
  
  // Make sure all methods that modify words call saveWords()
  void addWord(Word word) {
    state = state.copyWith(words: [...state.words, word]);
    saveWords(); // Persist after every change
  }
  
  // Same for other methods that modify state
}

// Provide easy access to filtered words
final wordsByCategoryProvider = Provider.family<List<Word>, String>((
  ref,
  category,
) {
  final words = ref.watch(wordsProvider).words;
  if (category.isEmpty) return words;
  return words.where((word) => word.category == category).toList();
});

// Provide search functionality
final searchResultsProvider = Provider.family<List<Word>, String>((ref, query) {
  final words = ref.watch(wordsProvider).words;
  if (query.isEmpty) return words;

  final lowercaseQuery = query.toLowerCase();
  return words
      .where(
        (word) =>
            word.text.toLowerCase().contains(lowercaseQuery) ||
            word.category.toLowerCase().contains(lowercaseQuery) ||
            word.definitions.any(
              (def) => def.toLowerCase().contains(lowercaseQuery),
            ),
      )
      .toList();
});

// Remove the duplicate WordListState class, WordListNotifier class and wordListProvider
// that were added at the end of this file, since they already exist in wordlistprovider.dart
