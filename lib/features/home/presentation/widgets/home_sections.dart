import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';
import 'package:mitologi_clothing_mobile/core/utils/currency_formatter.dart';
import 'package:mitologi_clothing_mobile/core/utils/haptic_feedback.dart';
import 'package:mitologi_clothing_mobile/core/utils/responsive_utils.dart';
import 'package:mitologi_clothing_mobile/core/widgets/app_image.dart';
import 'package:mitologi_clothing_mobile/core/widgets/glass_container.dart';
import 'package:mitologi_clothing_mobile/core/widgets/luxury_button.dart';
import 'package:mitologi_clothing_mobile/core/widgets/premium_section_header.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/category_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/order_step_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/site_settings_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/testimonial_model.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/home_view_model.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';



class HomeFeaturedShowcase extends StatelessWidget {
  const HomeFeaturedShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final featured = context.select<HomeViewModel, ProductModel?>((vm) {
      if (vm.bestSellers.isNotEmpty) return vm.bestSellers.first;
      if (vm.newArrivals.isNotEmpty) return vm.newArrivals.first;
      return null;
    });

    if (featured == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
        child: GlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: BorderRadius.circular(30),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 680;
              final image = Expanded(
                flex: wide ? 1 : 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: AspectRatio(
                    aspectRatio: wide ? 1.0 : 1.1,
                    child: AppImage(
                      imageUrl: ApiConfig.buildImageUrl(featured.featuredImageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );

              final details = Expanded(
                flex: wide ? 1 : 0,
                child: Padding(
                  padding: EdgeInsets.only(left: wide ? 20 : 0, top: wide ? 0 : 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Koleksi Pilihan',
                        style: AppTextStyles.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.secondary,
                          letterSpacing: 2.1,
                        ),
                      ),
                      const Gap(10),
                      Text(
                        featured.name,
                        style: AppTextStyles.notoSerif(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          height: 1.12,
                        ),
                      ),
                      const Gap(10),
                      Text(
                        featured.description,
                        maxLines: wide ? 4 : 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                      const Gap(14),
                      Text(
                        CurrencyFormatter.formatIDR(featured.displayPrice),
                        style: AppTextStyles.notoSerif(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const Gap(18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          LuxuryButton(
                            label: 'Lihat Detail',
                            icon: PhosphorIconsRegular.arrowRight,
                            onPressed: () => context.push('/product/${featured.slug}'),
                          ),
                          LuxuryButton(
                            label: 'Katalog',
                            variant: LuxuryButtonVariant.ghost,
                            onPressed: () => context.go('/products'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );

              return wide
                  ? Row(children: [image, details])
                  : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [image, details]);
            },
          ),
        ),
      ),
    );
  }
}

class HomeCategoriesSection extends StatelessWidget {
  const HomeCategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = context.select<HomeViewModel, List>((vm) => vm.categories);
    if (categories.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final cardWidth = ResponsiveConfig.value(context: context, mobile: 140.0, tablet: 180.0, desktop: 220.0);
    final sectionHeight = ResponsiveConfig.value(context: context, mobile: 190.0, tablet: 230.0, desktop: 270.0);
    final maxItems = ResponsiveConfig.value(context: context, mobile: 8, tablet: 12, desktop: 15);
    final displayCategories = categories.take(maxItems).toList();

    return SliverToBoxAdapter(
      child: RepaintBoundary(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PremiumSectionHeader(
              eyebrow: 'Kurasi Utama',
              title: 'Eksplor Kategori',
              subtitle: 'Pilihan kategori yang dirancang untuk memudahkan pencarian gaya.',
            ),
            SizedBox(
              height: sectionHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: displayCategories.length,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: true,
                cacheExtent: cardWidth * 2,
                itemBuilder: (context, index) {
                  final category = displayCategories[index];
                  return Container(
                    width: cardWidth,
                    margin: EdgeInsets.only(right: index == displayCategories.length - 1 ? 0 : 14),
                    child: _CategoryCard(category: category),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final hasImage = category.iconUrl != null && category.iconUrl!.isNotEmpty;
    final fallbackIcons = [
      PhosphorIconsRegular.tShirt,
      PhosphorIconsRegular.hoodie,
      PhosphorIconsRegular.shoppingBag,
      PhosphorIconsRegular.tag,
      PhosphorIconsRegular.scissors,
      PhosphorIconsRegular.palette,
    ];

    return GestureDetector(
      onTap: () => context.go('/products?category=${category.slug}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              AppImage(
                imageUrl: ApiConfig.buildImageUrl(category.iconUrl!),
                fit: BoxFit.cover,
              )
            else
              Container(
                color: AppColors.secondarySoft,
                child: Center(
                  child: Icon(
                    fallbackIcons[category.id % fallbackIcons.length],
                    size: 48,
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.primary.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.26),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                ),
                child: Center(
                  child: Text(
                    category.name,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeProductSection extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final List<ProductModel> products;
  final bool alternateTone;

  const _HomeProductSection({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.products,
    this.alternateTone = false,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final cardWidth = ResponsiveConfig.value(context: context, mobile: 198.0, tablet: 240.0, desktop: 280.0);
    final sectionHeight = ResponsiveConfig.value(context: context, mobile: 340.0, tablet: 380.0, desktop: 420.0);
    final maxItems = ResponsiveConfig.value(context: context, mobile: 6, tablet: 8, desktop: 10);
    final displayProducts = products.take(maxItems).toList();

    return SliverToBoxAdapter(
      child: RepaintBoundary(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PremiumSectionHeader(
              eyebrow: eyebrow,
              title: title,
              subtitle: subtitle,
              actionLabel: 'Lihat Semua',
              onAction: () => context.go('/products'),
            ),
            SizedBox(
              height: sectionHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: displayProducts.length,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: true,
                cacheExtent: cardWidth * 2,
                itemBuilder: (context, index) {
                  final product = displayProducts[index];
                  return Container(
                    width: cardWidth,
                    margin: EdgeInsets.only(right: index == displayProducts.length - 1 ? 0 : 16),
                    child: _HomeProductCard(
                      product: product,
                      isInWishlist: false,
                      onWishlistToggle: null,
                    ),
                  );
                },
              ),
            ),
            if (alternateTone)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.secondarySoft.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          PhosphorIconsRegular.sealCheck,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          'Setiap rilisan baru dikurasi untuk menjaga kualitas visual, material, dan detail akhir.',
                          style: AppTextStyles.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class HomeBestSellersSection extends StatelessWidget {
  const HomeBestSellersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.select<HomeViewModel, List<ProductModel>>((vm) => vm.bestSellers);
    return _HomeProductSection(
      eyebrow: 'Paling Diminati',
      title: 'Paling Diminati',
      subtitle: 'Pilihan yang paling sering dicari untuk tampilan percaya diri.',
      products: products,
    );
  }
}

class HomeNewArrivalsSection extends StatelessWidget {
  const HomeNewArrivalsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.select<HomeViewModel, List<ProductModel>>((vm) => vm.newArrivals);
    return _HomeProductSection(
      eyebrow: 'Produk Terbaru',
      title: 'Produk Terbaru',
      subtitle: 'Rilis terbaru dengan karakter visual yang lebih tajam dan modern.',
      products: products,
      alternateTone: true,
    );
  }
}

class HomeStorytellingSection extends StatelessWidget {
  const HomeStorytellingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.select<HomeViewModel, SiteSettingsModel?>((vm) => vm.siteSettings);
    final features = context.select<HomeViewModel, List>((vm) => vm.features.take(3).toList());

    if ((settings?.aboutDescription1?.isEmpty ?? true) && features.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          borderRadius: BorderRadius.circular(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cerita Mitologi',
                style: AppTextStyles.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.secondary,
                  letterSpacing: 2.2,
                ),
              ),
              const Gap(10),
              Text(
                settings?.aboutHeadline ?? 'Dirancang untuk karya yang terasa lebih personal.',
                style: AppTextStyles.notoSerif(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  height: 1.15,
                ),
              ),
              const Gap(12),
              Text(
                settings?.aboutDescription1 ??
                    'Mitologi Clothing menghadirkan pendekatan visual yang rapi, detail yang matang, dan kualitas yang siap dipakai untuk berbagai kebutuhan.',
                style: AppTextStyles.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurfaceVariant,
                  height: 1.7,
                ),
              ),
              if (features.isNotEmpty) ...[
                const Gap(20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: features
                      .map(
                        (feature) => GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          borderRadius: BorderRadius.circular(18),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                PhosphorIconsRegular.star,
                                size: 16,
                                color: AppColors.secondary,
                              ),
                              const Gap(8),
                              Text(
                                feature.title,
                                style: AppTextStyles.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class HomePlastisolPricingSection extends StatelessWidget {
  const HomePlastisolPricingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final pricingData = context.select<HomeViewModel, List>((vm) => vm.siteSettings?.plastisolPricing ?? []);
    if (pricingData.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final cardWidth = ResponsiveConfig.value(context: context, mobile: 180.0, tablet: 220.0, desktop: 260.0);
    final sectionHeight = ResponsiveConfig.value(context: context, mobile: 260.0, tablet: 300.0, desktop: 340.0);
    final maxItems = ResponsiveConfig.value(context: context, mobile: 6, tablet: 8, desktop: 10);
    final displayItems = pricingData.take(maxItems).toList();

    return SliverToBoxAdapter(
      child: RepaintBoundary(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PremiumSectionHeader(
              eyebrow: 'Pricelist',
              title: 'Sablon Plastisol',
              subtitle: 'Harga terbaik untuk kualitas premium. Garansi detailing dan ketepatan waktu.',
            ),
            SizedBox(
              height: sectionHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: displayItems.length,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: true,
                cacheExtent: cardWidth * 2,
                itemBuilder: (context, index) {
                  final item = displayItems[index] as Map;
                  return Container(
                    width: cardWidth,
                    margin: EdgeInsets.only(right: index == displayItems.length - 1 ? 0 : 14),
                    child: _PlastisolPricingCard(item: item, index: index),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Text(
                'Harga yang tertera adalah estimasi dasar. Final pricing dapat berubah sesuai tingkat kerumitan desain.',
                style: AppTextStyles.manrope(fontSize: 12, color: AppColors.outline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlastisolPricingCard extends StatelessWidget {
  final Map item;
  final int index;

  const _PlastisolPricingCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final tierIcons = [
      PhosphorIconsRegular.paintBucket,
      PhosphorIconsRegular.paintBrushBroad,
      PhosphorIconsRegular.palette,
      PhosphorIconsRegular.drop,
      PhosphorIconsRegular.waves,
    ];

    final imageUrl = item['image_url'] as String? ?? item['imageUrl'] as String? ?? item['image'] as String?;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasImage)
            AppImage(
              imageUrl: ApiConfig.buildImageUrl(imageUrl),
              fit: BoxFit.cover,
            )
          else
            Container(
              color: AppColors.surfaceContainerLow,
              child: Center(
                child: Icon(
                  tierIcons[index % tierIcons.length],
                  size: 48,
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.primary.withValues(alpha: 0.88),
                ],
              ),
            ),
          ),
          if (item['popular'] == true)
            Positioned(
              left: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'POPULER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.26),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item['title'] ?? 'Tier ${index + 1}',
                    style: AppTextStyles.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Gap(8),
                  Row(
                    children: [
                      Text('Pendek ', style: AppTextStyles.manrope(fontSize: 10, color: Colors.white.withValues(alpha: 0.7))),
                      Text('${item['short'] ?? '-'}K', style: AppTextStyles.notoSerif(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.secondaryContainer)),
                    ],
                  ),
                  const Gap(3),
                  Row(
                    children: [
                      Text('Panjang ', style: AppTextStyles.manrope(fontSize: 10, color: Colors.white.withValues(alpha: 0.7))),
                      Text('${item['long'] ?? '-'}K', style: AppTextStyles.notoSerif(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.secondaryContainer)),
                    ],
                  ),
                  if (item['minOrder'] != null) ...[
                    const Gap(6),
                    Text(
                      'Min. ${item['minOrder']} pcs',
                      style: AppTextStyles.manrope(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.6)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomePortfolioSection extends StatelessWidget {
  const HomePortfolioSection({super.key});

  @override
  Widget build(BuildContext context) {
    final portfolioItems = context.select<HomeViewModel, List>((vm) => vm.portfolioItems);
    if (portfolioItems.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final cardWidth = ResponsiveConfig.value(context: context, mobile: 280.0, tablet: 340.0, desktop: 400.0);
    final sectionHeight = ResponsiveConfig.value(context: context, mobile: 280.0, tablet: 320.0, desktop: 360.0);
    final maxItems = ResponsiveConfig.value(context: context, mobile: 5, tablet: 8, desktop: 10);
    final displayItems = portfolioItems.take(maxItems).toList();

    return SliverToBoxAdapter(
      child: RepaintBoundary(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PremiumSectionHeader(
              eyebrow: 'Visual Story',
              title: 'Cerita Visual & Portfolio',
              subtitle: 'Potret karya yang memperlihatkan karakter, detail, dan kualitas hasil akhir.',
              actionLabel: 'Portfolio',
              onAction: () => context.go('/portfolio'),
            ),
            SizedBox(
              height: sectionHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: displayItems.length,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: true,
                cacheExtent: cardWidth * 2,
                itemBuilder: (context, index) {
                  final item = displayItems[index];
                  return Container(
                    width: cardWidth,
                    margin: EdgeInsets.only(right: index == displayItems.length - 1 ? 0 : 16),
                    child: GestureDetector(
                      onTap: () => context.push('/portfolio/${item.slug}'),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            AppImage(
                              imageUrl: ApiConfig.buildImageUrl(item.imageUrl),
                              fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    AppColors.primary.withValues(alpha: 0.82),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 18,
                              right: 18,
                              bottom: 18,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.26),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.category,
                                      style: AppTextStyles.manrope(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.secondaryContainer,
                                        letterSpacing: 1.8,
                                      ),
                                    ),
                                    const Gap(6),
                                    Text(
                                      item.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.notoSerif(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        height: 1.15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeTestimonialsSection extends StatelessWidget {
  const HomeTestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final testimonials = context.select<HomeViewModel, List<TestimonialModel>>((vm) => vm.testimonials);
    if (testimonials.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final cardWidth = ResponsiveConfig.value(context: context, mobile: 310.0, tablet: 360.0, desktop: 400.0);
    final sectionHeight = ResponsiveConfig.value(context: context, mobile: 210.0, tablet: 240.0, desktop: 270.0);
    final maxItems = ResponsiveConfig.value(context: context, mobile: 5, tablet: 8, desktop: 10);
    final displayItems = testimonials.take(maxItems).toList();

    return SliverToBoxAdapter(
      child: RepaintBoundary(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PremiumSectionHeader(
              eyebrow: 'Suara Pelanggan',
              title: 'Kepercayaan yang Terlihat',
              subtitle: 'Respons pelanggan yang memperkuat rasa aman saat memilih Mitologi.',
            ),
            SizedBox(
              height: sectionHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: displayItems.length,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: true,
                cacheExtent: cardWidth * 2,
                itemBuilder: (context, index) {
                  final testimonial = displayItems[index];
                  return Container(
                    width: cardWidth,
                    margin: EdgeInsets.only(right: index == displayItems.length - 1 ? 0 : 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.55)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(
                              testimonial.rating.clamp(0, 5).toInt(),
                              (_) => const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Icon(
                                  PhosphorIconsFill.star,
                                  size: 14,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                          ),
                          const Gap(14),
                          Expanded(
                            child: Text(
                              '"${testimonial.content}"',
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.onSurfaceVariant,
                                height: 1.65,
                              ),
                            ),
                          ),
                          const Gap(12),
                          Text(
                            testimonial.name,
                            style: AppTextStyles.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          if (testimonial.role.isNotEmpty)
                            Text(
                              testimonial.role,
                              style: AppTextStyles.manrope(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeWhyChooseUsSection extends StatelessWidget {
  const HomeWhyChooseUsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final guarantees = context.select<HomeViewModel, List>((vm) => vm.siteSettings?.guaranteesData ?? []);
    if (guarantees.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final icons = [PhosphorIconsRegular.clock, PhosphorIconsRegular.thumbsUp, PhosphorIconsRegular.arrowsClockwise];

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PremiumSectionHeader(
            eyebrow: 'Kenapa Memilih Kami?',
            title: 'Standar Kualitas Terbaik',
            subtitle: 'Komitmen kami adalah memberikan hasil terbaik dengan standar produksi profesional.',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: List.generate(guarantees.length, (i) {
                final item = guarantees[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(20),
                    borderRadius: BorderRadius.circular(24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.secondarySoft,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(icons[i % icons.length], size: 22, color: AppColors.primary),
                        ),
                        const Gap(16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: AppTextStyles.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
                              ),
                              const Gap(4),
                              Text(
                                item.description,
                                style: AppTextStyles.manrope(fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.6, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeGuaranteeBonusSection extends StatelessWidget {
  const HomeGuaranteeBonusSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bonusData = context.select<HomeViewModel, List>((vm) => vm.siteSettings?.garansiBonusData ?? []);

    final fallbackData = [
      GuaranteeBonusItem(title: 'Garansi Tepat Waktu', description: 'Jaminan pengerjaan tepat waktu sesuai deadline yang disepakati. Jika terlambat, kami berikan voucher diskon untuk order selanjutnya.'),
      GuaranteeBonusItem(title: 'Garansi Kualitas', description: 'Perbaikan atau refund 100% jika produk cacat, sablon luntur, atau spesifikasi tidak sesuai dengan kesepakatan order.'),
      GuaranteeBonusItem(title: 'Bonus Order > 100 pcs', description: 'Gratis 1 pcs kaos sablon eksklusif, free stickers premium, dan special packaging box untuk setiap pemesanan di atas 100 pcs.'),
    ];

    final data = bonusData.isNotEmpty ? bonusData : fallbackData;
    final icons = [PhosphorIconsRegular.clock, PhosphorIconsRegular.shieldCheck, PhosphorIconsRegular.gift];

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PremiumSectionHeader(
            eyebrow: 'Keuntungan Memilih Kami',
            title: 'Garansi & Bonus Eksklusif',
            subtitle: 'Kami tidak hanya berkomitmen pada kualitas, tapi juga memberikan apresiasi lebih untuk setiap pesanan Anda.',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: List.generate(data.length, (i) {
                final item = data[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(20),
                    borderRadius: BorderRadius.circular(24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.secondarySoft,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(icons[i % icons.length], size: 22, color: AppColors.secondary),
                        ),
                        const Gap(16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: AppTextStyles.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
                              ),
                              const Gap(4),
                              Text(
                                item.description,
                                style: AppTextStyles.manrope(fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.6, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class HomePartnerClientsSection extends StatelessWidget {
  const HomePartnerClientsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final partners = context.select<HomeViewModel, List>((vm) => vm.partners);
    if (partners.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final cardWidth = ResponsiveConfig.value(context: context, mobile: 120.0, tablet: 150.0, desktop: 180.0);
    final sectionHeight = ResponsiveConfig.value(context: context, mobile: 80.0, tablet: 100.0, desktop: 120.0);
    final maxItems = ResponsiveConfig.value(context: context, mobile: 8, tablet: 12, desktop: 15);
    final displayPartners = partners.take(maxItems).toList();

    return SliverToBoxAdapter(
      child: RepaintBoundary(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PremiumSectionHeader(
              eyebrow: 'Trusted By',
              title: 'Klien & Partner Kami',
              subtitle: 'Dipercaya oleh berbagai instansi, komunitas, dan brand ternama.',
            ),
            SizedBox(
              height: sectionHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: displayPartners.length,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: true,
                itemBuilder: (context, index) {
                  final partner = displayPartners[index];
                  return Container(
                    width: cardWidth,
                    margin: const EdgeInsets.only(right: 14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.55)),
                      ),
                      child: Center(
                        child: partner.logo.isNotEmpty
                            ? AppImage(
                                imageUrl: ApiConfig.buildImageUrl(partner.logo),
                                fit: BoxFit.contain,
                              )
                            : Text(
                                partner.name,
                                style: AppTextStyles.manrope(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isInWishlist;
  final VoidCallback? onWishlistToggle;

  const _HomeProductCard({
    required this.product,
    required this.isInWishlist,
    this.onWishlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppHaptics.tap();
        context.push('/product/${product.slug}');
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppImage(
              imageUrl: ApiConfig.buildImageUrl(product.featuredImageUrl),
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.primary.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  AppHaptics.lightImpact();
                  onWishlistToggle?.call();
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isInWishlist ? PhosphorIconsFill.heart : PhosphorIconsRegular.heart,
                    color: isInWishlist ? const Color(0xFFE53935) : Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
            if (product.onSale)
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'PILIHAN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.26),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (product.vendor != null)
                      Text(
                        product.vendor!.toUpperCase(),
                        style: AppTextStyles.manrope(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: AppColors.secondaryContainer,
                          letterSpacing: 1.8,
                        ),
                      ),
                    const Gap(4),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.notoSerif(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                    const Gap(6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          CurrencyFormatter.formatIDR(product.displayPrice),
                          style: AppTextStyles.notoSerif(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.secondaryContainer,
                          ),
                        ),
                        if (product.totalSold > 0)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(PhosphorIconsFill.fire, size: 12, color: AppColors.secondary),
                              const Gap(3),
                              Text(
                                '${product.totalSold} terjual',
                                style: AppTextStyles.manrope(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderFlowSectionWidget extends StatelessWidget {
  final List<OrderStepModel> steps;
  final String activeFlowType;
  final Function(String) onFlowTypeChanged;

  const OrderFlowSectionWidget({
    super.key,
    required this.steps,
    required this.activeFlowType,
    required this.onFlowTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filteredSteps = steps
        .where((step) => step.type == activeFlowType || (step.type.isEmpty && activeFlowType == 'langsung'))
        .toList()
      ..sort((a, b) => a.stepNumber.compareTo(b.stepNumber));

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PremiumSectionHeader(
              eyebrow: 'Langkah Pemesanan',
              title: 'Alur Belanja yang Jelas',
              subtitle: 'Ringkas, terarah, dan mudah dipahami sebelum kamu memulai pesanan.',
              padding: EdgeInsets.zero,
            ),
            const Gap(18),
            GlassContainer(
              padding: const EdgeInsets.all(18),
              borderRadius: BorderRadius.circular(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _OrderFlowTab(type: 'langsung', label: 'Order Langsung', activeType: activeFlowType, onChanged: onFlowTypeChanged)),
                        Expanded(child: _OrderFlowTab(type: 'ecommerce', label: 'Via E-Commerce', activeType: activeFlowType, onChanged: onFlowTypeChanged)),
                      ],
                    ),
                  ),
                  const Gap(18),
                  if (filteredSteps.isEmpty)
                    Text(
                      'Belum ada langkah pemesanan untuk tipe ini.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant,
                      ),
                    )
                  else
                    ...filteredSteps.asMap().entries.map((entry) {
                      final index = entry.key;
                      final step = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(bottom: index == filteredSteps.length - 1 ? 0 : 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${index + 1}',
                                style: AppTextStyles.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Gap(14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    step.title,
                                    style: AppTextStyles.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const Gap(4),
                                  Text(
                                    step.description,
                                    style: AppTextStyles.manrope(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.onSurfaceVariant,
                                      height: 1.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderFlowTab extends StatelessWidget {
  final String type;
  final String label;
  final String activeType;
  final Function(String) onChanged;

  const _OrderFlowTab({
    required this.type,
    required this.label,
    required this.activeType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = activeType == type;
    return GestureDetector(
      onTap: () => onChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isActive ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
