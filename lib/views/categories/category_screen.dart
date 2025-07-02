// lib/views/categories/category_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wordivate/core/constants/app_colors.dart';
import 'package:wordivate/models/categorymodel.dart';
import 'package:wordivate/providers/categoryprovider.dart';
import 'package:wordivate/providers/word_provider.dart';
import 'package:wordivate/views/categories/wordlistscreen.dart';
import 'package:wordivate/views/components/app_drawer.dart';
import 'package:wordivate/core/constants/text_styles.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryProvider);
    final categoriesWithCount = ref.watch(categoriesWithCountProvider);
    
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(
          'Categories',
          style: context.titleLarge,
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
      ),
      body: categoryState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : categoryState.categories.isEmpty
              ? _buildEmptyState()
              : _buildCategoryList(categoriesWithCount),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 80,
            color: context.primaryIconColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Categories Yet',
            style: context.emptyStateTitle,
          ),
          const SizedBox(height: 8),
          Text(
            'Create categories to organize your words',
            style: context.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showAddCategoryDialog(context),
            child: const Text('Create Category'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(List<Map<String, dynamic>> categoriesWithCount) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categoriesWithCount.length,
      itemBuilder: (context, index) {
        final item = categoriesWithCount[index];
        final Category category = item['category'];
        final int count = item['count'];
        
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _navigateToWordList(category.name),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildCategoryIcon(category),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: context.titleMedium,
                        ),
                        Text(
                          '$count words',
                          style: context.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (!category.isDefault)
                    _buildCategoryActions(category),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryIcon(Category category) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: category.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        category.icon,
        color: category.color,
        size: 24,
      ),
    );
  }

  Widget _buildCategoryActions(Category category) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'edit') {
          _showEditCategoryDialog(context, category);
        } else if (value == 'delete') {
          _showDeleteCategoryDialog(context, category);
        }
      },
      itemBuilder: (context) => [
        _buildPopupMenuItem('edit', Icons.edit, 'Edit'),
        _buildPopupMenuItem('delete', Icons.delete, 'Delete'),
      ],
    );
  }

  PopupMenuItem _buildPopupMenuItem(String value, IconData icon, String text) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  void _navigateToWordList(String category) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WordListScreen(
            category: category,
            onFavoriteToggle: (id) => ref.read(wordsProvider.notifier).toggleFavorite(id),
            onDelete: (id) => ref.read(wordsProvider.notifier).deleteWord(id),
          ),
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Error navigating to word list: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    _showCategoryDialog(
      context: context,
      title: 'Create New Category',
      buttonText: 'CREATE',
      onSave: (name, color, icon) {
        try {
          ref.read(categoryProvider.notifier).addCategory(
            name: name,
            color: color,
            icon: icon,
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Category "$name" created successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        } catch (e) {
          _showErrorSnackBar('Error creating category: ${e.toString()}');
        }
      },
    );
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    _showCategoryDialog(
      context: context,
      title: 'Edit Category',
      buttonText: 'SAVE',
      initialName: category.name,
      initialColor: category.color,
      initialIcon: category.icon,
      onSave: (name, color, icon) {
        try {
          ref.read(categoryProvider.notifier).updateCategory(
            category.copyWith(
              name: name,
              color: color,
              icon: icon,
            ),
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Category "$name" updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        } catch (e) {
          _showErrorSnackBar('Error updating category: ${e.toString()}');
        }
      },
    );
  }

  void _showCategoryDialog({
    required BuildContext context,
    required String title,
    required String buttonText,
    required Function(String name, Color color, IconData icon) onSave,
    String initialName = '',
    Color initialColor = Colors.blue,
    IconData initialIcon = Icons.folder,
  }) {
    final TextEditingController nameController = TextEditingController(text: initialName);
    Color selectedColor = initialColor;
    IconData selectedIcon = initialIcon;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                        hintText: 'Enter a name for your category',
                      ),
                      autofocus: initialName.isEmpty,
                    ),
                    const SizedBox(height: 16),
                    const Text('Select Color:'),
                    const SizedBox(height: 8),
                    _buildColorSelector(
                      selectedColor: selectedColor,
                      onColorSelected: (color) {
                        setDialogState(() {
                          selectedColor = color;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Select Icon:'),
                    const SizedBox(height: 8),
                    _buildIconSelector(
                      selectedIcon: selectedIcon,
                      onIconSelected: (icon) {
                        setDialogState(() {
                          selectedIcon = icon;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      onSave(name, selectedColor, selectedIcon);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a category name'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text(buttonText),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteCategoryDialog(BuildContext context, Category category) {
    final categories = ref.read(categoryProvider).categories
        .where((c) => c.id != category.id && c.isDefault == false)
        .toList();
    String? reassignTo = categories.isNotEmpty ? categories[0].name : null;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.amber),
                  SizedBox(width: 8),
                  Text('Delete Category'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Are you sure you want to delete "${category.name}"?'),
                  const SizedBox(height: 16),
                  if (categories.isNotEmpty) ...[
                    const Text('Reassign words to:'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: reassignTo,
                      items: categories.map((c) {
                        return DropdownMenuItem(
                          value: c.name,
                          child: Text(c.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          reassignTo = value;
                        });
                      },
                    ),
                  ] else ...[
                    const Text(
                      'Note: Words in this category will be moved to "General".',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    try {
                      ref.read(categoryProvider.notifier).deleteCategory(
                        category.id,
                        reassignTo: reassignTo ?? 'General',
                      );
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Category "${category.name}" deleted'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      
                      Navigator.pop(context);
                    } catch (e) {
                      _showErrorSnackBar('Error deleting category: ${e.toString()}');
                    }
                  },
                  child: const Text('DELETE'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildColorSelector({
    required Color selectedColor,
    required Function(Color) onColorSelected,
  }) {
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
    ];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((color) {
        return InkWell(
          onTap: () => onColorSelected(color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selectedColor == color ? Colors.white : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                if (selectedColor == color)
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: selectedColor == color
                ? const Icon(Icons.check, color: Colors.white)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIconSelector({
    required IconData selectedIcon,
    required Function(IconData) onIconSelected,
  }) {
    final icons = [
      Icons.folder,
      Icons.school,
      Icons.work,
      Icons.business,
      Icons.computer,
      Icons.science,
      Icons.psychology,
      Icons.sports,
      Icons.music_note,
      Icons.brush,
      Icons.restaurant,
      Icons.local_hospital,
      Icons.directions_car,
      Icons.travel_explore,
      Icons.public,
      Icons.people,
      Icons.sentiment_satisfied,
      Icons.favorite,
      Icons.star,
      Icons.lightbulb,
      Icons.book,
      Icons.celebration,
      Icons.language,
    ];
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: icons.map((icon) {
        final isSelected = selectedIcon.codePoint == icon.codePoint;
        return InkWell(
          onTap: () => onIconSelected(icon),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        );
      }).toList(),
    );
  }
}