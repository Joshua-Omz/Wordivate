import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wordivate/screens/branding_screen.dart';
import 'package:wordivate/views/auth/authgate.dart';

import 'package:wordivate/views/home/chatscreen.dart';

class AppStartup extends StatelessWidget {
  const AppStartup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Always show branding screen first, then go to AuthGate
    // AuthGate will handle all routing logic (first time, authentication, etc.)
    return BrandingScreen(
      nextScreen: AuthGate(
        // The AuthGate will determine what to show based on authentication status
        authenticatedBuilder: (user) {
          // This is what shows when user is authenticated
          return const ChatScreen();
        },
      ),
    );
  }
}