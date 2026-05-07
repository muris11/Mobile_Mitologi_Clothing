import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/home_view_model.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeFeaturesSection extends StatelessWidget {
  final HomeViewModel viewModel;

  const HomeFeaturesSection({super.key, required this.viewModel});

  static const Color _iosNavy = Color(0xFF1E2A44);
  static const Color _iosSurface = Color(0xFFFFFFFF);
  static const Color _iosBorder = Color(0xFFE2E8F0);
  static const Color _iosText = Color(0xFF0F172A);
  static const Color _iosMuted = Color(0xFFF1F5F9);
  static const Color _iosSubtext = Color(0xFF64748B);

  IconData _getFeatureIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'truck':
        return PhosphorIconsRegular.truck;
      case 'credit-card':
        return PhosphorIconsRegular.creditCard;
      case 'shield-check':
        return PhosphorIconsRegular.shieldCheck;
      case 'clock':
        return PhosphorIconsRegular.clock;
      default:
        return PhosphorIconsRegular.sparkle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final features = viewModel.features;
    if (features.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Container(
        height: 164,
        margin: const EdgeInsets.only(top: 24),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return Container(
              width: 172,
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              decoration: BoxDecoration(
                color: _iosSurface,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: _iosBorder),
                boxShadow: [AppShadows.cardSoft],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: _iosMuted,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getFeatureIcon(feature.icon),
                      color: _iosNavy,
                      size: 22,
                    ),
                  ),
                  const Gap(12),
                  Text(
                    feature.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: _iosText,
                    ),
                  ),
                  const Gap(3),
                  Expanded(
                    child: Text(
                      feature.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _iosSubtext,
                        fontSize: 11,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
