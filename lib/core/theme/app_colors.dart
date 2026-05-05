import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF000613); // Deep Navy
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF001F3F);
  static const Color onPrimaryContainer = Color(0xFF6F88AD);
  
  static const Color secondary = Color(0xFF735C00); // Gold
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFED65B);
  static const Color onSecondaryContainer = Color(0xFF745C00);

  static const Color background = Color(0xFFFAF9F5);
  static const Color onBackground = Color(0xFF1B1C1A);
  static const Color surface = Color(0xFFFAF9F5);
  static const Color onSurface = Color(0xFF1B1C1A);
  static const Color surfaceVariant = Color(0xFFE3E2DF);
  static const Color onSurfaceVariant = Color(0xFF43474E);
  
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF2E7D32);
  static const Color onSuccess = Color(0xFFFFFFFF);

  static const Color outline = Color(0xFF74777F);
  static const Color outlineVariant = Color(0xFFC4C6CF);
  
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF4F4F0);
  static const Color surfaceContainer = Color(0xFFEFEEEA);
  static const Color surfaceContainerHigh = Color(0xFFE9E8E4);
  static const Color surfaceContainerHighest = Color(0xFFE3E2DF);
  
  static const Color shadow = Color(0xFF000000);
}

class AppShadows {
  static final BoxShadow card = BoxShadow(
    color: AppColors.shadow.withValues(alpha: 0.08),
    blurRadius: 20,
    offset: const Offset(0, 10),
  );
  static final BoxShadow cardSoft = BoxShadow(
    color: AppColors.shadow.withValues(alpha: 0.04),
    blurRadius: 12,
    offset: const Offset(0, 4),
  );
  static final BoxShadow cardElevated = BoxShadow(
    color: AppColors.shadow.withValues(alpha: 0.12),
    blurRadius: 24,
    offset: const Offset(0, 8),
  );
  static final BoxShadow button = BoxShadow(
    color: AppColors.primary.withValues(alpha: 0.2),
    blurRadius: 30,
    offset: const Offset(0, 10),
  );
  static final BoxShadow bottomNav = BoxShadow(
    color: AppColors.shadow.withValues(alpha: 0.03),
    blurRadius: 30,
    offset: const Offset(0, -10),
  );
  static final BoxShadow floating = BoxShadow(
    color: AppColors.shadow.withValues(alpha: 0.15),
    blurRadius: 20,
    offset: const Offset(0, 6),
    spreadRadius: -4,
  );
}

class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primary,
      AppColors.primaryContainer,
    ],
  );

  static const LinearGradient premiumGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF735C00),
      Color(0xFFFED65B),
      Color(0xFF735C00),
    ],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.surfaceContainerLowest,
      AppColors.surfaceContainerLow,
    ],
  );

  static const LinearGradient heroOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Colors.black87,
    ],
    stops: [0.4, 1.0],
  );

  static const LinearGradient shimmer = LinearGradient(
    colors: [
      AppColors.surfaceContainerLow,
      AppColors.surfaceContainerHigh,
      AppColors.surfaceContainerLow,
    ],
    stops: [0.0, 0.5, 1.0],
  );
}

class AppBorderRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 12;
  static const double xxl = 20;
  static const double full = 9999;
}
