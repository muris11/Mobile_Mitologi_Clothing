import 'dart:math';
import 'package:flutter/material.dart';

class ResponsiveConfig {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width < tabletBreakpoint) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  static bool isMobile(BuildContext context) =>
      getDeviceType(context) == DeviceType.mobile;

  static bool isTablet(BuildContext context) =>
      getDeviceType(context) == DeviceType.tablet;

  static bool isDesktop(BuildContext context) =>
      getDeviceType(context) == DeviceType.desktop;

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static T value<T>({
    required BuildContext context,
    required T mobile,
    required T tablet,
    T? desktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop ?? tablet;
    }
  }

  static T getResponsiveValue<T>({
    required BuildContext context,
    required T mobile,
    required T tablet,
    T? desktop,
  }) {
    return value(context: context, mobile: mobile, tablet: tablet, desktop: desktop);
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    return value(
      context: context,
      mobile: const EdgeInsets.symmetric(horizontal: 16),
      tablet: const EdgeInsets.symmetric(horizontal: 32),
      desktop: const EdgeInsets.symmetric(horizontal: 64),
    );
  }

  static EdgeInsets pagePadding(BuildContext context) {
    return value(
      context: context,
      mobile: const EdgeInsets.symmetric(horizontal: 20),
      tablet: const EdgeInsets.symmetric(horizontal: 40),
      desktop: const EdgeInsets.symmetric(horizontal: 80),
    );
  }

  static EdgeInsets cardPadding(BuildContext context) {
    return value(
      context: context,
      mobile: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(24),
      desktop: const EdgeInsets.all(32),
    );
  }

  static int getGridColumnCount(BuildContext context) {
    return value(
      context: context,
      mobile: 2,
      tablet: 3,
      desktop: 4,
    );
  }

  static double getFontSizeMultiplier(BuildContext context) {
    return value(
      context: context,
      mobile: 1.0,
      tablet: 1.1,
      desktop: 1.2,
    );
  }

  static double sp(BuildContext context, double size) {
    final multiplier = getFontSizeMultiplier(context);
    return size * multiplier;
  }

  static double heroHeight(BuildContext context) {
    final h = screenHeight(context);
    return value(
      context: context,
      mobile: min(h * 0.5, 380.0),
      tablet: min(h * 0.45, 480.0),
      desktop: min(h * 0.5, 560.0),
    );
  }

  static double productImageHeight(BuildContext context) {
    return value(
      context: context,
      mobile: 520.0,
      tablet: 600.0,
      desktop: 680.0,
    );
  }

  static double iconSize(BuildContext context, {double base = 20}) {
    return value(
      context: context,
      mobile: base,
      tablet: base * 1.2,
      desktop: base * 1.3,
    );
  }

  static double gap(BuildContext context, {double base = 16}) {
    return value(
      context: context,
      mobile: base,
      tablet: base * 1.25,
      desktop: base * 1.5,
    );
  }

  static double borderRadius(BuildContext context, {double base = 28}) {
    return value(
      context: context,
      mobile: base,
      tablet: base * 1.1,
      desktop: base * 1.2,
    );
  }

  static double maxContentWidth(BuildContext context) {
    return value(
      context: context,
      mobile: double.infinity,
      tablet: 720.0,
      desktop: 960.0,
    );
  }

  static double cardWidth(BuildContext context) {
    final w = screenWidth(context);
    return value(
      context: context,
      mobile: w - 48,
      tablet: (w - 96) / 2,
      desktop: (w - 160) / 3,
    );
  }

  static double avatarSize(BuildContext context) {
    return value(
      context: context,
      mobile: 100.0,
      tablet: 120.0,
      desktop: 140.0,
    );
  }

  static double bottomBarHeight(BuildContext context) {
    return value(
      context: context,
      mobile: 80.0,
      tablet: 90.0,
      desktop: 100.0,
    );
  }
}

enum DeviceType {
  mobile,
  tablet,
  desktop,
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    required this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < ResponsiveConfig.mobileBreakpoint) {
          return mobile;
        } else if (constraints.maxWidth < ResponsiveConfig.tabletBreakpoint) {
          return tablet;
        } else {
          return desktop ?? tablet;
        }
      },
    );
  }
}

class ResponsiveConstrainedBox extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  const ResponsiveConstrainedBox({
    super.key,
    required this.child,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final mw = maxWidth ?? ResponsiveConfig.maxContentWidth(context);
    if (mw == double.infinity) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: mw),
        child: child,
      ),
    );
  }
}

class ResponsiveProductGrid extends StatelessWidget {
  final List<dynamic> products;
  final Function(dynamic product) onProductTap;
  final Widget Function(dynamic product) itemBuilder;

  const ResponsiveProductGrid({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount =
            constraints.maxWidth < ResponsiveConfig.mobileBreakpoint
                ? 2
                : constraints.maxWidth < ResponsiveConfig.tabletBreakpoint
                    ? 3
                    : 4;

        return GridView.builder(
          padding: ResponsiveConfig.getResponsivePadding(context),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return itemBuilder(product);
          },
        );
      },
    );
  }
}
