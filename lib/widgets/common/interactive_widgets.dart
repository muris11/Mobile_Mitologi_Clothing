import 'package:flutter/material.dart';

class InteractiveScale extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;

  const InteractiveScale({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.95,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    );
  }
}
