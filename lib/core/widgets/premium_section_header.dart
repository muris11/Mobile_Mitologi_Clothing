import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';
import 'package:mitologi_clothing_mobile/core/utils/responsive_utils.dart';
import 'package:mitologi_clothing_mobile/core/widgets/luxury_button.dart';

class PremiumSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? eyebrow;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  const PremiumSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.fromLTRB(24, 40, 24, 16),
  });

  @override
  Widget build(BuildContext context) {
    final eyebrowSize = ResponsiveConfig.sp(context, 11);
    final titleSize = ResponsiveConfig.sp(context, 26);
    final subtitleSize = ResponsiveConfig.sp(context, 13);

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null && eyebrow!.isNotEmpty) ...[
                  Text(
                    eyebrow!,
                    style: AppTextStyles.manrope(
                      fontSize: eyebrowSize,
                      fontWeight: FontWeight.w900,
                      color: AppColors.secondary,
                      letterSpacing: 2.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Text(
                  title,
                  style: AppTextStyles.notoSerif(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    height: 1.15,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: AppTextStyles.manrope(
                      fontSize: subtitleSize,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 12),
            LuxuryButton(
              label: actionLabel!,
              onPressed: onAction,
              variant: LuxuryButtonVariant.secondary,
            ),
          ],
        ],
      ),
    );
  }
}
