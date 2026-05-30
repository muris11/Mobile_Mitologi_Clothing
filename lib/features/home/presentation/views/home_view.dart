import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/widgets/app_image.dart';
import 'package:mitologi_clothing_mobile/widgets/common/shimmer_image.dart';
import 'package:mitologi_clothing_mobile/features/cart/presentation/widgets/cart_icon_button.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/banner_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/category_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/order_step_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/portfolio_item_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/product_pricing_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/site_settings_model.dart';

import 'package:mitologi_clothing_mobile/features/home/presentation/home_view_model.dart';
import 'package:mitologi_clothing_mobile/widgets/shared/product_card.dart';
import 'package:mitologi_clothing_mobile/widgets/common/skeleton_loading.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:mitologi_clothing_mobile/core/utils/responsive_utils.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ScrollController _scrollController = ScrollController();
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;
  HomeViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    log('HomeView: initState called', name: 'HOME');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _viewModel = context.read<HomeViewModel>();
      if (!mounted) return;
      log('HomeView: postFrameCallback fired, calling fetchHomeData',
          name: 'HOME');
      _viewModel!.fetchHomeData().then((_) {
        log('HomeView: fetchHomeData completed — banners=${_viewModel!.banners.length}',
            name: 'HOME');
        if (mounted) _startBannerTimer();
      });
    });
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted || _viewModel == null) return;
      if (_viewModel!.banners.length <= 1) return;
      if (!_bannerController.hasClients) return;
      final next = (_currentBannerIndex + 1) % _viewModel!.banners.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final theme = Theme.of(context);
    log('HomeView: build — isLoading=${viewModel.isLoading} banners=${viewModel.banners.length} error=${viewModel.error}',
        name: 'HOME');

    if (viewModel.isLoading && viewModel.banners.isEmpty) {
      return const Scaffold(
        body: HomeSkeleton(),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.fetchHomeData,
      displacement: 100,
      color: AppColors.primary,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _buildHomeHeader(),
          ),
          SliverToBoxAdapter(
            child: _buildNewHeroCarousel(viewModel),
          ),
          if (viewModel.isLoading)
            const SliverToBoxAdapter(
              child: LinearProgressIndicator(minHeight: 2),
            ),
          _buildIntro(theme),
          _buildFeaturesSection(viewModel),
          _buildCategories(viewModel),
          _buildPortfolioSection(viewModel),
          if (viewModel.bestSellers.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              title: 'Best Sellers',
              subtitle: 'Pilihan paling dicari minggu ini',
              onSeeAll: () => context.push('/products'),
            ),
            _buildProductList(viewModel.bestSellers),
          ],
          if (viewModel.newArrivals.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              title: 'New Arrivals',
              subtitle: 'Koleksi terbaru minggu ini',
              onSeeAll: () => context.push('/products'),
            ),
            _buildProductList(viewModel.newArrivals),
          ],
          _buildWhyChooseUsSection(viewModel),
          _buildPlastisolPricingSection(viewModel),
          _buildGuaranteeBonusSection(viewModel),
        ],
      ),
    );
  }

  Widget _buildHomeHeader() {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      padding: EdgeInsets.fromLTRB(16, topPadding + 14, 16, 28),
      decoration: const BoxDecoration(
        gradient: AppGradients.navyGradient,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'MITOLOGI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'ID',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const CartIconButton(iconColor: Colors.white),
            ],
          ),
          const Gap(24),
          const Text(
            'Crafted apparel for bold stories.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const Gap(8),
          Text(
            'Temukan koleksi premium, custom printing, dan merchandise Mitologi.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.74),
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(18),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildNewHeroCarousel(HomeViewModel viewModel) {
    if (viewModel.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    final height = ResponsiveConfig.value(
      context: context,
      mobile: 200.0,
      tablet: 280.0,
      desktop: 280.0,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: SizedBox(
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          child: _buildHeroCarouselContent(viewModel),
        ),
      ),
    );
  }

  Widget _buildHeroCarouselContent(HomeViewModel viewModel) {
    if (viewModel.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _bannerController,
          itemCount: viewModel.banners.length,
          onPageChanged: (i) => setState(() => _currentBannerIndex = i),
          itemBuilder: (context, index) {
            final banner = viewModel.banners[index];
            final title = _heroTitle(banner);
            final subtitle = _heroSubtitle(banner);
            final description = _heroDescription(banner);
            final imageUrl = banner.imageUrl.trim();
            return Stack(
              fit: StackFit.expand,
              children: [
                _buildHeroBackdrop(),
                if (imageUrl.isNotEmpty)
                  AppImage(
                    imageUrl: ApiConfig.buildImageUrl(imageUrl),
                    fit: BoxFit.cover,
                  ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(
                            alpha:
                                0.55), // Dark top vignette to ensure transparent App Bar readability
                        Colors.black.withValues(
                            alpha:
                                0.1), // Clear center to showcase streetwear clothes
                        Colors.black.withValues(
                            alpha:
                                0.85), // Deep bottom dark block for text legibility
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 38,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: AppGradients.premiumGold,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.secondary.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Text(
                          subtitle.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.2,
                          ),
                        ),
                      ),
                      const Gap(8),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Gap(10),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const Gap(16),
                      // Single CTA sesuai spec (bukan dua tombol)
                      GestureDetector(
                        onTap: () => context.push('/products'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 11),
                          decoration: BoxDecoration(
                            gradient: AppGradients.premiumGold,
                            borderRadius:
                                BorderRadius.circular(AppBorderRadius.sm),
                          ),
                          child: Text(
                            (banner.link != null && banner.link!.isNotEmpty)
                                ? 'LIHAT KOLEKSI'
                                : 'SHOP NOW',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        Positioned(
          bottom: 16,
          right: 20,
          child: Row(
            children: List.generate(
              viewModel.banners.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: index == _currentBannerIndex ? 24 : 8,
                height: 6,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  gradient: index == _currentBannerIndex
                      ? AppGradients.premiumGold
                      : null,
                  color: index == _currentBannerIndex
                      ? null
                      : Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroBackdrop() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF000613),
            Color(0xFF001F3F),
            Color(0xFF735C00),
          ],
          stops: [0, 0.68, 1],
        ),
      ),
    );
  }

  String _heroTitle(BannerModel banner) {
    final title = banner.title.trim();
    return title.isNotEmpty ? title : 'Premium Quality\nCustom Clothing';
  }

  String _heroSubtitle(BannerModel banner) {
    final subtitle = banner.subtitle.trim();
    return subtitle.isNotEmpty ? subtitle : 'CUSTOM CLOTHING';
  }

  String _heroDescription(BannerModel banner) {
    final description = banner.description?.trim();
    if (description != null && description.isNotEmpty) return description;
    return 'Vendor konveksi terpercaya untuk kaos, hoodie, dan kebutuhan produksi apparel.';
  }

  Widget _buildIntro(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: AppGradients.premiumGold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Gap(12),
                Text(
                  'WHO WE ARE',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3.5,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const Gap(18),
            RichText(
              text: TextSpan(
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.3,
                  fontSize: 24,
                  color: AppColors.onBackground,
                ),
                children: const [
                  TextSpan(text: 'Premium '),
                  TextSpan(
                    text: 'mythology-inspired',
                    style: TextStyle(
                      color: AppColors.secondary,
                    ),
                  ),
                  TextSpan(text: ' apparel for the modern explorer.'),
                ],
              ),
            ),
            const Gap(12),
            Text(
              'Setiap benang ditenun untuk menceritakan kisah epik dari mitologi dunia, menggabungkan kenyamanan modern dengan estetika streetwear legendaris yang tak lekang oleh waktu.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.6,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () => context.push('/products'),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppBorderRadius.full),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.28),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              PhosphorIconsRegular.magnifyingGlass,
              size: 20,
              color: AppColors.outline,
            ),
            const Gap(10),
            Expanded(
              child: Text(
                'Cari kaos, hoodie, atau merchandise...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.outline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(HomeViewModel viewModel) {
    final features = viewModel.features;
    if (features.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Container(
        height: 180,
        margin: const EdgeInsets.only(top: 32),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return Container(
              width: 160,
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withValues(alpha: 0.03),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.04),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                        width: 1.0,
                      ),
                    ),
                    child: Icon(
                      _getFeatureIcon(feature.icon),
                      color: AppColors.secondary,
                      size: 22,
                    ),
                  ),
                  const Gap(16),
                  Text(
                    feature.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppColors.primary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    feature.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                      height: 1.4,
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
        return PhosphorIconsRegular.crown;
    }
  }

  Widget _buildCategories(HomeViewModel viewModel) {
    if (viewModel.categories.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeaderInline(
            context,
            title: 'Collections',
            subtitle: 'Browse by category',
            onSeeAll: () => context.push('/products'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: viewModel.categories.length,
              itemBuilder: (context, index) {
                final category = viewModel.categories[index];
                return _buildCollectionCard(category);
              },
            ),
          ),
          const Gap(24),
        ],
      ),
    );
  }

  Widget _buildCollectionCard(CategoryModel category) {
    final hasImage = category.iconUrl != null && category.iconUrl!.isNotEmpty;

    return GestureDetector(
      onTap: () => context.push('/products?category=${category.slug}'),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            )
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              AppImage(
                imageUrl: ApiConfig.buildImageUrl(category.iconUrl!),
                fit: BoxFit.cover,
                borderRadius: 0,
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.surfaceContainerLow,
                      AppColors.surfaceContainerHigh,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    PhosphorIconsRegular.image,
                    size: 28,
                    color: AppColors.outline,
                  ),
                ),
              ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    stops: const [0.4, 0.7, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'EXPLORE COLLECTION',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Gap(4),
                      const Icon(
                        PhosphorIconsRegular.arrowRight,
                        size: 10,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(List<ProductModel> products) {
    if (products.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 320,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return SizedBox(
              width: 175,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ProductCard(
                  product: product,
                  showBrand: false,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPortfolioSection(HomeViewModel viewModel) {
    final portfolio = viewModel.portfolioItems;
    if (portfolio.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 28, height: 3, color: AppColors.secondary),
                    const Gap(10),
                    Text(
                      'PORTFOLIO',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ],
                ),
                const Gap(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        'Hasil Karya\nTerbaik Kami',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/portfolio'),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(PhosphorIconsRegular.arrowRight,
                            size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 320,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: portfolio.length + 1,
              separatorBuilder: (_, __) => const Gap(16),
              itemBuilder: (context, index) {
                if (index == portfolio.length) {
                  return _buildPortfolioSeeAllCard();
                }
                return _buildPortfolioCard(portfolio[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioCard(PortfolioItemModel item) {
    // Strip HTML tags like <div> or <p> from raw descriptions
    final cleanDescription = item.description
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();

    return GestureDetector(
      onTap: () => context.push('/portfolio/${item.slug}'),
      child: SizedBox(
        width: 200,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppImage(
                imageUrl: ApiConfig.buildImageUrl(item.imageUrl),
                fit: BoxFit.cover,
                borderRadius: 0,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.category.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (cleanDescription.isNotEmpty) ...[
                      const Gap(4),
                      Text(
                        cleanDescription,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortfolioSeeAllCard() {
    return GestureDetector(
      onTap: () => context.push('/portfolio'),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                PhosphorIconsRegular.arrowRight,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const Gap(12),
            Text(
              'Lihat Semua',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Karya Kami',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlastisolPricingSection(HomeViewModel viewModel) {
    final settings = viewModel.siteSettings;
    if (settings == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final items = settings.plastisolPricing;
    if (items.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final addons = settings.pricingAddons;

    final features = settings.pricingFeaturesData;

    return SliverToBoxAdapter(
      child: Container(
        color: const Color(0xFFFAFAF9),
        padding: const EdgeInsets.fromLTRB(24, 56, 24, 56),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'PRICELIST',
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
            const Gap(12),
            const Text(
              'Sablon Plastisol',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
                height: 1.1,
              ),
            ),
            const Gap(12),
            Text(
              'Harga terbaik untuk kualitas premium. Garansi detailing & ketepatan waktu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            if (features.isNotEmpty) ...[
              const Gap(24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 24,
                runSpacing: 8,
                children: features
                    .map((f) => Text(
                          f.text.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ))
                    .toList(),
              ),
            ],
            const Gap(32),
            SizedBox(
              height: 340,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (ctx, i) {
                  final pkg = items[i];
                  return Container(
                    width: 220,
                    margin: EdgeInsets.only(
                      left: i == 0 ? 0 : 0,
                      right: i < items.length - 1 ? 16 : 0,
                    ),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        pkg.image != null && pkg.image!.isNotEmpty
                            ? ShimmerImage(
                                imageUrl: ApiConfig.buildImageUrl(pkg.image!),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : Container(
                                color: const Color(0xFFF1F5F9),
                                child: const Center(
                                  child: Icon(
                                    PhosphorIconsRegular.tShirt,
                                    size: 48,
                                    color: Color(0xFFCBD5E1),
                                  ),
                                ),
                              ),
                        if (pkg.popular)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.shadow.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Text(
                                'POPULER',
                                style: TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  const Color(0xFF1E293B)
                                      .withValues(alpha: 0.92),
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pkg.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    height: 1.2,
                                  ),
                                ),
                                if (pkg.minOrder != null &&
                                    pkg.minOrder!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.white
                                                .withValues(alpha: 0.3)),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        pkg.minOrder!,
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.7),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 10),
                                if (pkg.short != null) ...[
                                  _pricelistRow('Pendek', pkg.short!),
                                  const SizedBox(height: 4),
                                ],
                                if (pkg.long != null)
                                  _pricelistRow('Panjang', pkg.long!),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (addons.isNotEmpty) ...[
              const Gap(48),
              Row(
                children: [
                  Container(width: 20, height: 3, color: AppColors.secondary),
                  const Gap(10),
                  Text(
                    'LAYANAN TAMBAHAN',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const Gap(16),
              const Text(
                'Add-ons & Ketentuan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Gap(20),
              ...addons.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: Text(
                            a.name,
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              'Rp',
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Gap(1),
                            Text(
                              a.price.replaceAll(RegExp(r'^\+?\s*|\/pcs$'), ''),
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '/pcs',
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _pricelistRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'Rp',
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Gap(1),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'K',
              style: TextStyle(
                color: AppColors.secondary.withValues(alpha: 0.7),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWhyChooseUsSection(HomeViewModel viewModel) {
    final settings = viewModel.siteSettings;
    final guarantees = settings?.guaranteesData ?? [];
    if (guarantees.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final icons = [
      PhosphorIconsRegular.clock,
      PhosphorIconsRegular.thumbsUp,
      PhosphorIconsRegular.arrowsClockwise,
      PhosphorIconsRegular.shieldCheck,
      PhosphorIconsRegular.star,
      PhosphorIconsRegular.medal,
    ];

    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.surfaceContainerLow,
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 32, height: 2, color: AppColors.secondary),
                const Gap(10),
                Text(
                  'KENAPA MEMILIH KAMI?',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const Gap(12),
            const Text(
              'Standar Kualitas Terbaik',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const Gap(24),
            ...List.generate(guarantees.length, (i) {
              final g = guarantees[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        icons[i % icons.length],
                        color: AppColors.secondaryContainer,
                        size: 22,
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            g.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                          if (g.description.isNotEmpty) ...[
                            const Gap(4),
                            Text(
                              g.description,
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildGuaranteeBonusSection(HomeViewModel viewModel) {
    final settings = viewModel.siteSettings;
    final bonuses = settings?.garansiBonusData ?? [];
    final displayBonuses = bonuses.isNotEmpty
        ? bonuses
        : [
            const GuaranteeBonusItem(
              title: 'Garansi Hasil Sablon',
              description:
                  'Hasil sablon dijamin rapi dan presisi. Jika tidak sesuai, kami revisi gratis.',
            ),
            const GuaranteeBonusItem(
              title: 'Bebas Revisi Desain',
              description:
                  'Revisi desain tanpa batas sampai kamu benar-benar puas dengan hasilnya.',
            ),
            const GuaranteeBonusItem(
              title: 'Bonus Konsultasi Gratis',
              description:
                  'Tim kami siap membantu konsultasi kebutuhan sablon dan produksi kaos kamu.',
            ),
          ];

    final icons = [
      PhosphorIconsRegular.clock,
      PhosphorIconsRegular.shieldCheck,
      PhosphorIconsRegular.gift,
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 32, height: 2, color: AppColors.secondary),
                const Gap(10),
                Text(
                  'KEUNTUNGAN MEMILIH KAMI',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const Gap(12),
            const Text(
              'Garansi & Bonus Eksklusif',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const Gap(20),
            ...List.generate(displayBonuses.length, (i) {
              final b = displayBonuses[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.outlineVariant),
                  boxShadow: [AppShadows.cardSoft],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        icons[i % icons.length],
                        color: AppColors.secondaryContainer,
                        size: 22,
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                          if (b.description.isNotEmpty) ...[
                            const Gap(6),
                            Text(
                              b.description,
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onSeeAll,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onSeeAll,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(PhosphorIconsRegular.arrowRight, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeaderInline(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const Gap(4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: const Icon(PhosphorIconsRegular.arrowRight, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPricelistWidget extends StatefulWidget {
  final List<ProductPricingModel> pricings;
  const _CategoryPricelistWidget({required this.pricings});

  @override
  State<_CategoryPricelistWidget> createState() =>
      _CategoryPricelistWidgetState();
}

class _CategoryPricelistWidgetState extends State<_CategoryPricelistWidget> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final active = widget.pricings.where((p) => p.isActive).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    if (active.isEmpty) {
      return const SizedBox.shrink();
    }

    final selected = active[_selectedTab.clamp(0, active.length - 1)];

    return Container(
      color: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 32, height: 2, color: AppColors.secondary),
              const Gap(10),
              Text(
                'HARGA PRODUK',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const Gap(12),
          const Text(
            'Daftar Harga per Kategori',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const Gap(8),
          Text(
            'Harga sudah termasuk jasa sablon dan bahan baku',
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
          ),
          const Gap(24),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: active.length,
              itemBuilder: (ctx, i) {
                final isSelected = i == _selectedTab;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTab = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.outlineVariant,
                      ),
                    ),
                    child: Text(
                      active[i].categoryName,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Gap(20),
          ...selected.items.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                    Text(
                      item.priceRange,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )),
          if (selected.minOrder != null && selected.minOrder!.isNotEmpty) ...[
            const Gap(8),
            Row(
              children: [
                const Icon(PhosphorIconsRegular.info,
                    size: 14, color: AppColors.primary),
                const Gap(6),
                Text(
                  'Min. order: ${selected.minOrder}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderFlowWidget extends StatefulWidget {
  final List<OrderStepModel> orderSteps;
  const _OrderFlowWidget({required this.orderSteps});

  @override
  State<_OrderFlowWidget> createState() => _OrderFlowWidgetState();
}

class _OrderFlowWidgetState extends State<_OrderFlowWidget> {
  String _activeType = 'langsung';

  @override
  Widget build(BuildContext context) {
    final types = widget.orderSteps.map((s) => s.type).toSet().toList();
    final filtered = widget.orderSteps
        .where((s) => s.type == _activeType)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    if (types.isEmpty) {
      return const SizedBox.shrink();
    }

    if (!types.contains(_activeType)) {
      _activeType = types.first;
    }

    final tabLabels = {
      'langsung': 'Order Langsung',
      'ecommerce': 'Via E-Commerce',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 32, height: 2, color: AppColors.secondary),
              const Gap(10),
              Text(
                'CARA PEMESANAN',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const Gap(12),
          const Text(
            'Alur Pemesanan',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const Gap(20),
          Row(
            children: types.map((type) {
              final isSelected = type == _activeType;
              return GestureDetector(
                onTap: () => setState(() => _activeType = type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.outlineVariant,
                    ),
                  ),
                  child: Text(
                    tabLabels[type] ?? type,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const Gap(24),
          ...filtered.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            final isLast = i == filtered.length - 1;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${step.stepNumber}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: AppColors.outlineVariant,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                          ),
                        ),
                    ],
                  ),
                  const Gap(16),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(bottom: isLast ? 0 : 20),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                          if (step.description.isNotEmpty) ...[
                            const Gap(6),
                            Text(
                              step.description,
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
