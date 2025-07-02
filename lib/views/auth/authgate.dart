import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wordivate/core/services/firebaseService.dart';
import 'package:wordivate/providers/storageServiceProvider.dart';
import 'package:wordivate/views/auth/login.dart';
import 'package:wordivate/views/auth/register.dart';
import 'package:wordivate/views/splash/splash_screen.dart';

enum AuthScreen {
  login,
  register,
}

class AuthGate extends ConsumerStatefulWidget {
  final Widget Function(User user) authenticatedBuilder;
  
  const AuthGate({
    Key? key,
    required this.authenticatedBuilder,
  }) : super(key: key);

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  final FirebaseService _firebaseService = FirebaseService();
  AuthScreen _currentScreen = AuthScreen.login;
  bool _checkingFirstLaunch = true;
  bool _isFirstLaunch = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final storageService = ref.read(storageServiceProvider);
    final isFirst = await storageService.isFirstLaunch();
    
    setState(() {
      _isFirstLaunch = isFirst;
      _checkingFirstLaunch = false;
    });
    
    // If it's first launch, mark it as launched for next time
    if (isFirst) {
      await storageService.markAppAsLaunched();
    }
  }

  void _toggleScreen() {
    setState(() {
      _currentScreen = _currentScreen == AuthScreen.login 
          ? AuthScreen.register 
          : AuthScreen.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking first launch status
    if (_checkingFirstLaunch) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // If it's the first launch, show the splash/onboarding screen
    if (_isFirstLaunch) {
      return SplashScreen(
        nextRoute: '/auth',
        // When onboarding is complete, set this to false to proceed to auth
        onComplete: () {
          setState(() {
            _isFirstLaunch = false;
          });
        },
      );
    }

    // Regular auth flow
    return StreamBuilder<User?>(
      stream: _firebaseService.userStream,
      builder: (context, snapshot) {
        // Show a loading indicator while waiting for the auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // User is logged in
        if (snapshot.hasData && snapshot.data != null) {
          return widget.authenticatedBuilder(snapshot.data!);
        }
        
        // User is not logged in, show the appropriate auth screen
        return _currentScreen == AuthScreen.login
            ? LoginPage(onRegisterClick: _toggleScreen)
            : RegisterPage(onLoginClick: _toggleScreen);
      },
    );
  }
}
