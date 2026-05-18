import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';
import 'package:mitologi_clothing_mobile/core/widgets/glass_container.dart';
import 'package:mitologi_clothing_mobile/core/widgets/luxury_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AnimatedEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;
  final Color? iconColor;
  final bool centerContent;

  const AnimatedEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
    this.iconColor,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: PremiumEmptyStateView(
        icon: icon,
        title: title,
        subtitle: subtitle,
        actionLabel: actionLabel,
        onAction: onAction,
        iconColor: iconColor,
        centerContent: centerContent,
      ),
    );
  }
}

class PremiumEmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;
  final Color? iconColor;
  final bool centerContent;

  const PremiumEmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
    this.iconColor,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          borderRadius: AppBorderRadius.xxlRadius,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment:
                centerContent ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.secondary).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        (iconColor ?? AppColors.secondary).withValues(alpha: 0.18),
                  ),
                ),
                child: Icon(
                  icon,
                  size: 34,
                  color: iconColor ?? AppColors.secondary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: AppTextStyles.notoSerif(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  height: 1.15,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.manrope(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 22),
              LuxuryButton(
                label: actionLabel,
                onPressed: onAction,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PremiumErrorStateView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String title;

  const PremiumErrorStateView({
    super.key,
    required this.message,
    required this.onRetry,
    this.title = 'Terjadi Kesalahan',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassContainer(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              PhosphorIconsRegular.warning,
              size: 42,
              color: AppColors.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.notoSerif(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.manrope(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: LuxuryButton(
                onPressed: onRetry,
                icon: PhosphorIconsRegular.arrowClockwise,
                label: 'Coba Lagi',
                expand: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginRequiredState extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onLogin;

  const LoginRequiredState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedEmptyState(
      icon: PhosphorIconsRegular.lockKey,
      title: title,
      subtitle: subtitle,
      actionLabel: 'Masuk / Daftar',
      onAction: onLogin,
    );
  }
}

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String title;

  const ErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    this.title = 'Terjadi Kesalahan',
  });

  @override
  Widget build(BuildContext context) {
    return PremiumErrorStateView(
      message: message,
      onRetry: onRetry,
      title: title,
    );
  }
}
