import 'dart:async';
import 'package:flutter/foundation.dart';

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

extension DebounceExtension on Function(String) {
  Function(String) debounce(Duration delay) {
    final debouncer = Debouncer(delay: delay);
    return (String value) {
      debouncer.run(() => this(value));
    };
  }
}
