// lib/views/categories/category_wordlist_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wordivate/core/constants/app_colors.dart';
import 'package:wordivate/models/categorymodel.dart';
import 'package:wordivate/models/word_model.dart';
import 'package:wordivate/providers/word_provider.dart';
import 'package:wordivate/providers/categoryprovider.dart';
import 'package:wordivate/views/components/word_card.dart';
import 'package:wordivate/views/categories/availablewordsScreen.dart';
import 'package:wordivate/core/constants/text_styles.dart';

class CategoryWordlistScreen extends ConsumerStatefulWidget {
  final String categoryName;
  final Color categoryColor;
  final IconData categoryIcon;

  const CategoryWordlistScreen({
    Key? key,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryIcon,
  }) : super(key: key);

  @override
  ConsumerState<CategoryWordlistScreen> createState() =>
      _CategoryWordlistScreenState();
}

class _CategoryWordlistScreenState
    extends ConsumerState<CategoryWordlistScreen> {
  final ScrollController _scrollController = ScrollController();
  late TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get words for this specific category
    final allWords = ref.watch(wordsProvider).words;
    List<Word> categoryWords =
        allWords
            .where(
              (word) =>
                  word.category.toLowerCase() == 
                  widget.categoryName.toLowerCase(),
            )
            .toList();

    // Apply search filter if needed
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      categoryWords =
          categoryWords
              .where(
                (word) =>
                    word.text.toLowerCase().contains(query) ||
                    word.definitions.any(
                      (def) => def.toLowerCase().contains(query),
                    ),
              )
              .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.categoryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.categoryIcon,
                color: widget.categoryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.categoryName,
              style: context.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          // Add refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh list',
            onPressed: () {
              setState(() {
                // This will trigger a rebuild to show the latest data
              });
              ref.refresh(categoriesWithCountProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _CategorySearchDelegate(
                  categoryWords: categoryWords,
                  onWordSelected: _navigateToWordDetail,
                  categoryColor: widget.categoryColor,
                ),
              );
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: context.colorScheme.onSurface,
      ),
      body:
          categoryWords.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: categoryWords.length,
                itemBuilder: (context, index) {
                  final word = categoryWords[index];
                  return WordCard(
                    word: word,
                    onFavoriteToggle:
                        (id) =>
                            ref.read(wordsProvider.notifier).toggleFavorite(id),
                    onDelete: (id) {
                      ref.read(wordsProvider.notifier).deleteWord(id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${word.text} removed'),
                          action: SnackBarAction(
                            label: 'UNDO',
                            onPressed: () {
                              // Implement undo logic if needed
                            },
                          ),
                        ),
                      );
                    },
                    onCategoryChange: (id, newCategory) {
                      ref
                          .read(wordsProvider.notifier)
                          .updateWordCategory(id, newCategory);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Moved to $newCategory')),
                      );
                    },
                  );
                },
              ),
    );
  }

  void _navigateToWordDetail(Word word) {
    // Implement navigation to word detail view if needed
  }
  void _navigateToAddWords() {
  // Get all words that aren't i  n this category
  final allWords = ref.read(wordsProvider).words;
  final otherWords = allWords.where(
    (word) => word.category.toLowerCase() != widget.categoryName.toLowerCase()
  ).toList();
  
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AvailableWordsScreen(
        categoryName: widget.categoryName,
        categoryColor: widget.categoryColor,
        categoryIcon: widget.categoryIcon,
        availableWords: otherWords,
      ),
    ),
  ).then((_) {
    // Refresh the word list when returning from the available words screen
    setState(() {
      // This will trigger a rebuild to show the latest data
    });
    
    // Refresh the category count provider
    ref.refresh(categoriesWithCountProvider);
  });
}

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.categoryIcon,
            size: 80,
            color: widget.categoryColor.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No words in ${widget.categoryName}',
            style: context.emptyStateTitle,
          ),
          const SizedBox(height: 12),
          Text(
            'Words from this category will appear here',
            style: context.emptyStateSubtitle,
          ),
          const SizedBox(height: 24),
       
                     ElevatedButton.icon(
              icon: const Icon(Icons.playlist_add),
              label: const Text('Add from Existing Words'),
              onPressed: _navigateToAddWords,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colorScheme.surface,
                foregroundColor: widget.categoryColor,
                side: BorderSide(color: widget.categoryColor),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Custom search delegate for category words
class _CategorySearchDelegate extends SearchDelegate<Word?> {
  final List<Word> categoryWords;
  final Function(Word) onWordSelected;
  final Color categoryColor;

  _CategorySearchDelegate({
    required this.categoryWords,
    required this.onWordSelected,
    required this.categoryColor,
  });

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: theme.iconTheme,
        titleTextStyle: theme.textTheme.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showResults(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return Center(
        child: Text(
          'Type to search words',
          style: TextStyle(color: AppColors.textLight),
        ),
      );
    }

    final filteredWords =
        categoryWords.where((word) {
          final queryLower = query.toLowerCase();
          return word.text.toLowerCase().contains(queryLower) ||
              word.definitions.any(
                (def) => def.toLowerCase().contains(queryLower),
              );
        }).toList();

    if (filteredWords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textLight),
            const SizedBox(height: 16),
            Text(
              'No matching words found',
              style: TextStyle(color: AppColors.textLight),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredWords.length,
      itemBuilder: (context, index) {
        final word = filteredWords[index];
        return ListTile(
          title: Text(
            word.text,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            word.definitions.first,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: CircleAvatar(
            backgroundColor: categoryColor.withOpacity(0.2),
            child: Text(
              word.text.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: categoryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onTap: () {
            close(context, word);
            onWordSelected(word);
          },
        );
      },
    );
  }
}
