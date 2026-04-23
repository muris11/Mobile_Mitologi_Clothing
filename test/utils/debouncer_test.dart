import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/utils/debouncer.dart';

void main() {
  group('Debouncer', () {
    test('executes action after delay', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 50));
      var executed = false;

      debouncer.run(() => executed = true);
      expect(executed, false);

      await Future.delayed(const Duration(milliseconds: 100));
      expect(executed, true);
    });

    test('cancels previous timer on subsequent run', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 100));
      var count = 0;

      debouncer.run(() => count++);
      await Future.delayed(const Duration(milliseconds: 50));
      debouncer.run(() => count++);

      await Future.delayed(const Duration(milliseconds: 150));
      expect(count, 1);
    });

    test('dispose cancels timer', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 50));
      var executed = false;

      debouncer.run(() => executed = true);
      debouncer.dispose();

      await Future.delayed(const Duration(milliseconds: 100));
      expect(executed, false);
    });

    test('default delay is 300ms', () {
      final debouncer = Debouncer();
      expect(debouncer.delay, const Duration(milliseconds: 300));
    });
  });

  group('DebounceExtension', () {
    test('debounces function calls', () async {
      var callCount = 0;
      void onSearch(String value) => callCount++;

      final debounced = onSearch.debounce(const Duration(milliseconds: 50));

      debounced('a');
      debounced('ab');
      debounced('abc');

      expect(callCount, 0);
      await Future.delayed(const Duration(milliseconds: 100));
      expect(callCount, 1);
    });
  });
}
