import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wordivate/core/constants/app_colors.dart';
import 'package:wordivate/models/word_model.dart';
import 'package:intl/intl.dart';
import 'package:wordivate/models/wordrespons.dart';
import 'package:wordivate/models/categorymodel.dart';
import 'package:wordivate/providers/categoryprovider.dart';


class WordCard extends ConsumerStatefulWidget {
  final Word word;
  final Function(String) onFavoriteToggle;
  final Function(String)? onDelete;
  final Function()? onTap;
  final bool isExpanded;
  final bool isSelected;
  final Function(String, String)? onCategoryChange;

  const WordCard({
    Key? key,
    required this.word,
    required this.onFavoriteToggle,
    this.onDelete,
    this.onTap,
    this.isExpanded = false,
    this.isSelected = false,
    this.onCategoryChange, 
  }) : super(key: key);

  @override
  ConsumerState<WordCard> createState() => _WordCardState();
}

class _WordCardState extends ConsumerState<WordCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              widget.isSelected
                  ? AppColors.primary
                  : AppColors.divider.withOpacity(0.5),
          width: widget.isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main content (always visible)
            _buildHeader(),

            // Expandable section
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: _buildExpandedContent(),
            ),

            // Date added and actions footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: _toggleExpand,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Word container with difficulty color
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getDifficultyColor(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  widget.word.text.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Word info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.word.text,
                    style: Theme.of(context).textTheme.titleLarge,),
                  if (widget.word.pronunciation.isNotEmpty)
                    Text(
                      widget.word.pronunciation,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.word.category,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Favorite icon
            IconButton(
              icon: Icon(
                widget.word.isFavorite ? Icons.favorite : Icons.favorite_border,
                color:
                    widget.word.isFavorite
                        ? AppColors.favorite
                        : AppColors.textLight,
              ),
              onPressed: () => widget.onFavoriteToggle(widget.word.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),

          // Definitions section
          if (widget.word.definitions.isNotEmpty) ...[
            const Text(
              'Definition',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.word.definitions.map(
              (definition) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '• $definition',
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Examples section
          if (widget.word.examples.isNotEmpty) ...[
            const Text(
              'Examples',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.word.examples.map(
              (example) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '• $example',
                  style: const TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final dateFormat = DateFormat('MMM d, yyyy');
    final formattedDate = dateFormat.format(widget.word.timestamp);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Date added
          Text(
            'Added $formattedDate',
            style: TextStyle(fontSize: 12, color: AppColors.textLight),
          ),
          
          // Action buttons
          Row(
            children: [
              // Category change button
              if (widget.onCategoryChange != null)
                IconButton(
                  icon: Icon(
  Icons.category_outlined, 
  size: 20,
  color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
),
                  color: AppColors.textLight,
                  tooltip: 'Change category',
                  onPressed: () => _showCategoryDialog(context),
                ),
              
              // Delete button (if provided)
              if (widget.onDelete != null)
                IconButton(
                 icon: Icon(
  Icons.category_outlined, 
  size: 20,
  color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
),
                  color: AppColors.textLight,
                  onPressed: () => widget.onDelete!(widget.word.id),
                ),
              
              // Expand/collapse button
              IconButton(
               icon: Icon(
  Icons.category_outlined, 
  size: 20,
  color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
),
                color: AppColors.textLight,
                onPressed: _toggleExpand,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Color _getDifficultyColor() {
    switch (widget.word.difficulty.toLowerCase()) {
      case 'beginner':
        return AppColors.beginner;
      case 'intermediate':
        return AppColors.intermediate;
      case 'advanced':
        return AppColors.advanced;
      default:
        return AppColors.beginner;
    }
  }

  // Add this method to show the category selection dialog
  void _showCategoryDialog(BuildContext context) {
    final categories = ref.read(categoryProvider).categories;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Category'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                leading: Icon(
                  category.icon,
                  color: category.color,
                ),
                title: Text(category.name),
                selected: widget.word.category == category.name,
                onTap: () {
                  Navigator.pop(context);
                  if (widget.onCategoryChange != null) {
                    widget.onCategoryChange!(widget.word.id, category.name);
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }
}
