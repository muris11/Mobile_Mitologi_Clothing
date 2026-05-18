import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';

class MitologiAlert extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmLabel;
  final String? cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final IconData? icon;
  final Widget? content;

  const MitologiAlert({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel,
    this.cancelLabel,
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.icon,
    this.content,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    bool isDestructive = false,
    IconData? icon,
    Widget? content,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => MitologiAlert(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
        isDestructive: isDestructive,
        icon: icon,
        content: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 48),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: (isDestructive ? AppColors.error : AppColors.primary).withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isDestructive ? AppColors.error : AppColors.primary,
                  size: 28,
                ),
              ),
              const Gap(24),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.notoSerif(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),
            const Gap(12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.manrope(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (content != null) ...[
              const Gap(12),
              content!,
            ],
            const Gap(32),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: onConfirm ?? () => context.pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: isDestructive ? AppColors.error : AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      confirmLabel ?? 'Konfirmasi',
                      style: AppTextStyles.manrope(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                if (cancelLabel != null || onCancel != null) ...[
                  const Gap(8),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextButton(
                      onPressed: onCancel ?? () => context.pop(false),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        cancelLabel ?? 'Batal',
                        style: AppTextStyles.manrope(
                          fontWeight: FontWeight.w700,
                          color: AppColors.outline,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
