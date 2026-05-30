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
              height: 560,
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
                                    colors: [
                                      Color(0x33000000),
                                      Color(0x11000000),
                                      Color(0x99000000),
                                      Color(0xEE08101C)
                                    ],
                                    stops: [0.0, 0.4, 0.75, 1.0],
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
                    left: 20,
                    right: 20,
                    bottom: 24,
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
                      borderRadius: BorderRadius.circular(28),
                      blur: 24,
                      color: AppColors.primary.withValues(alpha: 0.35),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: AppGradients.premiumGold,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondary.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Text(
                              (settings?.siteTagline ?? 'Koleksi Eksklusif').toUpperCase(),
                              style: AppTextStyles.manrope(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2.5,
                              ),
                            ),
                          ),
                          const Gap(14),
                          Text(
                            banner.title,
                            style: AppTextStyles.notoSerif(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.15,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const Gap(10),
                          Text(
                            (banner.description?.isNotEmpty ?? false)
                                ? banner.description!
                                : 'Dirancang dengan detail presisi, dibuat untuk kenyamanan dan visual streetwear modern.',
                            style: AppTextStyles.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.88),
                              height: 1.6,
                            ),
                          ),
                          const Gap(22),
                          Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: LuxuryButton(
                                  label: (banner.ctaText != null && banner.ctaText!.isNotEmpty)
                                      ? banner.ctaText!
                                      : (banner.link != null && banner.link!.isNotEmpty)
                                          ? 'Lihat Koleksi'
                                          : 'Eksplor Katalog',
                                  icon: PhosphorIconsRegular.arrowUpRight,
                                  onPressed: () {
                                    final route = (banner.link != null && banner.link!.isNotEmpty)
                                        ? banner.link!
                                        : '/products';
                                    context.go(route);
                                  },
                                ),
                              ),
                              const Gap(10),
                              SizedBox(
                                width: double.infinity,
                                child: LuxuryButton(
                                  label: 'Cerita Brand',
                                  icon: PhosphorIconsRegular.images,
                                  variant: LuxuryButtonVariant.secondary,
                                  onPressed: () => context.go('/portfolio'),
                                ),
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
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      borderRadius: BorderRadius.circular(20),
                      blur: 10,
                      color: Colors.black.withValues(alpha: 0.2),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(banners.length, (index) {
                          final isActive = widget.currentBannerIndex == index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.only(left: index == 0 ? 0 : 6),
                            width: isActive ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              gradient: isActive ? AppGradients.premiumGold : null,
                              color: isActive ? null : Colors.white.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          );
                        }),
                      ),
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
