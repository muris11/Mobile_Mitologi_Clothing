/// Retry configuration for API calls
class RetryPolicy {
  final int maxRetries;
  final Duration initialDelay;
  final double backoffMultiplier;

  const RetryPolicy({
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.backoffMultiplier = 2.0,
  });

  Duration getDelayForAttempt(int attempt) {
    return Duration(
      milliseconds:
          (initialDelay.inMilliseconds * backoffMultiplier * attempt).toInt(),
    );
  }

  bool shouldRetry(int attempt, Exception error) {
    if (attempt >= maxRetries) return false;

    // Only retry on specific errors
    final errorString = error.toString().toLowerCase();
    return errorString.contains('socket') ||
        errorString.contains('timeout') ||
        errorString.contains('network');
  }
}
