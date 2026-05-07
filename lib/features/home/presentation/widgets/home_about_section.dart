import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/widgets/app_image.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/home_view_model.dart';

class HomeAboutSection extends StatelessWidget {
  final HomeViewModel viewModel;

  const HomeAboutSection({super.key, required this.viewModel});

  static const Color _iosSurface = Color(0xFFFFFFFF);
  static const Color _iosBorder = Color(0xFFE2E8F0);
  static const Color _iosText = Color(0xFF0F172A);
  static const Color _iosSubtext = Color(0xFF64748B);
  static const Color _iosGold = Color(0xFFD8A73C);
  static const Color _iosNavy = Color(0xFF1E2A44);

  @override
  Widget build(BuildContext context) {
    final settings = viewModel.siteSettings;
    if (settings == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final headline = settings.aboutHeadline ?? 'Tentang Mitologi Clothing';
    final desc1 = settings.aboutDescription1 ?? '';
    final desc2 = settings.aboutDescription2 ?? '';
    final year = settings.companyFoundedYear ?? '';
    final aboutImg = settings.aboutImage;

    if (desc1.isEmpty && desc2.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 48, 24, 0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _iosSurface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: _iosBorder),
          boxShadow: [AppShadows.cardSoft],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 32, height: 2, color: _iosGold),
                const Gap(10),
                const Text(
                  'TENTANG KAMI',
                  style: TextStyle(
                    color: _iosGold,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const Gap(12),
            Text(
              headline,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                height: 1.2,
                color: _iosText,
              ),
            ),
            if (aboutImg != null && aboutImg.isNotEmpty) ...[
              const Gap(16),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: AppImage(
                    imageUrl: ApiConfig.buildImageUrl(aboutImg),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
            const Gap(16),
            if (desc1.isNotEmpty)
              Text(
                desc1,
                style: const TextStyle(
                  color: _iosSubtext,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            if (desc2.isNotEmpty) ...[
              const Gap(8),
              Text(
                desc2,
                style: const TextStyle(
                  color: _iosSubtext,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ],
            if (year.isNotEmpty) ...[
              const Gap(20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _iosNavy,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Berdiri sejak $year',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
