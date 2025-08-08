import 'package:flutter/material.dart';
import 'dart:async';

class BrandingScreen extends StatefulWidget {
  final Widget nextScreen;
  
  const BrandingScreen({Key? key, required this.nextScreen}) : super(key: key);

  @override
  State<BrandingScreen> createState() => _BrandingScreenState();
}

class _BrandingScreenState extends State<BrandingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Set up the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    // Create a fade-in animation
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    
    // Start the animation
    _controller.forward();
    
    // Navigate to the main app after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => widget.nextScreen),
      );
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/wordivateblack.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 20),
              const Text(
                'absolute',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}