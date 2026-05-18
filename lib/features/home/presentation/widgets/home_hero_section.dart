import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';
import 'package:mitologi_clothing_mobile/core/widgets/app_image.dart';
import 'package:mitologi_clothing_mobile/core/widgets/glass_container.dart';
import 'package:mitologi_clothing_mobile/core/widgets/luxury_button.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/site_settings_model.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/home_view_model.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class HomeHeroSection extends StatefulWidget {
  final PageController bannerController;
  final int currentBannerIndex;
  final ValueChanged<int> onBannerIndexChanged;

  const HomeHeroSection({
    super.key,
    required this.bannerController,
    required this.currentBannerIndex,
    required this.onBannerIndexChanged,
  });

  @override
  State<HomeHeroSection> createState() => _HomeHeroSectionState();
}

class _HomeHeroSectionState extends State<HomeHeroSection> {
  @override
  Widget build(BuildContext context) {
    final banners = context.select<HomeViewModel, List>((vm) => vm.banners);
    final settings = context.select<HomeViewModel, SiteSettingsModel?>((vm) => vm.siteSettings);

    if (banners.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: GlassContainer(
            padding: const EdgeInsets.all(48),
            borderRadius: BorderRadius.circular(34),
            child: Column(
              children: [
                const Icon(PhosphorIconsRegular.tShirt, size: 42, color: AppColors.secondary),
                const Gap(20),
                Text(
                  'Koleksi Mitologi',
                  style: AppTextStyles.notoSerif(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
                const Gap(8),
                Text(
                  'Eksplorasi fashion nusantara sedang disiapkan.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.manrope(fontSize: 14, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final banner = banners[widget.currentBannerIndex];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 500,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: widget.bannerController,
                    itemCount: banners.length,
                    onPageChanged: widget.onBannerIndexChanged,
                    itemBuilder: (context, index) {
                      final item = banners[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index == banners.length - 1 ? 0 : 12,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(34),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              AppImage(
                                imageUrl: ApiConfig.buildImageUrl(item.imageUrl),
                                fit: BoxFit.cover,
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Color(0x22000000), Color(0x11000000), Color(0xCC0D1726)],
                                    stops: [0.0, 0.45, 1.0],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    left: 28,
                    right: 28,
                    bottom: 28,
                    child: GlassContainer(
                      padding: const EdgeInsets.all(24),
                      borderRadius: BorderRadius.circular(28),
                      blur: 20,
                      color: AppColors.primary.withValues(alpha: 0.28),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            settings?.siteTagline ?? 'Koleksi Eksklusif',
                            style: AppTextStyles.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppColors.secondaryContainer,
                              letterSpacing: 2.4,
                            ),
                          ),
                          const Gap(10),
                          Text(
                            banner.title,
                            style: AppTextStyles.notoSerif(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.08,
                            ),
                          ),
                          const Gap(10),
                          Text(
                            (banner.description?.isNotEmpty ?? false)
                                ? banner.description!
                                : 'Dirancang dengan detail, dibuat untuk tampil percaya diri.',
                            style: AppTextStyles.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.86),
                              height: 1.6,
                            ),
                          ),
                          const Gap(18),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              LuxuryButton(
                                label: 'Eksplor Katalog',
                                icon: PhosphorIconsRegular.arrowUpRight,
                                onPressed: () => context.go('/products'),
                              ),
                              LuxuryButton(
                                label: 'Cerita Brand',
                                icon: PhosphorIconsRegular.images,
                                variant: LuxuryButtonVariant.secondary,
                                onPressed: () => context.go('/portfolio'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 24,
                    right: 24,
                    child: Row(
                      children: List.generate(banners.length, (index) {
                        final isActive = widget.currentBannerIndex == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.only(left: 6),
                          width: isActive ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
