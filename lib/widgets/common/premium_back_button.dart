import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// A premium circular back button widget with subtle shadow,
/// consistent with Mitologi Clothing's design language.
///
/// Use this as [AppBar.leading] to replace bare [IconButton]s.
class PremiumBackButton extends StatelessWidget {
  /// Callback when the button is pressed. Defaults to [Navigator.pop].
  final VoidCallback? onPressed;

  /// Icon color. Defaults to [AppColors.primary].
  final Color? color;

  /// Background color. Defaults to [Colors.white].
  final Color? backgroundColor;

  /// Border color. Defaults to [AppColors.outlineVariant] with 50% opacity.
  final Color? borderColor;

  const PremiumBackButton({
    super.key,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? Colors.white;
    final effectiveColor = color ?? AppColors.primary;
    final effectiveBorder =
        borderColor ?? AppColors.outlineVariant.withValues(alpha: 0.5);

    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: effectiveBg,
          shape: BoxShape.circle,
          border: Border.all(color: effectiveBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onPressed ?? () => Navigator.of(context).pop(),
            child: Icon(
              PhosphorIconsRegular.caretLeft,
              color: effectiveColor,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

/// A variant of [PremiumBackButton] designed for dark/navy backgrounds
/// (e.g. when [SliverAppBar.backgroundColor] is [AppColors.primary]).
class PremiumBackButtonOnDark extends StatelessWidget {
  final VoidCallback? onPressed;

  const PremiumBackButtonOnDark({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return PremiumBackButton(
      onPressed: onPressed,
      color: Colors.white,
      backgroundColor: Colors.white.withValues(alpha: 0.15),
      borderColor: Colors.white.withValues(alpha: 0.3),
    );
  }
}
