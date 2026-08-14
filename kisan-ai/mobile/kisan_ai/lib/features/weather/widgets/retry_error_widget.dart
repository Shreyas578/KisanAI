import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/theme/app_colors.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/features/weather/state/weather_retry_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Error widget with retry button
class RetryErrorWidget extends ConsumerWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final bool isRetrying;

  const RetryErrorWidget({
    Key? key,
    required this.errorMessage,
    required this.onRetry,
    this.isRetrying = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final retryState = ref.watch(weatherRetryProvider);
    final canRetry = retryState.canRetry;
    final remainingAttempts = retryState.remainingAttempts;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dangerRed.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.dangerRed.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 32,
              color: AppColors.dangerRed,
            ),
          ),
          const SizedBox(height: 16),

          // Error title
          Text(
            'Oops! Something went wrong',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Error message
          Text(
            _formatErrorMessage(errorMessage),
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Retry attempt indicator
          if (!canRetry)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.dangerRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.dangerRed,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Max retry attempts reached. Please try again later.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.dangerRed,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (retryState.currentAttempt > 0)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.accentGreen,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Attempt ${retryState.currentAttempt}/${retryState.maxAttempts} • $remainingAttempts attempts left',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.accentGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Retry button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canRetry && !isRetrying
                  ? () {
                      ref.read(weatherRetryProvider.notifier).setRetrying(true);
                      onRetry();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                disabledBackgroundColor: AppColors.textSecondary.withValues(
                  alpha: 0.3,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isRetrying
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          canRetry ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    )
                  : Text(
                      canRetry ? 'Retry Now' : 'Max Attempts Reached',
                      style: AppTypography.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 12),

          // More options button
          if (canRetry)
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  ref.read(weatherRetryProvider.notifier).reset();
                },
                child: Text(
                  'Reset & Go Back',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.accentGreen,
                  ),
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2);
  }

  /// Format error message for display
  String _formatErrorMessage(String error) {
    if (error.contains('Connection')) {
      return 'Unable to connect to the server. Please check your internet connection.';
    } else if (error.contains('Timeout')) {
      return 'Request took too long. Please try again.';
    } else if (error.contains('404')) {
      return 'The resource was not found. Please try again.';
    } else if (error.contains('500')) {
      return 'Server error. Please try again later.';
    } else if (error.isEmpty) {
      return 'An unexpected error occurred. Please try again.';
    }
    return error;
  }
}
