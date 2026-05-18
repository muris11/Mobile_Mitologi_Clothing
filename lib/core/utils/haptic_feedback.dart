import 'package:flutter/services.dart';

class AppHaptics {
  static DateTime? _lastHaptic;

  static void lightImpact() {
    final now = DateTime.now();
    if (_lastHaptic != null && 
        now.difference(_lastHaptic!) < const Duration(milliseconds: 100)) {
      return;
    }
    _lastHaptic = now;
    HapticFeedback.lightImpact();
  }

  static void tap() {
    lightImpact();
  }

  static void addToCart() {
    final now = DateTime.now();
    if (_lastHaptic != null && 
        now.difference(_lastHaptic!) < const Duration(milliseconds: 150)) {
      return;
    }
    _lastHaptic = now;
    HapticFeedback.mediumImpact();
  }
}
