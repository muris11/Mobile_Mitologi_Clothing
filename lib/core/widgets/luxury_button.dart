import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';

enum LuxuryButtonVariant { primary, secondary, ghost }

class LuxuryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expand;
  final LuxuryButtonVariant variant;
  final EdgeInsetsGeometry? padding;

  const LuxuryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = false,
    this.variant = LuxuryButtonVariant.primary,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = switch (variant) {
      LuxuryButtonVariant.primary => AppColors.onPrimary,
      LuxuryButtonVariant.secondary => AppColors.onSecondaryContainer,
      LuxuryButtonVariant.ghost => AppColors.primary,
    };
    final background = switch (variant) {
      LuxuryButtonVariant.primary => AppColors.primary,
      LuxuryButtonVariant.secondary => AppColors.secondary,
      LuxuryButtonVariant.ghost => Colors.transparent,
    };
    final border = switch (variant) {
      LuxuryButtonVariant.primary => BorderSide.none,
      LuxuryButtonVariant.secondary => BorderSide.none,
      LuxuryButtonVariant.ghost =>
        const BorderSide(color: AppColors.outlineVariant),
    };

    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppBorderRadius.fullRadius,
        border: Border.fromBorderSide(border),
        boxShadow: variant != LuxuryButtonVariant.ghost
            ? [AppShadows.button]
            : const <BoxShadow>[],
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(foreground),
              ),
            )
          else ...[
            if (icon != null) ...[
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: 10),
            ],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: foreground,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: AppBorderRadius.fullRadius,
        child: child,
      ),
    );

    if (expand) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}
