import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wordivate/core/constants/app_colors.dart';
import 'package:wordivate/core/constants/apptheme.dart';
import 'package:wordivate/providers/theme_provider.dart';
import 'package:wordivate/core/constants/text_styles.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final currentTheme = themeState.themeMode;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: context.titleLarge),
        elevation: 0,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Appearance',
              style: context.headingSmall,
            ),
          ),
          
          // Theme options
          _buildThemeOption(
            context, 
            ref,
            title: 'Light', 
            subtitle: 'Standard light theme',
            icon: Icons.light_mode,
            value: AppTheme.light, 
            groupValue: currentTheme,
          ),
          
          _buildThemeOption(
            context, 
            ref,
            title: 'Dark', 
            subtitle: 'Standard dark theme',
            icon: Icons.dark_mode,
            value: AppTheme.dark, 
            groupValue: currentTheme,
          ),
          
          _buildThemeOption(
            context, 
            ref,
            title: 'AMOLED Dark', 
            subtitle: 'True black for OLED screens',
            icon: Icons.nightlight_round,
            value: AppTheme.amoled, 
            groupValue: currentTheme,
          ),
          
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Accent Colors',
              style: context.headingSmall,
            ),
          ),
          
          // Color options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildColorOption(context, ref, 'Default', Colors.black, AppTheme.light, currentTheme),
                _buildColorOption(context, ref, 'Blue', Colors.blue, AppTheme.blue, currentTheme),
                _buildColorOption(context, ref, 'Green', Colors.green, AppTheme.green, currentTheme),
                _buildColorOption(context, ref, 'Red', Colors.red, AppTheme.red, currentTheme),
                _buildColorOption(context, ref, 'Purple', Colors.purple, AppTheme.purple, currentTheme),
                _buildColorOption(context, ref, 'Orange', Colors.orange, AppTheme.orange, currentTheme),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // About section
          const Divider(),
          ListTile(
            leading: Icon(Icons.info_outline, color: context.iconColor),
            title: Text('About Wordivate', style: context.titleMedium),
            subtitle: Text('Version 1.0.0', style: context.bodySmall),
            onTap: () {
              // Show about dialog
              showAboutDialog(
                context: context,
                applicationName: 'Wordivate',
                applicationVersion: '1.0.0',
                applicationIcon: const FlutterLogo(size: 48),
                applicationLegalese: '© 2024 Wordivate',
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildThemeOption(
    BuildContext context, 
    WidgetRef ref, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required String groupValue,
  }) {
    return RadioListTile<String>(
      title: Text(title, style: context.titleMedium),
      subtitle: Text(subtitle, style: context.bodySmall),
      secondary: Icon(icon, color: context.iconColor),
      value: value,
      groupValue: groupValue,
      onChanged: (newValue) {
        if (newValue != null) {
          ref.read(themeProvider.notifier).setTheme(newValue);
        }
      },
    );
  }
  
  Widget _buildColorOption(
    BuildContext context, 
    WidgetRef ref,
    String label, 
    Color color, 
    String themeName,
    String currentTheme,
  ) {
    final isSelected = themeName == currentTheme;
    
    return GestureDetector(
      onTap: () {
        ref.read(themeProvider.notifier).setTheme(themeName);
      },
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? Icon(Icons.check, color: context.colorScheme.surface)
                : null,
          ),
          const SizedBox(height: 8),
          Text(label, style: context.bodyMedium),
        ],
      ),
    );
  }
}