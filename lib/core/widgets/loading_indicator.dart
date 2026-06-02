import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';
import 'package:mitologi_clothing_mobile/core/widgets/glass_container.dart';
import 'package:mitologi_clothing_mobile/core/widgets/luxury_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(20),
        child: const CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }
}

class ErrorWidgetWithRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorWidgetWithRetry({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          borderRadius: BorderRadius.circular(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                PhosphorIconsRegular.warningCircle,
                size: 42,
                color: AppColors.secondary,
              ),
              const Gap(20),
              Text(
                'Terjadi Kesalahan',
                style: AppTextStyles.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(8),
              Text(
                message,
                style: AppTextStyles.plusJakartaSans(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 14,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(24),
              LuxuryButton(
                onPressed: onRetry,
                icon: PhosphorIconsRegular.arrowClockwise,
                label: 'Coba Lagi',
                expand: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
