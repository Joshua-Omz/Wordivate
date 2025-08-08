import 'package:flutter/foundation.dart';

/// A simple logging utility to replace print statements
class AppLogger {
  static const String _prefix = '[Wordivate]';
  
  /// Log an info message
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix INFO: $message');
    }
  }
  
  /// Log a warning message
  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix WARNING: $message');
    }
  }
  
  /// Log an error message
  static void error(String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint('$_prefix ERROR: $message${error != null ? ' - $error' : ''}');
    }
  }
  
  /// Log a debug message
  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix DEBUG: $message');
    }
  }
}