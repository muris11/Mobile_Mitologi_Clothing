import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/utils/haptic_feedback.dart';

void main() {
  group('AppHaptics', () {
    test('tap is defined', () {
      expect(AppHaptics.tap, isA<Function>());
    });

    test('selection is defined', () {
      expect(AppHaptics.selection, isA<Function>());
    });

    test('addToCart is defined', () {
      expect(AppHaptics.addToCart, isA<Function>());
    });

    test('success is defined', () {
      expect(AppHaptics.success, isA<Function>());
    });

    test('error is defined', () {
      expect(AppHaptics.error, isA<Function>());
    });
  });
}
