import 'package:flutter/material.dart';
import 'package:wordivate/core/constants/app_colors.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  final String nextRoute;
  final VoidCallback? onComplete;
  
  const SplashScreen({
    Key? key, 
    this.nextRoute = '/auth',
    this.onComplete,
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // Updated colors for onboarding content
  final List<OnboardingContent> _contents = [
    OnboardingContent(
      title: "Learn New Words",
      description:
          "Expand your vocabulary with our intelligent word learning app",
      icon: Icons.menu_book,
      iconColor: Colors.amber[600]!, // Gold color for icons
    ),
    OnboardingContent(
      title: "Smart Definitions",
      description:
          "Get detailed explanations, usage examples, and proper context for every word",
      icon: Icons.psychology,
      iconColor: Colors.amber[600]!, // Gold color for icons
    ),
    OnboardingContent(
      title: "Organize Your Learning",
      description:
          "Save words in categories and track your vocabulary growth over time",
      icon: Icons.category,
      iconColor: Colors.amber[600]!, // Gold color for icons
    ),
  ];

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (widget.onComplete != null) {
        widget.onComplete!();
      } else {
        Navigator.pushReplacementNamed(context, widget.nextRoute);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define our color scheme
    final Color backgroundColor = Colors.black;
    final Color textColor = Colors.grey[300]!; // Silver color for text
    final Color accentColor = Colors.amber[600]!; // Gold color for accents
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // App Name/Logo at top with silver color
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Text(
                'Wordivate',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),

            // PageView for onboarding content
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _contents.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(_contents[index]);
                },
              ),
            ),

            // Pagination dots
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _contents.length,
                  (index) => _buildDot(index, accentColor),
                ),
              ),
            ),

            // Next or Get Started button with gold accent
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SizedBox(
                width:
                    _currentPage == _contents.length - 1 ? double.infinity : 60,
                height: 50,
                child:
                    _currentPage == _contents.length - 1
                        ? ElevatedButton(
                          onPressed: () {
                            if (widget.onComplete != null) {
                              widget.onComplete!();
                            } else {
                              Navigator.pushReplacementNamed(context, '/home');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Get Started',
                            style: TextStyle(
                              color: backgroundColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        )
                        : FloatingActionButton(
                          onPressed: () {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                          backgroundColor: accentColor,
                          child: Icon(
                            Icons.arrow_forward,
                            color: backgroundColor,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingContent content) {
    // Define silver text color
    final Color textColor = Colors.grey[300]!;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with background
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              shape: BoxShape.circle,
            ),
            child: Icon(content.icon, size: 80, color: content.iconColor),
          ),
          const SizedBox(height: 40),

          // Title with silver color
          Text(
            content.title,
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Description with lighter silver color
          Text(
            content.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, Color accentColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color:
            _currentPage == index
                ? accentColor
                : Colors.grey[700],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// Helper class to store onboarding content
class OnboardingContent {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
  });
}
