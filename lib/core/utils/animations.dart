import 'package:flutter/material.dart';

class AppAnimations {
  AppAnimations._();

  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration quick = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration entrance = Duration(milliseconds: 600);

  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve sharpCurve = Curves.easeOutExpo;
  static const Curve entranceCurve = Curves.easeOutCubic;
  static const Curve exitCurve = Curves.easeInQuad;
}

class FadeSlideTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final Offset beginOffset;

  const FadeSlideTransition({
    super.key,
    required this.animation,
    required this.child,
    this.beginOffset = const Offset(0, 0.05),
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      ),
    );
  }
}

class ScaleFadeTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final double beginScale;

  const ScaleFadeTransition({
    super.key,
    required this.animation,
    required this.child,
    this.beginScale = 0.95,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: beginScale, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    );
  }
}

class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;
    return Opacity(opacity: 0.5, child: child);
  }
}
