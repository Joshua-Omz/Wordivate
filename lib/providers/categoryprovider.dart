// lib/providers/category_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wordivate/models/categorymodel.dart';
import 'package:wordivate/models/word_model.dart';
import 'package:wordivate/providers/word_provider.dart';
import 'package:wordivate/core/services/storage_service.dart';

// State class for categories
class CategoryState {
  final List<Category> categories;
  final bool isLoading;
  final String? error;
  
  const CategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });
  
  CategoryState copyWith({
    List<Category>? categories,
    bool? isLoading,
    String? error,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Notifier for category state
class CategoryNotifier extends StateNotifier<CategoryState> {
  final StorageService _storageService = StorageService();
  final Ref _ref;
  
  CategoryNotifier(this._ref) : super(const CategoryState()) {
    loadCategories();
  }
  
  // Load categories from storage
  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final categories = await _storageService.getCategories();
      
      // If no categories exist, create defaults
      if (categories.isEmpty) {
        await _createDefaultCategories();
      } else {
        state = state.copyWith(categories: categories, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load categories: $e',
      );
    }
  }
  
  // Create default categories
  Future<void> _createDefaultCategories() async {
    final defaults = [
      Category(
        id: 'academic',
        name: 'Academic',
        color: Colors.blue,
        icon: Icons.school,
        isDefault: true,
      ),
      Category(
        id: 'business',
        name: 'Business',
        color: Colors.green,
        icon: Icons.business,
        isDefault: true,
      ),
      Category(
        id: 'technology',
        name: 'Technology',
        color: Colors.purple,
        icon: Icons.computer,
        isDefault: true,
      ),
      Category(
        id: 'everyday',
        name: 'Everyday',
        color: Colors.orange,
        icon: Icons.people,
        isDefault: true,
      ),
    ];
    
    state = state.copyWith(categories: defaults);
    await _saveCategories();
  }
  
  // Save categories to storage
  Future<void> _saveCategories() async {
    try {
      await _storageService.saveCategories(state.categories);
    } catch (e) {
      state = state.copyWith(error: 'Failed to save categories: $e');
    }
  }
  
  // Create a new category
  Future<void> addCategory({
    required String name,
    required Color color,
    required IconData icon,
  }) async {
    // Check if category with this name already exists
    if (state.categories.any((c) => c.name.toLowerCase() == name.toLowerCase())) {
      state = state.copyWith(error: 'A category with this name already exists');
      return;
    }
    
    final newCategory = Category(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      color: color,
      icon: icon,
    );
    
    final updatedCategories = [...state.categories, newCategory];
    state = state.copyWith(categories: updatedCategories);
    await _saveCategories();
  }
  
  // Update an existing category
  Future<void> updateCategory(Category updated) async {
    final index = state.categories.indexWhere((c) => c.id == updated.id);
    
    if (index != -1) {
      final updatedCategories = [...state.categories];
      updatedCategories[index] = updated;
      
      state = state.copyWith(categories: updatedCategories);
      await _saveCategories();
    }
  }
  
  // Delete a category and reassign words
  Future<void> deleteCategory(String categoryId, {String? reassignTo}) async {
    final category = state.categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => throw Exception('Category not found'),
    );
    
    // Don't allow deleting default categories
    if (category.isDefault) {
      state = state.copyWith(error: 'Default categories cannot be deleted');
      return;
    }
    
    // Update words to new category if specified
    if (reassignTo != null) {
      final wordsNotifier = _ref.read(wordsProvider.notifier);
      final words = _ref.read(wordsProvider).words;
      
      for (final word in words) {
        if (word.category == category.name) {
          wordsNotifier.updateWordCategory(word.id, reassignTo);
        }
      }
    }
    
    // Remove the category
    final updatedCategories = state.categories.where((c) => c.id != categoryId).toList();
    state = state.copyWith(categories: updatedCategories);
    await _saveCategories();
  }
  
  // Get word count for each category
  Map<String, int> getCategoryCounts() {
    final words = _ref.read(wordsProvider).words;
    final Map<String, int> counts = {};
    
    // Initialize all categories with 0
    for (final category in state.categories) {
      counts[category.name] = 0;
    }
    
    // Count words in each category
    for (final word in words) {
      final category = word.category;
      if (counts.containsKey(category)) {
        counts[category] = (counts[category] ?? 0) + 1;
      } else {
        // For words with categories not in our list
        counts[category] = 1;
      }
    }
    
    return counts;
  }
}

// Provider for categories
final categoryProvider = StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  return CategoryNotifier(ref);
});

// Provider for getting word counts by category
final categoriesWithCountProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final categories = ref.watch(categoryProvider).categories;
  final counts = ref.read(categoryProvider.notifier).getCategoryCounts();
  
  return categories.map((category) => {
    'category': category,
    'count': counts[category.name] ?? 0,
  }).toList();
});