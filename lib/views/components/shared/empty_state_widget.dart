import 'package:flutter/material.dart';
import 'package:wordivate/core/constants/app_colors.dart';

/// A reusable empty state widget for displaying when no items are found
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  /// Factory constructor for no words found state
  factory EmptyStateWidget.noWords({
    String? customMessage,
    Widget? action,
  }) {
    return EmptyStateWidget(
      icon: Icons.library_books_outlined,
      title: 'No Words Found',
      message: customMessage ?? 'Start building your vocabulary by adding some words!',
      action: action,
    );
  }

  /// Factory constructor for no search results state
  factory EmptyStateWidget.noSearchResults({
    String? searchQuery,
    Widget? action,
  }) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'No Results Found',
      message: searchQuery != null 
          ? 'No words found for "$searchQuery". Try a different search term.'
          : 'No words match your search criteria.',
      action: action,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.textSecondaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textSecondaryColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondaryColor.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}