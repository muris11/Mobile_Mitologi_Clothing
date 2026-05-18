import 'package:flutter/material.dart';

class CustomPullToRefresh extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const CustomPullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: child,
    );
  }
}
