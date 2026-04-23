import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF000613);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF001F3F);
  static const Color onPrimaryContainer = Color(0xFF6F88AD);
  static const Color secondary = Color(0xFF735C00);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFED65B);
  static const Color onSecondaryContainer = Color(0xFF745C00);
  static const Color tertiary = Color(0xFF040604);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFAF9F5);
  static const Color onSurface = Color(0xFF1B1C1A);
  static const Color surfaceVariant = Color(0xFFE3E2DF);
  static const Color onSurfaceVariant = Color(0xFF43474E);
  static const Color background = Color(0xFFFAF9F5);
  static const Color onBackground = Color(0xFF1B1C1A);
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color outline = Color(0xFF74777F);
  static const Color outlineVariant = Color(0xFFC4C6CF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF4F4F0);
  static const Color surfaceContainer = Color(0xFFEFEEEA);
  static const Color surfaceContainerHigh = Color(0xFFE9E8E4);
  static const Color surfaceContainerHighest = Color(0xFFE3E2DF);
  static const Color surfaceBright = Color(0xFFFAF9F5);
  static const Color shadow = Color(0xFF000000);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
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
  static const LinearGradient heroOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Colors.black87,
    ],
    stops: [0.4, 1.0],
  );

  static const LinearGradient cardSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.surfaceContainerLowest,
      AppColors.surfaceContainerLow,
    ],
  );

  static const LinearGradient primaryDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primary,
      AppColors.primaryContainer,
    ],
  );

  static const LinearGradient categoryBg = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF5F5F0),
      Color(0xFFE8E8E3),
    ],
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

class AppTypography {
  static TextTheme get textTheme => TextTheme(
        headlineLarge: GoogleFonts.notoSerif(
            fontSize: 32,
            fontWeight: FontWeight.w400,
            color: AppColors.onSurface),
        headlineMedium: GoogleFonts.notoSerif(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: AppColors.onSurface),
        headlineSmall: GoogleFonts.notoSerif(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: AppColors.onSurface),
        titleLarge: GoogleFonts.manrope(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface),
        titleMedium: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface),
        titleSmall: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface),
        bodyLarge: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.onSurface),
        bodyMedium: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.onSurface),
        bodySmall: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.onSurface),
        labelLarge: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface),
        labelMedium: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface),
        labelSmall: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface),
      );
}

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          primaryContainer: AppColors.primaryContainer,
          onPrimaryContainer: AppColors.onPrimaryContainer,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
          secondaryContainer: AppColors.secondaryContainer,
          onSecondaryContainer: AppColors.onSecondaryContainer,
          tertiary: AppColors.tertiary,
          onTertiary: AppColors.onTertiary,
          error: AppColors.error,
          onError: AppColors.onError,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          surfaceContainerHighest: AppColors.surfaceContainerHighest,
          onSurfaceVariant: AppColors.onSurfaceVariant,
          outline: AppColors.outline,
          outlineVariant: AppColors.outlineVariant,
          shadow: AppColors.shadow,
        ),
        textTheme: AppTypography.textTheme,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surface.withValues(alpha: 0.95),
          foregroundColor: AppColors.onSurface,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.notoSerif(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: AppColors.primary),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor:
              AppColors.surfaceContainerLowest.withValues(alpha: 0.95),
          selectedItemColor: AppColors.secondary,
          unselectedItemColor: AppColors.onSurfaceVariant,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: AppColors.surfaceContainerLowest,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.xxl)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.xl)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.outlineVariant),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.xl)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceContainerLow,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.xl),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.xl),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.xl),
              borderSide:
                  const BorderSide(color: AppColors.secondary, width: 2)),
          hintStyle: GoogleFonts.manrope(
              fontSize: 14, color: AppColors.outline.withValues(alpha: 0.6)),
        ),
      );
}
