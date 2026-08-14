import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' show pow;

/// Retry configuration model
class RetryConfig {
  final int maxAttempts;
  final Duration baseDelay;
  final double backoffMultiplier;

  const RetryConfig({
    this.maxAttempts = 3,
    this.baseDelay = const Duration(seconds: 2),
    this.backoffMultiplier = 2.0,
  });

  /// Calculate delay for attempt number
  Duration getDelayForAttempt(int attemptNumber) {
    final multiplier = pow(
      backoffMultiplier,
      (attemptNumber - 1).toDouble(),
    ).toInt();
    return baseDelay * multiplier;
  }

  @override
  String toString() =>
      'RetryConfig(max: $maxAttempts, baseDelay: $baseDelay, backoff: $backoffMultiplier)';
}

/// Retry state model
class RetryState {
  final int currentAttempt;
  final int maxAttempts;
  final bool isRetrying;
  final String? lastError;
  final DateTime? lastRetryTime;

  const RetryState({
    this.currentAttempt = 0,
    this.maxAttempts = 3,
    this.isRetrying = false,
    this.lastError,
    this.lastRetryTime,
  });

  /// Check if more retries available
  bool get canRetry => currentAttempt < maxAttempts;

  /// Get remaining attempts
  int get remainingAttempts => maxAttempts - currentAttempt;

  /// Get retry percentage
  int get retryPercentage => ((currentAttempt / maxAttempts) * 100).toInt();

  RetryState copyWith({
    int? currentAttempt,
    int? maxAttempts,
    bool? isRetrying,
    String? lastError,
    DateTime? lastRetryTime,
  }) {
    return RetryState(
      currentAttempt: currentAttempt ?? this.currentAttempt,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      isRetrying: isRetrying ?? this.isRetrying,
      lastError: lastError ?? this.lastError,
      lastRetryTime: lastRetryTime ?? this.lastRetryTime,
    );
  }

  @override
  String toString() =>
      'RetryState(attempt: $currentAttempt/$maxAttempts, canRetry: $canRetry)';
}

/// Retry notifier for managing retry attempts
class RetryNotifier extends StateNotifier<RetryState> {
  final RetryConfig config;

  RetryNotifier({RetryConfig? config})
    : config = config ?? const RetryConfig(),
      super(RetryState(maxAttempts: config?.maxAttempts ?? 3));

  /// Increment attempt counter
  void incrementAttempt(String error) {
    state = state.copyWith(
      currentAttempt: state.currentAttempt + 1,
      lastError: error,
      isRetrying: false,
    );
  }

  /// Reset retry counter
  void reset() {
    state = RetryState(maxAttempts: state.maxAttempts);
  }

  /// Set retrying state
  void setRetrying(bool retrying) {
    state = state.copyWith(
      isRetrying: retrying,
      lastRetryTime: retrying ? DateTime.now() : null,
    );
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(lastError: null);
  }

  /// Get current delay before next retry
  Duration getNextRetryDelay() {
    if (!state.canRetry) return Duration.zero;
    return config.getDelayForAttempt(state.currentAttempt + 1);
  }
}

/// Default retry configuration
const defaultRetryConfig = RetryConfig(
  maxAttempts: 3,
  baseDelay: Duration(seconds: 2),
  backoffMultiplier: 2.0,
);

/// Provider for weather retry state
final weatherRetryProvider = StateNotifierProvider<RetryNotifier, RetryState>((
  ref,
) {
  return RetryNotifier(config: defaultRetryConfig);
});

/// Provider for retry delay
final retryDelayProvider = Provider<Duration>((ref) {
  final retryState = ref.watch(weatherRetryProvider);
  if (!retryState.canRetry) return Duration.zero;
  final notifier = ref.read(weatherRetryProvider.notifier);
  return notifier.getNextRetryDelay();
});

/// Provider to check if can retry
final canRetryProvider = Provider<bool>((ref) {
  final retryState = ref.watch(weatherRetryProvider);
  return retryState.canRetry;
});

/// Provider for remaining attempts
final remainingAttemptsProvider = Provider<int>((ref) {
  final retryState = ref.watch(weatherRetryProvider);
  return retryState.remainingAttempts;
});
