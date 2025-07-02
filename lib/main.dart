import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wordivate/core/services/api_service.dart';
import 'package:wordivate/providers/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import local files
import 'package:wordivate/core/constants/app_colors.dart';
import 'package:wordivate/views/categories/wordlistscreen.dart';
import 'package:wordivate/models/wordrespons.dart';
import 'package:wordivate/views/splash/splash_screen.dart';
import 'package:wordivate/views/home/chatscreen.dart';
import 'package:wordivate/providers/word_provider.dart';
import 'package:wordivate/core/services/storage_service.dart';
import 'package:wordivate/views/categories/category_screen.dart';
import 'package:wordivate/views/settings/settings_screen.dart';
import 'package:wordivate/providers/storageServiceProvider.dart';
import 'package:wordivate/views/auth/authgate.dart';
import 'package:wordivate/providers/navigation_provider.dart';
import 'package:wordivate/screens/branding_screen.dart';
import 'package:wordivate/views/auth/authgate.dart';  
import 'package:wordivate/screens/app_startup.dart';
// Remove or use this import:
// import 'package:wordivate/views/main_navigation_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Improved .env loading with debugging
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('🔑 .env file loaded successfully');
    
    // Check if the API key is actually loaded
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('⚠️ WARNING: GEMINI_API_KEY not found in .env file!');
    } else {
      debugPrint('✅ GEMINI_API_KEY found in .env file');
    }
  } catch (e) {
    debugPrint('❌ Error loading .env file: $e');
  }
  
  await Hive.initFlutter();
  final storageService = StorageService();
  await storageService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        // Initialize storage service here so it's available to all providers
        storageServiceProvider.overrideWithValue(await initializeStorage()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<StorageService> initializeStorage() async {
  final storageService = StorageService();
  await storageService.initialize();
  final isFirstLaunch = await storageService.isFirstLaunch();
  print('🚀 App first launch: $isFirstLaunch');
  return storageService;
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the theme provider to rebuild when theme changes
    final themeState = ref.watch(themeProvider);
    
    return MaterialApp(
      title: 'Wordivate',
      // Simply use the themeData from your ThemeState
      theme: themeState.themeData,
      // Show the branding screen first, which will then navigate to your main app screen
      home: const AppStartup(),
    );
  }
}
