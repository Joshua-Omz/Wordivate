import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wordivate/models/word_model.dart';
import 'package:wordivate/models/categorymodel.dart' as models;
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;

  late Box<String> _wordsBox;
  late SharedPreferences _prefs;
  late FlutterSecureStorage _secureStorage;
  bool _isInitialized = false;

  StorageService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;
    
     try {
      // Initialize Hive
      await Hive.initFlutter();
      
      // Open Hive boxes
      _wordsBox = await Hive.openBox('wordivate_data');
      
      // Initialize SharedPreferences
      _prefs = await SharedPreferences.getInstance();
      
      // Initialize FlutterSecureStorage
      _secureStorage = const FlutterSecureStorage();
      
      _isInitialized = true;
      print('🔐 Storage service initialized successfully');
    } catch (e) {
      print('⚠️ Error initializing storage: $e');
    }
  }
  
  bool get isInitialized => _isInitialized;

  // Add proper error handling and logging to read/write methods
  Future<bool> saveString(String key, String value) async {
    if (!_isInitialized) await initialize();
    try {
      await _prefs.setString(key, value);
      print('💾 Saved to storage: $key');
      return true;
    } catch (e) {
      print('⚠️ Error saving $key: $e');
      return false;
    }
  }
  String? getString(String key) {
    if (!_isInitialized) {
      print('⚠️ Storage not initialized when trying to read $key');
      return null;
    }
    try {
      return _prefs.getString(key);
    } catch (e) {
      print('⚠️ Error reading $key from SharedPreferences: $e');
      return null;
    }
  }
  Future<void> saveToBox(String key, dynamic value) async {
    if (!_isInitialized) await initialize();
    try {
      await _wordsBox.put(key, value);
      print('💾 Saved to Hive Box: $key');
    } catch (e) {
      print('⚠️ Error saving $key to Hive Box: $e');
    }
  }

  dynamic getFromBox(String key) {
    if (!_isInitialized) {
      print('⚠️ Storage not initialized when trying to read $key from box');
      return null;
    }
    try {
      return _wordsBox.get(key);
    } catch (e) {
      print('⚠️ Error reading $key from Hive Box: $e');
      return null;
    }
  }

  // Save words to storage
  Future<void> saveWords(List<Word> words) async {
    try {
      // Convert words to JSON string
      final List<Map<String, dynamic>> wordsJson =
          words.map((word) => word.toJson()).toList();
      final String wordsString = json.encode(wordsJson);

      // Save to Hive box
      await _wordsBox.put('words', wordsString);

      debugPrint('Saved ${words.length} words to storage');
    } catch (e) {
      debugPrint('Error saving words: $e');
    }
  }
   Future<List<Word>> loadWords() async {
    if (!_isInitialized) await initialize();
    try {
      // Try Hive first, fall back to SharedPreferences
      String? wordsString = _wordsBox.get('words') as String?;
      
      if (wordsString == null || wordsString.isEmpty) {
        wordsString = _prefs.getString('saved_words');
      }
      
      if (wordsString == null || wordsString.isEmpty) {
        print('📚 No words found in storage');
        return [];
      }
      
      final List<dynamic> wordsJson = json.decode(wordsString);
      final List<Word> words = 
          wordsJson.map((json) => Word.fromJson(json)).toList();
      
      print('📚 Loaded ${words.length} words from storage');
      return words;
    } catch (e) {
      print('⚠️ Error loading words: $e');
      return [];
    }
  }
  // Get categories from storage
  Future<List<models.Category>> getCategories() async {
    try {
      final box = await Hive.openBox('wordivate');
      final categoriesData = box.get('categories');
      
      if (categoriesData == null) {
        return [];
      }
      
      final List<dynamic> decodedData = json.decode(categoriesData);
      return decodedData.map((data) => models.Category.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error loading categories: $e');
      return [];
    }
  }
  
  
  // Save categories to storage
  Future<void> saveCategories(List<models.Category> categories) async {
    try {
      final box = await Hive.openBox('wordivate');
      final encodedData = json.encode(
        categories.map((c) => c.toJson()).toList(),
      );
      await box.put('categories', encodedData);
    } catch (e) {
      debugPrint('Error saving categories: $e');
      throw Exception('Failed to save categories: $e');
    }
  }
 

    // In storage_service.dart
  
  // Check if this is the first launch
  Future<bool> isFirstLaunch() async {
    try {
      // First check in Hive for speed
      final hasLaunched = _wordsBox.get('has_launched_before') == 'true';
      
      if (!hasLaunched) {
        // Double-check secure storage as backup (more secure but slower)
        final secureCheck = await _secureStorage.read(key: 'has_launched_before');
        return secureCheck != 'true';
      }
      
      return !hasLaunched;
    } catch (e) {
      // If there's an error, assume it's the first launch
      debugPrint('Error checking first launch: $e');
      return true;
    }
  }
  //Theme methods
   Future<void> saveTheme(String themeName) async {
    if (!_isInitialized) await initialize();
    try {
      await _wordsBox.put('theme', themeName);
      print('💾 Saved theme preference: $themeName');
    } catch (e) {
      print('⚠️ Error saving theme: $e');
    }
  }

    // Get saved theme
  Future<String?> getTheme() async {
    try {
      final box = await Hive.openBox('wordivate');
      return box.get('theme') as String?;
    } catch (e) {
      debugPrint('Error getting theme: $e');
      return null;
    }
  }
  
  // Save theme

  // Mark the app as launched
  Future<void> markAppAsLaunched() async {
    try {
      // Store in both places for redundancy
      await _wordsBox.put('has_launched_before', 'true');
      await _secureStorage.write(key: 'has_launched_before', value: 'true');
      debugPrint('App marked as launched');
    } catch (e) {
      debugPrint('Error marking app as launched: $e');
    }
  }


  // Generic read method that tries both storage options
  dynamic read(String key) {
    if (!_isInitialized) {
      print('⚠️ Storage not initialized when trying to read $key');
      return null;
    }
    
    try {
      // Try to get from SharedPreferences first
      final prefValue = _prefs.getString(key);
      if (prefValue != null) {
        return prefValue;
      }
      
      // If not in SharedPreferences, try Hive box
      return _wordsBox.get(key);
    } catch (e) {
      print('⚠️ Error reading $key from storage: $e');
      return null;
    }
  }
  // Save API key securely
  Future<void> saveApiKey(String apiKey) async {
    await _secureStorage.write(key: 'gemini_api_key', value: apiKey);
  }

  // Get API key securely
  Future<String?> getApiKey() async {
    return await _secureStorage.read(key: 'gemini_api_key');
  }

  // Clear all stored data (for logout/reset functionality)
  Future<void> clearAllData() async {
    await _wordsBox.clear();
    await _secureStorage.deleteAll();
  }
}
