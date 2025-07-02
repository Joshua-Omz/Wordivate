import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wordivate/core/constants/app_colors.dart';
import 'package:wordivate/providers/word_provider.dart';
import 'package:wordivate/providers/wordlistprovider.dart';
import 'package:wordivate/views/components/word_card.dart';
import 'package:wordivate/models/wordrespons.dart';

// Renamed class to follow Flutter naming conventions
class WordListScreen extends ConsumerStatefulWidget {
  final String category;
  final Function(String) onFavoriteToggle;
  final Function(String) onDelete;

  const WordListScreen({
    super.key,
    required this.category,
    required this.onFavoriteToggle,
    required this.onDelete,
  });

  @override
  ConsumerState<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends ConsumerState<WordListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.category.isNotEmpty && widget.category != 'all') {
        ref.read(wordListProvider.notifier).setFilter(widget.category);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wordListState = ref.watch(wordListProvider);
    final notifier = ref.read(wordListProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(wordListState, notifier),
      body: wordListState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : wordListState.filteredWords.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () async => notifier.refreshList(),
                  child: _buildWordList(wordListState, notifier),
                ),
      floatingActionButton: !wordListState.isSelectionMode
          ? FloatingActionButton(
              onPressed: () => _showAddWordDialog(context),
              backgroundColor: AppColors.primary,
              elevation: 4,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  AppBar _buildAppBar(WordListState wordListState, WordListNotifier notifier) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: AppColors.textPrimary,
      title: _isSearchMode
          ? _buildSearchField()
          : const Text(
              'Words',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
      actions: _buildAppBarActions(wordListState, notifier),
      bottom: _isSearchMode
          ? null
          : _buildTabBar(notifier),
    );
  }

  List<Widget> _buildAppBarActions(WordListState wordListState, WordListNotifier notifier) {
    if (wordListState.isSelectionMode) {
      return [
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${wordListState.selectedWordIds.length} selected',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.error),
          tooltip: 'Delete selected',
          onPressed: () {
            _showDeleteConfirmDialog(
              context, 
              wordListState.selectedWordIds.length,
              notifier,
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancel selection',
          onPressed: () => notifier.toggleSelectionMode(),
        ),
      ];
    } else {
      return [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh list',
          onPressed: () => _handleRefresh(notifier),
        ),
        IconButton(
          icon: Icon(_isSearchMode ? Icons.close : Icons.search),
          tooltip: _isSearchMode ? 'Cancel search' : 'Search words',
          onPressed: () {
            setState(() {
              _isSearchMode = !_isSearchMode;
              if (!_isSearchMode) {
                _searchController.clear();
                notifier.refreshList();
              }
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.select_all_outlined),
          tooltip: 'Select multiple',
          onPressed: () => notifier.toggleSelectionMode(),
        ),
      ];
    }
  }

  TabBar _buildTabBar(WordListNotifier notifier) {
    return TabBar(
      controller: _tabController,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.primary,
      indicatorWeight: 3,
      indicatorSize: TabBarIndicatorSize.label,
      tabs: [
        _buildTab(Icons.format_list_bulleted, 'All'),
        _buildTab(Icons.favorite, 'Favorites'),
        _buildTab(Icons.history, 'Recent'),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            notifier.setFilter('all');
            break;
          case 1:
            notifier.setFilter('favorites');
            break;
          case 2:
            notifier.setFilter('recent');
            break;
        }
      },
    );
  }

  Widget _buildTab(IconData icon, String text) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(text, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search your words...',
        hintStyle: TextStyle(color: AppColors.textLight),
        border: InputBorder.none,
        prefixIcon: Icon(Icons.search, color: AppColors.textLight),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: AppColors.textLight),
                onPressed: () {
                  _searchController.clear();
                  ref.read(wordListProvider.notifier).refreshList();
                },
              )
            : null,
      ),
      style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
      onChanged: (query) {
        if (query.isNotEmpty) {
          ref.read(wordListProvider.notifier).searchWords(query);
        } else {
          ref.read(wordListProvider.notifier).refreshList();
        }
      },
    );
  }

  Widget _buildEmptyState() {
    final currentFilter = ref.read(wordListProvider).filter;
    String message;
    IconData icon;
    
    switch (currentFilter) {
      case 'favorites':
        message = "You haven't favorited any words yet";
        icon = Icons.favorite_border;
        break;
      case 'recent':
        message = "No recent words found";
        icon = Icons.history;
        break;
      default:
        message = "Your word collection is empty";
        icon = Icons.menu_book;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _showAddWordDialog(context),
            icon: const Icon(Icons.add),
            label: const Text("Add Your First Word"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordList(WordListState wordListState, WordListNotifier notifier) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: ListView.builder(
        key: ValueKey<String>(wordListState.filter),
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 80, top: 8),
        itemCount: wordListState.filteredWords.length,
        itemBuilder: (context, index) {
          final word = wordListState.filteredWords[index];
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: 1.0,
            curve: Curves.easeInOut,
            child: WordCard(
              word: word,
              isSelected: wordListState.isSelectionMode &&
                  wordListState.selectedWordIds.contains(word.id),
              onTap: () {
                if (wordListState.isSelectionMode) {
                  notifier.toggleWordSelection(word.id);
                } else {
                  // Navigate to word details or toggle expand
                }
              },
              onFavoriteToggle: widget.onFavoriteToggle,
              onDelete: wordListState.isSelectionMode
                  ? null // Disable individual delete in selection mode
                  : widget.onDelete,
            ),
          );
        },
      ),
    );
  }

  void _handleRefresh(WordListNotifier notifier) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Refreshing word list..."),
        duration: Duration(seconds: 1),
      ),
    );
    
    try {
      notifier.refreshList();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Word list refreshed'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error refreshing: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmDialog(
    BuildContext context, 
    int count,
    WordListNotifier notifier
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.amber),
            const SizedBox(width: 12),
            Text('Delete $count Words'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete $count words? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('DELETE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              notifier.deleteSelectedWords();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAddWordDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String text = '';
    String definition = '';
    String pronunciation = '';
    String example = '';
    String category = '';
    String difficulty = 'beginner';
    
    // Get categories for dropdown
    final categories = ref.read(wordsProvider.notifier).getAllCategories();
    if (!categories.contains('General')) {
      categories.add('General');
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Word'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormField(
                  labelText: 'Word *',
                  hintText: 'Enter the word',
                  prefixIcon: Icons.text_fields,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the word';
                    }
                    return null;
                  },
                  onChanged: (value) => text = value,
                  textCapitalization: TextCapitalization.words,
                ),
                
                const SizedBox(height: 16),
                
                _buildFormField(
                  labelText: 'Pronunciation',
                  hintText: 'How to pronounce it',
                  prefixIcon: Icons.record_voice_over,
                  onChanged: (value) => pronunciation = value,
                ),
                
                const SizedBox(height: 16),
                
                _buildFormField(
                  labelText: 'Definition *',
                  hintText: 'Enter the definition',
                  prefixIcon: Icons.description,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a definition';
                    }
                    return null;
                  },
                  maxLines: 3,
                  onChanged: (value) => definition = value,
                ),
                
                const SizedBox(height: 16),
                
                _buildFormField(
                  labelText: 'Example',
                  hintText: 'Example sentence using the word',
                  prefixIcon: Icons.format_quote,
                  maxLines: 2,
                  onChanged: (value) => example = value,
                ),
                
                const SizedBox(height: 16),
                
                // Category dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                  ),
                  hint: const Text('Select a category'),
                  value: categories.contains('General') ? 'General' : null,
                  items: categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      category = value;
                    }
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Difficulty dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Difficulty',
                    prefixIcon: Icon(Icons.signal_cellular_alt),
                  ),
                  value: difficulty,
                  items: const [
                    DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                    DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
                    DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      difficulty = value;
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                try {
                  ref.read(wordListProvider.notifier).addNewWord(
                    text: text,
                    definition: definition,
                    pronunciation: pronunciation,
                    example: example,
                    category: category.isEmpty ? 'General' : category,
                    difficulty: difficulty,
                  );
                  
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("'$text' has been added to your collection"),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error adding word: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    int? maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        alignLabelWithHint: maxLines != null && maxLines > 1,
      ),
      validator: validator,
      maxLines: maxLines,
      onChanged: onChanged,
      textCapitalization: textCapitalization,
    );
  }
}