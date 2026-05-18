import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/widgets/luxury_button.dart';

class AnimatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;

  const AnimatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return LuxuryButton(
      label: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      expand: width == null || width == double.infinity,
      variant: isOutlined ? LuxuryButtonVariant.ghost : LuxuryButtonVariant.primary,
    );
  }
}

class AnimatedIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final Color? backgroundColor;

  const AnimatedIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 24,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: size, color: color ?? AppColors.primary),
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
      ),
    );
  }
}

class AnimatedFavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback? onToggle;
  final double size;
  final Color activeColor;

  const AnimatedFavoriteButton({
    super.key,
    required this.isFavorite,
    this.onToggle,
    this.size = 24,
    this.activeColor = const Color(0xFFE53935),
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onToggle,
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        size: size,
        color: isFavorite ? activeColor : AppColors.outline,
      ),
    );
  }
}
