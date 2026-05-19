import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum SnackbarType { info, success, error }

class AnimatedSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    final theme = Theme.of(context);
    
    // Design tokens based on type
    final backgroundColor = switch (type) {
      SnackbarType.success => const Color(0xFFECFDF5),
      SnackbarType.error => const Color(0xFFFFF1F2),
      SnackbarType.info => const Color(0xFFF0FDF4), // Warm tint
    };

    final borderColor = switch (type) {
      SnackbarType.success => const Color(0xFF10B981).withValues(alpha: 0.3),
      SnackbarType.error => const Color(0xFFEF4444).withValues(alpha: 0.3),
      SnackbarType.info => AppColors.primary.withValues(alpha: 0.15),
    };

    final iconColor = switch (type) {
      SnackbarType.success => const Color(0xFF059669),
      SnackbarType.error => const Color(0xFFDC2626),
      SnackbarType.info => AppColors.primary,
    };

    final icon = switch (type) {
      SnackbarType.success => PhosphorIconsFill.checkCircle,
      SnackbarType.error => PhosphorIconsFill.warningCircle,
      SnackbarType.info => PhosphorIconsFill.info,
    };

    final defaultTitle = switch (type) {
      SnackbarType.success => 'Berhasil',
      SnackbarType.error => 'Gagal',
      SnackbarType.info => 'Informasi',
    };

    final snackBar = SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: EdgeInsets.zero,
      duration: duration,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title ?? defaultTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Clear current queue to prevent stacking overlays
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(snackBar);
  }

  static void success(BuildContext context, String message, {String? title, Duration duration = const Duration(seconds: 4)}) {
    show(context, message: message, title: title, type: SnackbarType.success, duration: duration);
  }

  static void error(BuildContext context, String message, {String? title, Duration duration = const Duration(seconds: 4)}) {
    show(context, message: message, title: title, type: SnackbarType.error, duration: duration);
  }

  static void info(BuildContext context, String message, {String? title, Duration duration = const Duration(seconds: 4)}) {
    show(context, message: message, title: title, type: SnackbarType.info, duration: duration);
  }
}
