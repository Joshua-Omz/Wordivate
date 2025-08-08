import 'package:flutter/material.dart';
import 'package:wordivate/core/constants/app_colors.dart';

/// A reusable error widget for displaying error states
class ErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String? retryText;

  const ErrorWidget({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.retryText,
  });

  /// Factory constructor for API errors
  factory ErrorWidget.apiError({
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    return ErrorWidget(
      title: 'Connection Error',
      message: customMessage ?? 'Failed to connect to the server. Please check your internet connection.',
      onRetry: onRetry,
      retryText: 'Retry',
    );
  }

  /// Factory constructor for loading errors
  factory ErrorWidget.loadingError({
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    return ErrorWidget(
      title: 'Loading Error',
      message: customMessage ?? 'Something went wrong while loading data.',
      onRetry: onRetry,
      retryText: 'Try Again',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.withOpacity(0.7),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText ?? 'Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}