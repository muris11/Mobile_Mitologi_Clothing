import 'package:flutter/services.dart';

class AppHaptics {
  static void tap() => HapticFeedback.selectionClick();
  static void selection() => HapticFeedback.selectionClick();
  static void addToCart() => HapticFeedback.lightImpact();
  static void success() => HapticFeedback.mediumImpact();
  static void error() => HapticFeedback.heavyImpact();
}
