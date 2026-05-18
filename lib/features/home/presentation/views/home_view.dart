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
import 'package:mitologi_clothing_mobile/widgets/product/product_card.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

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

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          RefreshIndicator(
            onRefresh: viewModel.fetchHomeData,
            displacement: 100,
            color: AppColors.primary,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(height: MediaQuery.of(context).padding.top + 64),
                ),
                _buildHeroCarousel(viewModel),
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
                _buildAboutSection(viewModel),
              ],
            ),
          ),
          _buildDynamicAppBar(context),
        ],
      ),
    );
  }

  Widget _buildDynamicAppBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: MediaQuery.of(context).padding.top + 64,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [AppShadows.bottomNav],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'MITOLOGI',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: SizedBox(
                      width: 3,
                      height: 3,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      'ID',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _buildAppBarAction(
                icon: PhosphorIconsRegular.magnifyingGlass,
                onPressed: () => context.push('/products'),
              ),
              const Gap(8),
              SizedBox(
                width: 40,
                height: 40,
                child: CartIconButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarAction({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.primary, size: 22),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildHeroCarousel(HomeViewModel viewModel) {
    if (viewModel.banners.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 520,
        child: Stack(
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
                            Colors.black.withValues(alpha: 0.48),
                            Colors.black.withValues(alpha: 0.18),
                            Colors.black.withValues(alpha: 0.88),
                          ],
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: 70,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              subtitle.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const Gap(12),
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                            ),
                          ),
                          const Gap(12),
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.84),
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                          const Gap(20),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => context.push('/products'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    (banner.link != null &&
                                            banner.link!.isNotEmpty)
                                        ? 'LIHAT KOLEKSI'
                                        : 'SHOP NOW',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                              const Gap(12),
                              GestureDetector(
                                onTap: () => context.push('/products'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white38),
                                  ),
                                  child: const Text(
                                    'KATALOG',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            Positioned(
              bottom: 24,
              left: 24,
              child: Row(
                children: List.generate(
                  viewModel.banners.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: index == _currentBannerIndex ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: index == _currentBannerIndex
                          ? AppColors.secondary
                          : Colors.white38,
                      borderRadius: BorderRadius.circular(4),
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

  Widget _buildFallbackHero() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 360,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildHeroBackdrop(),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.12),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.24),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 56,
              child: _buildHeroCopy(
                subtitle: 'CUSTOM CLOTHING',
                title: 'Premium Quality\nCustom Clothing',
                description:
                    'Vendor konveksi terpercaya untuk kaos, hoodie, dan kebutuhan produksi apparel.',
                primaryLabel: 'SHOP NOW',
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildHeroCopy({
    required String subtitle,
    required String title,
    required String description,
    required String primaryLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            subtitle.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const Gap(12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        const Gap(12),
        Text(
          description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.84),
            fontSize: 14,
            height: 1.45,
          ),
        ),
        const Gap(18),
        GestureDetector(
          onTap: () => context.push('/products'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              primaryLabel,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ],
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
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 2,
                  color: AppColors.secondary,
                ),
                const Gap(12),
                Text(
                  'WHO WE ARE',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const Gap(16),
            Text(
              'Premium mythology-inspired apparel for the modern explorer.',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.2,
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
                boxShadow: [AppShadows.cardSoft],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getFeatureIcon(feature.icon),
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const Gap(16),
                  Text(
                    feature.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    feature.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
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
        return PhosphorIconsRegular.sparkle;
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
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppShadows.cardSoft],
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
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                    stops: [0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(4),
                  Text(
                    'Lihat Produk →',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
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
            return GestureDetector(
              onTap: () => context.push('/product/${product.slug}'),
              child: Container(
                width: 220,
                margin: const EdgeInsets.only(right: 16),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ShimmerImage(
                      imageUrl: ApiConfig.buildImageUrl(product.featuredImageUrl),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.85),
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatPrice(product.displayPrice),
                              style: const TextStyle(
                                color: Color(0xFFB9955B),
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (product.onSale)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xD6142033),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'PROMO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),
                  ],
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
                        child: const Icon(PhosphorIconsRegular.arrowRight, size: 20),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB9955B),
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
                    if (item.description.isNotEmpty) ...[
                      const Gap(4),
                      Text(
                        item.description,
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

  Widget _buildFacilitiesSection(HomeViewModel viewModel) {
    final facilities = viewModel.facilities;
    if (facilities.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeaderInline(
            context,
            title: 'Production House',
            subtitle: 'Behind the scenes of our quality',
            onSeeAll: () => context.push('/layanan'),
          ),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: facilities.length,
              itemBuilder: (context, index) {
                final facility = facilities[index];
                return Container(
                  width: 300,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [AppShadows.cardSoft],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(24)),
                        child: AppImage(
                          imageUrl: ApiConfig.buildImageUrl(facility.image),
                          width: 120,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                facility.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                              const Gap(8),
                              Text(
                                facility.description,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 11,
                                  height: 1.4,
                                ),
                              ),
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
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection(HomeViewModel viewModel) {
    final testimonials = viewModel.testimonials;
    if (testimonials.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeaderInline(
            context,
            title: 'Testimoni',
            subtitle: 'Kata mereka tentang Mitologi',
            onSeeAll: () {},
          ),
          SizedBox(
            height: 230,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: testimonials.length,
              itemBuilder: (context, index) {
                final testimonial = testimonials[index];
                return Container(
                  width: 300,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.outlineVariant),
                    boxShadow: [AppShadows.cardSoft],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(
                            5,
                            (i) => Icon(
                                  i < testimonial.rating.round()
                                      ? PhosphorIconsFill.star
                                      : PhosphorIconsRegular.star,
                                  size: 14,
                                  color: i < testimonial.rating.round()
                                      ? AppColors.secondaryContainer
                                      : AppColors.outlineVariant,
                                )),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          '"${testimonial.content}"',
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.onSurface,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const Gap(12),
                      const Divider(height: 1),
                      const Gap(12),
                      Row(
                        children: [
                          if (testimonial.avatarUrl != null &&
                              testimonial.avatarUrl!.isNotEmpty)
                            ClipOval(
                              child: AppImage(
                                imageUrl: ApiConfig.buildImageUrl(
                                    testimonial.avatarUrl!),
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                testimonial.name.isNotEmpty
                                    ? testimonial.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          const Gap(10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  testimonial.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  testimonial.role,
                                  style: TextStyle(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnersSection(HomeViewModel viewModel) {
    final partners = viewModel.partners;
    if (partners.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
            child: Text(
              'TRUSTED BY',
              style: TextStyle(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: partners.length,
              itemBuilder: (context, index) {
                final partner = partners[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 32),
                  child: Opacity(
                    opacity: 0.6,
                    child: AppImage(
                      imageUrl: ApiConfig.buildImageUrl(partner.logo),
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection(BuildContext context, HomeViewModel viewModel) {
    final settings = viewModel.siteSettings;
    final title = settings?.ctaTitle ?? 'Pesan Sekarang';
    final subtitle = settings?.ctaSubtitle ??
        'Hubungi kami untuk pemesanan custom clothing terbaik.';
    final btnText = settings?.ctaButtonText ?? 'LIHAT KOLEKSI';

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: AppGradients.primaryGradient,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [AppShadows.cardElevated],
          ),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'MITOLOGI CLOTHING',
                  style: TextStyle(
                    color: AppColors.secondaryContainer,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const Gap(16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const Gap(10),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const Gap(24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => context.push('/products'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryContainer,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      btnText,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 0.5),
                    ),
                  ),
                  if (settings?.contactWhatsapp != null &&
                      settings!.contactWhatsapp!.isNotEmpty) ...[
                    const Gap(12),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/kontak'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white38),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(PhosphorIconsRegular.whatsappLogo,
                          size: 18),
                      label: const Text(
                        'WhatsApp',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ],
                ],
              ),
              const Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => context.push('/tentang-kami'),
                    child: Text(
                      'Tentang Kami',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text('·',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 12)),
                  TextButton(
                    onPressed: () => context.push('/kontak'),
                    child: Text(
                      'Kontak',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text('·',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 12)),
                  TextButton(
                    onPressed: () => context.push('/portfolio'),
                    child: Text(
                      'Portofolio',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
                                    color: AppColors.shadow.withValues(alpha: 0.2),
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
                                  const Color(0xFF1E293B).withValues(alpha: 0.92),
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
                                            color: Colors.white.withValues(alpha: 0.3)),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        pkg.minOrder!,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.7),
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
                                color: Color(0xFFB9955B),
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
                color: Color(0xFFB9955B),
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

  Widget _buildPrintingMethodsSection(HomeViewModel viewModel) {
    final methods = viewModel.printingMethods;
    if (methods.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(width: 32, height: 2, color: AppColors.secondary),
              const Gap(10),
              Text('EKSPLORASI TEKNIK SABLON',
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2)),
            ]),
            const Gap(12),
            const Text('Pilih Sesuai Kebutuhan Anda',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const Gap(8),
            Text(
              'Berbagai teknik printing berkualitas tinggi, dari sablon manual legendaris hingga digital modern.',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
            ),
            const Gap(24),
            ...methods.map((method) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (method.image.isNotEmpty)
                        SizedBox(
                          height: 180,
                          width: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              AppImage(
                                imageUrl: ApiConfig.buildImageUrl(method.image),
                                fit: BoxFit.cover,
                              ),
                              DecoratedBox(
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
                                bottom: 12,
                                left: 16,
                                right: 16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      method.name,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900),
                                    ),
                                    if (method.priceRange.isNotEmpty)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border:
                                              Border.all(color: Colors.white38),
                                        ),
                                        child: Text(method.priceRange,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700)),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (method.image.isEmpty) ...[
                              Text(method.name,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900)),
                              if (method.priceRange.isNotEmpty) ...[
                                const Gap(4),
                                Text(method.priceRange,
                                    style: TextStyle(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13)),
                              ],
                              const Gap(8),
                            ],
                            Text(method.description,
                                style: TextStyle(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 13,
                                    height: 1.5)),
                            if (method.pros.isNotEmpty) ...[
                              const Gap(12),
                              Text('Keunggulan',
                                  style: TextStyle(
                                      color: AppColors.secondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1)),
                              const Gap(8),
                              ...method.pros.map((pro) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(PhosphorIconsRegular.checkCircle,
                                            size: 14, color: AppColors.primary),
                                        const Gap(8),
                                        Expanded(
                                          child: Text(pro,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500)),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(HomeViewModel viewModel) {
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
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [AppShadows.cardSoft],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 32, height: 2, color: AppColors.secondary),
                const Gap(10),
                Text(
                  'TENTANG KAMI',
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
            Text(
              headline,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                height: 1.2,
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
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            if (desc2.isNotEmpty) ...[
              const Gap(8),
              Text(
                desc2,
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ],
            if (year.isNotEmpty) ...[
              const Gap(20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
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
              description: 'Hasil sablon dijamin rapi dan presisi. Jika tidak sesuai, kami revisi gratis.',
            ),
            const GuaranteeBonusItem(
              title: 'Bebas Revisi Desain',
              description: 'Revisi desain tanpa batas sampai kamu benar-benar puas dengan hasilnya.',
            ),
            const GuaranteeBonusItem(
              title: 'Bonus Konsultasi Gratis',
              description: 'Tim kami siap membantu konsultasi kebutuhan sablon dan produksi kaos kamu.',
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

  Widget _buildCategoryPricelistSection(HomeViewModel viewModel) {
    final pricings = viewModel.productPricings;
    if (pricings.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(child: _CategoryPricelistWidget(pricings: pricings));
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

  Widget _buildErrorState(BuildContext context, HomeViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            PhosphorIconsRegular.warningCircle,
            size: 64,
            color: AppColors.error,
          ),
          const Gap(24),
          const Text(
            'Failed to load home',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const Gap(12),
          Text(
            viewModel.error ?? 'Connection timeout. Please check your network.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
          const Gap(16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'API: ${ApiConfig.baseUrl}/landing-page\n\nIf this persists, check:\n1. CORS headers on backend\n2. Network connectivity\n3. Open DevTools → Console for logs',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const Gap(32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: viewModel.fetchHomeData,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('RETRY CONNECTION'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            PhosphorIconsRegular.database,
            size: 64,
            color: AppColors.outline,
          ),
          const Gap(24),
          const Text(
            'Belum Ada Data',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const Gap(12),
          Text(
            'Halaman masih kosong. Pastikan backend aktif dan bisa dijangkau.\n\n'
            'Base URL: ${ApiConfig.baseUrl}',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
          ),
          const Gap(32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => context.read<HomeViewModel>().fetchHomeData(),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('MUAT ULANG'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    final whole = price.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < whole.length; i++) {
      final reverseIndex = whole.length - i;
      buffer.write(whole[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp $buffer';
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 8),
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
                        color:
                            isSelected ? Colors.white : AppColors.onSurface,
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
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
