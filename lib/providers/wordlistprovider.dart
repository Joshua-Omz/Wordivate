// lib/providers/wordlistprovider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wordivate/models/word_model.dart';
import 'package:wordivate/providers/word_provider.dart';
import 'package:wordivate/models/wordrespons.dart';

// Define our state class for word list
class WordListState {
  final List<Word> filteredWords;
  final String filter;
  final bool isSelectionMode;
  final Set<String> selectedWordIds;
  final bool isLoading;
  final String? error;

  const WordListState({
    this.filteredWords = const [],
    this.filter = 'all',
    this.isSelectionMode = false,
    this.selectedWordIds = const {},
    this.isLoading = false,
    this.error,
  });

  // Create a copy of the state with new values
  WordListState copyWith({
    List<Word>? filteredWords,
    String? filter,
    bool? isSelectionMode,
    Set<String>? selectedWordIds,
    bool? isLoading,
    String? error,
  }) {
    return WordListState(
      filteredWords: filteredWords ?? this.filteredWords,
      filter: filter ?? this.filter,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedWordIds: selectedWordIds ?? this.selectedWordIds,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// State notifier for word list
class WordListNotifier extends StateNotifier<WordListState> {
  final Ref _ref;

  WordListNotifier(this._ref) : super(const WordListState()) {
    // Initialize with all words
    _applyFilter('all');
  }

  // Apply filter and update state
  void setFilter(String filter) {
    state = state.copyWith(isLoading: true);
    _applyFilter(filter);
  }
  
  // Get all categories from the words provider
  List<String> getAllCategories() {
    final wordsNotifier = _ref.read(wordsProvider.notifier);
    return wordsNotifier.getAllCategories();
  }

  // Save a word using the wordsProvider
  Future<void> saveWord(String text, WordResponse response, {String? customCategory}) async {
    final wordsNotifier = _ref.read(wordsProvider.notifier);
    await wordsNotifier.saveWord();
    refreshList();
  }

  void _applyFilter(String filter) {
    // Get all words from the main words provider
    final allWords = _ref.read(wordsProvider).words;
    List<Word> filtered;
    
    switch (filter) {
      case 'favorites':
        filtered = allWords.where((word) => word.isFavorite).toList();
        break;
      case 'recent':
        // Sort by timestamp (newest first)
        filtered = List.from(allWords)
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        // Take the most recent words (optional, can adjust or remove limit)
        if (filtered.length > 20) {
          filtered = filtered.sublist(0, 20);
        }
        break;
      case 'all':
        filtered = allWords;
        break;
      default:
        // If filter is a category name
        filtered = allWords.where((word) => word.category == filter).toList();
        break;
    }
    
    state = state.copyWith(
      filteredWords: filtered,
      filter: filter,
      isLoading: false,
    );
  }

  // Toggle selection mode
  void toggleSelectionMode() {
    state = state.copyWith(
      isSelectionMode: !state.isSelectionMode,
      selectedWordIds: {}, // Clear selections when toggling
    );
  }

  // Select/deselect a word
  void toggleWordSelection(String wordId) {
    final selectedIds = Set<String>.from(state.selectedWordIds);
    
    if (selectedIds.contains(wordId)) {
      selectedIds.remove(wordId);
    } else {
      selectedIds.add(wordId);
    }
    
    state = state.copyWith(selectedWordIds: selectedIds);
  }

  // Add a new word manually
  void addNewWord({
    required String text,
    required String definition,
    String pronunciation = '',
    String example = '',
    String category = '',
    String difficulty = 'beginner',
  }) {
    if (text.isEmpty || definition.isEmpty) return;
    
    // Get the wordsNotifier to add the word to the main repository
    final wordsNotifier = _ref.read(wordsProvider.notifier);
    
    // Create the word response
    final wordResponse = WordResponse(
      definition: definition,
      useContext: '',
      example: example,
      suggestedCategory: category,
    );
    
    // Save the word using the main provider
    wordsNotifier.saveWord();
    
    // Refresh the list to show the new word
    refreshList();
  }

  // Delete selected words
  void deleteSelectedWords() {
    final wordsNotifier = _ref.read(wordsProvider.notifier);
    
    // Delete each selected word
    for (final wordId in state.selectedWordIds) {
      wordsNotifier.deleteWord(wordId);
    }
    
    // Reset selection mode and refresh list
    state = state.copyWith(
      isSelectionMode: false,
      selectedWordIds: {},
    );
    
    // Refresh the filtered list
    _applyFilter(state.filter);
  }

  // Select all visible words
  void selectAll() {
    final allVisibleWordIds = state.filteredWords.map((word) => word.id).toSet();
    state = state.copyWith(selectedWordIds: allVisibleWordIds);
  }

  // Deselect all words
  void deselectAll() {
    state = state.copyWith(selectedWordIds: {});
  }

  // Refresh the word list (useful after external changes)
  void refreshList() {
    _applyFilter(state.filter);
  }

  // Search functionality
  void searchWords(String query) {
    if (query.isEmpty) {
      // If query is empty, just apply the current filter
      _applyFilter(state.filter);
      return;
    }
    
    // Get all words and then filter by search query
    final allWords = _ref.read(wordsProvider).words;
    final lowercaseQuery = query.toLowerCase();
    
    final searchResults = allWords.where((word) => 
      word.text.toLowerCase().contains(lowercaseQuery) ||
      word.category.toLowerCase().contains(lowercaseQuery) ||
      word.definitions.any((def) => def.toLowerCase().contains(lowercaseQuery)) ||
      word.examples.any((ex) => ex.toLowerCase().contains(lowercaseQuery))
    ).toList();
    
    // Update state with search results
    state = state.copyWith(
      filteredWords: searchResults,
      isLoading: false,
    );
  }
}

// Provider for word list state
final wordListProvider = StateNotifierProvider<WordListNotifier, WordListState>((ref) {
  return WordListNotifier(ref);
});