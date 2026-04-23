import 'package:flutter/material.dart';

enum ScrollRevealAnimation { fade, fadeUp, scale }

class ScrollReveal extends StatelessWidget {
  final Widget child;
  final ScrollRevealAnimation animation;

  const ScrollReveal({
    super.key,
    required this.child,
    this.animation = ScrollRevealAnimation.fade,
  });

  @override
  Widget build(BuildContext context) => child;
}
