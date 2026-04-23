import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/utils/retry_policy.dart';

void main() {
  group('RetryPolicy', () {
    const policy = RetryPolicy();

    test('has default values', () {
      expect(policy.maxRetries, 3);
      expect(policy.initialDelay, const Duration(milliseconds: 500));
      expect(policy.backoffMultiplier, 2.0);
    });

    test('getDelayForAttempt calculates exponential backoff', () {
      expect(
        policy.getDelayForAttempt(1),
        const Duration(milliseconds: 1000),
      );
      expect(
        policy.getDelayForAttempt(2),
        const Duration(milliseconds: 2000),
      );
      expect(
        policy.getDelayForAttempt(3),
        const Duration(milliseconds: 3000),
      );
    });

    test('shouldRetry returns false when attempt >= maxRetries', () {
      expect(
        policy.shouldRetry(3, Exception('timeout')),
        false,
      );
      expect(
        policy.shouldRetry(4, Exception('timeout')),
        false,
      );
    });

    test('shouldRetry returns true for socket errors', () {
      expect(
        policy.shouldRetry(1, Exception('socket exception')),
        true,
      );
    });

    test('shouldRetry returns true for timeout errors', () {
      expect(
        policy.shouldRetry(1, Exception('connection timeout')),
        true,
      );
    });

    test('shouldRetry returns true for network errors', () {
      expect(
        policy.shouldRetry(1, Exception('network error')),
        true,
      );
    });

    test('shouldRetry returns false for non-retryable errors', () {
      expect(
        policy.shouldRetry(1, Exception('invalid argument')),
        false,
      );
    });

    test('custom retry policy uses provided values', () {
      const custom = RetryPolicy(
        maxRetries: 5,
        initialDelay: Duration(seconds: 1),
        backoffMultiplier: 3.0,
      );

      expect(custom.maxRetries, 5);
      expect(custom.getDelayForAttempt(1), const Duration(seconds: 3));
    });
  });
}
