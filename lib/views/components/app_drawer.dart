import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wordivate/core/constants/app_colors.dart';
import 'package:wordivate/core/constants/apptheme.dart';
import 'package:wordivate/providers/categoryprovider.dart';
import 'package:wordivate/providers/navigation_provider.dart';
import 'package:wordivate/providers/theme_provider.dart';
import 'package:wordivate/providers/word_provider.dart';
import 'package:wordivate/providers/wordlistprovider.dart';
import 'package:wordivate/core/constants/text_styles.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDarkMode = themeState.themeMode == AppTheme.dark;
    final categoriesWithCount = ref.watch(categoriesWithCountProvider);
    final selectedIndex = ref.watch(navigationProvider);
    
    return Drawer(
      child: Column(
        children: [
          _buildDrawerHeader(context, isDarkMode),
          
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavigationTile(
                  context, 
                  'Chat Assistant', 
                  Icons.chat, 
                  0, 
                  selectedIndex, 
                  ref,
                  iconColor: context.primaryIconColor,
                ),
                
                _buildNavigationTile(
                  context, 
                  'All Words', 
                  Icons.menu_book, 
                  1, 
                  selectedIndex, 
                  ref,
                  iconColor: context.primaryIconColor,
                ),
                
                const Divider(),
                
                // Categories section
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Categories',
                        style: context.drawerSectionTitle,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                        onPressed: () {
                          _navigateTo(context, ref, 4);
                        },
                        tooltip: 'Add Category',
                      ),
                    ],
                  ),
                ),
                
                // List of categories
                ...categoriesWithCount.map((item) => _buildCategoryTile(context, ref, item)).toList(),
                
                const Divider(),
                
                // Dark mode toggle
                SwitchListTile(
                  secondary: Icon(
                    isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: isDarkMode ? context.warningIconColor : context.infoIconColor,
                  ),
                  title: Text('Dark Mode', style: context.titleMedium),
                  value: isDarkMode,
                  onChanged: (value) {
                    final newTheme = value ? AppTheme.dark : AppTheme.light;
                    ref.read(themeProvider.notifier).setTheme(newTheme);
                  },
                ),
                
                _buildNavigationTile(
                  context, 
                  'Settings', 
                  Icons.settings, 
                  5, 
                  selectedIndex, 
                  ref,
                  iconColor: context.iconColor,
                ),
                
                _buildAboutTile(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile(
    BuildContext context, 
    String title, 
    IconData icon, 
    int index, 
    int selectedIndex, 
    WidgetRef ref, 
    {Color? iconColor}
  ) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? context.iconColor),
      title: Text(title, style: context.titleMedium),
      selected: selectedIndex == index,
      selectedTileColor: context.colorScheme.primary.withOpacity(0.1),
      onTap: () => _navigateTo(context, ref, index),
    );
  }

  Widget _buildCategoryTile(BuildContext context, WidgetRef ref, Map<String, dynamic> item) {
    final category = item['category'];
    final count = item['count'];
    
    return ListTile(
      leading: Icon(
        category.icon,
        color: category.color,
      ),
      title: Text(category.name, style: context.titleMedium),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$count',
          style: context.captionText,
        ),
      ),
      onTap: () {
        try {
          ref.read(wordListProvider.notifier).setFilter(category.name);
          _navigateTo(context, ref, 1);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error navigating: ${e.toString()}')),
          );
        }
      },
    );
  }

  Widget _buildAboutTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.info_outline, color: context.iconColor),
      title: Text('About', style: context.titleMedium),
      onTap: () {
        Navigator.pop(context);
        showAboutDialog(
          context: context,
          applicationName: 'Wordivate',
          applicationVersion: '1.0.0',
          applicationIcon: const FlutterLogo(size: 48),
          applicationLegalese: '© 2024 Wordivate',
          children: [
            const SizedBox(height: 16),
            const Text(
              'Wordivate helps you expand your vocabulary by providing word definitions, examples, and organizing them into categories.',
              style: TextStyle(height: 1.5),
            ),
          ],
        );
      },
    );
  }

  void _navigateTo(BuildContext context, WidgetRef ref, int index) {
    try {
      ref.read(navigationProvider.notifier).state = index;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigation error: ${e.toString()}')),
      );
    }
  }

  Widget _buildDrawerHeader(BuildContext context, bool isDarkMode) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colorScheme.primary,
            context.colorScheme.primary.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colorScheme.onPrimary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 30,
              color: context.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Wordivate',
            style: context.headingMedium.copyWith(
              color: context.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Expand your vocabulary',
            style: context.bodyMedium.copyWith(
              color: context.colorScheme.onPrimary.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}