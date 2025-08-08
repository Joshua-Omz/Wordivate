/// Storage keys used throughout the application
class StorageKeys {
  static const String savedWords = 'saved_words';
  static const String firstLaunch = 'first_launch';
  static const String userTheme = 'user_theme';
  static const String userCategories = 'user_categories';
  static const String userProfile = 'user_profile';
  
  // Private constructor to prevent instantiation
  StorageKeys._();
}

/// App-wide constants
class AppConstants {
  static const String appName = 'Wordivate';
  static const String defaultCategory = 'General';
  static const int maxWordsPerCategory = 1000;
  static const int maxDefinitionLength = 500;
  
  // Private constructor to prevent instantiation
  AppConstants._();
}

/// Default categories for the application
class DefaultCategories {
  static const List<String> categories = [
    'General',
    'Academic',
    'Business',
    'Technology',
    'Literature',
    'Science',
    'Arts',
    'Sports',
  ];
  
  // Private constructor to prevent instantiation
  DefaultCategories._();
}