import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const SectionHeader({super.key, required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'Lihat Semua',
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
      ],
    );
  }
}
