import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0C1A2E);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1E3A5F);
  static const Color onPrimaryContainer = Color(0xFFE5C463);

  static const Color secondary = Color(0xFFCA8A04);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFE5C463);
  static const Color onSecondaryContainer = Color(0xFF0C1A2E);

  static const Color background = Color(0xFFF8FAFC);
  static const Color onBackground = Color(0xFF0F172A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF0F172A);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color onSurfaceVariant = Color(0xFF64748B);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF2E7D32);
  static const Color onSuccess = Color(0xFFFFFFFF);

  static const Color outline = Color(0xFF94A3B8);
  static const Color outlineVariant = Color(0xFFE2E8F0);

  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF8FAFC);
  static const Color surfaceContainer = Color(0xFFF1F5F9);
  static const Color surfaceContainerHigh = Color(0xFFE2E8F0);
  static const Color surfaceContainerHighest = Color(0xFFCBD5E1);

  static const Color shadow = Color(0xFF000000);

  static const Color secondarySoft = Color(0x1FCA8A04);
  static const Color glassBorder = Color(0x22FFFFFF);
  static const Color glassSurface = Color(0xE6FFFFFF);
  static const Color glassSurfaceStrong = Color(0xF7FFFFFF);

  // Status colors
  static const Color promoRed = Color(0xFFE11D48);
  static const Color promoRedSoft = Color(0xFFFEECEC);
  static const Color infoBlue = Color(0xFF2563EB);
  static const Color infoSoft = Color(0xFFEFF6FF);
  static const Color successGreen = Color(0xFF16A34A);
  static const Color successSoft = Color(0xFFEFFFEF);
  static const Color warningAmber = Color(0xFFD97706);
  static const Color warningSoft = Color(0xFFFFFBEB);

  // Background warm (untuk badge best-seller)
  static const Color backgroundWarm = Color(0xFFFBF7EF);
}

class AppShadows {
  static final BoxShadow card = BoxShadow(
    color: const Color(0xFF0C1A2E).withValues(alpha: 0.06),
    blurRadius: 24,
    offset: const Offset(0, 10),
  );
  static final BoxShadow cardSoft = BoxShadow(
    color: const Color(0xFF0C1A2E).withValues(alpha: 0.04),
    blurRadius: 16,
    offset: const Offset(0, 4),
  );
  static final BoxShadow cardElevated = BoxShadow(
    color: const Color(0xFF0C1A2E).withValues(alpha: 0.08),
    blurRadius: 32,
    offset: const Offset(0, 12),
  );
  static final BoxShadow button = BoxShadow(
    color: AppColors.primary.withValues(alpha: 0.16),
    blurRadius: 24,
    offset: const Offset(0, 10),
  );
  static final BoxShadow bottomNav = BoxShadow(
    color: const Color(0xFF0C1A2E).withValues(alpha: 0.05),
    blurRadius: 24,
    offset: const Offset(0, -10),
  );
  static final BoxShadow floating = BoxShadow(
    color: const Color(0xFF0C1A2E).withValues(alpha: 0.12),
    blurRadius: 24,
    offset: const Offset(0, 8),
    spreadRadius: -4,
  );
  static final BoxShadow glass = BoxShadow(
    color: const Color(0xFF0C1A2E).withValues(alpha: 0.05),
    blurRadius: 20,
    offset: const Offset(0, 4),
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

  static const LinearGradient navyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0C1A2E),
      Color(0xFF132A46),
    ],
  );

  static const LinearGradient premiumGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFCA8A04),
      Color(0xFFE5C463),
      Color(0xFFCA8A04),
    ],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.background,
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

  static const LinearGradient glassHighlight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x40FFFFFF),
      Color(0x10FFFFFF),
    ],
  );
}

class AppBorderRadius {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double xxl = 32;
  static const double full = 999;

  static BorderRadius get xsRadius => BorderRadius.circular(xs);
  static BorderRadius get smRadius => BorderRadius.circular(sm);
  static BorderRadius get mdRadius => BorderRadius.circular(md);
  static BorderRadius get lgRadius => BorderRadius.circular(lg);
  static BorderRadius get xlRadius => BorderRadius.circular(xl);
  static BorderRadius get xxlRadius => BorderRadius.circular(xxl);
  static BorderRadius get fullRadius => BorderRadius.circular(full);
  static BorderRadius get circular => BorderRadius.circular(9999);
}
