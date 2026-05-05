import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/widgets/app_image.dart';
import 'package:mitologi_clothing_mobile/features/cart/presentation/cart_view_model.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/order_step_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/product_pricing_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/site_settings_model.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/home_view_model.dart';
import 'package:mitologi_clothing_mobile/widgets/common/skeleton_loading.dart';
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
  double _appBarOpacity = 0;
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;
  HomeViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    log('HomeView: initState called', name: 'HOME');
    _scrollController.addListener(_onScroll);
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

  void _onScroll() {
    final offset = _scrollController.offset;
    final newOpacity = (offset / 100).clamp(0.0, 1.0);
    if (newOpacity != _appBarOpacity) {
      setState(() {
        _appBarOpacity = newOpacity;
      });
    }
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
      return Scaffold(
        backgroundColor: AppColors.background,
        body: _buildSkeletonLoading(),
      );
    }

    if (viewModel.error != null && viewModel.banners.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: _buildErrorState(context, viewModel),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: viewModel.fetchHomeData,
        displacement: 100,
        color: AppColors.primary,
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildHeroCarousel(viewModel),
                if (viewModel.isLoading)
                  const SliverToBoxAdapter(
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
                _buildIntro(theme),
                _buildFeaturesSection(viewModel),
                _buildCategories(viewModel),
                _buildSectionHeader(
                  context,
                  title: 'Best Sellers',
                  subtitle: 'Pilihan paling dicari minggu ini',
                  onSeeAll: () => context.push('/products'),
                ),
                _buildProductList(viewModel.bestSellers),
                _buildSectionHeader(
                  context,
                  title: 'New Arrivals',
                  subtitle: 'Rilis terbaru untuk tampilan harian',
                  onSeeAll: () => context.push('/products'),
                ),
                _buildProductList(viewModel.newArrivals),
                _buildAboutSection(viewModel),
                _buildPlastisolPricingSection(viewModel),
                _buildMaterialsSection(viewModel),
                _buildPrintingMethodsSection(viewModel),
                _buildWhyChooseUsSection(viewModel),
                _buildGuaranteeBonusSection(viewModel),
                _buildCategoryPricelistSection(viewModel),
                _buildOrderFlowSection(viewModel),
                _buildPortfolioSection(viewModel),
                _buildFacilitiesSection(viewModel),
                _buildTestimonialsSection(viewModel),
                _buildPartnersSection(viewModel),
                _buildCTASection(context, viewModel),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
            _buildDynamicAppBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicAppBar(BuildContext context) {
    final cartVM = context.watch<CartViewModel>();
    final cartCount =
        cartVM.cart?.items.fold<int>(0, (s, i) => s + i.quantity) ?? 0;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: MediaQuery.of(context).padding.top + 64,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: _appBarOpacity),
          boxShadow: _appBarOpacity > 0.5 ? [AppShadows.bottomNav] : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'MITOLOGI',
                style: TextStyle(
                  color: Color.lerp(
                      Colors.white, AppColors.primary, _appBarOpacity),
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: 3,
                ),
              ),
              const Spacer(),
              _buildAppBarAction(
                icon: PhosphorIconsRegular.magnifyingGlass,
                onPressed: () => context.push('/products'),
              ),
              const Gap(8),
              _buildAppBarAction(
                icon: PhosphorIconsRegular.shoppingCart,
                onPressed: () => context.push('/cart'),
                badgeCount: cartCount,
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
    int badgeCount = 0,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Color.lerp(
              Colors.white.withValues(alpha: 0.2),
              AppColors.surfaceContainerLow,
              _appBarOpacity,
            ),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              icon,
              color:
                  Color.lerp(Colors.white, AppColors.primary, _appBarOpacity),
              size: 24,
            ),
            onPressed: onPressed,
          ),
        ),
        if (badgeCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                badgeCount > 99 ? '99' : '$badgeCount',
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: AppColors.onSecondaryContainer,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeroCarousel(HomeViewModel viewModel) {
    if (viewModel.banners.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox(height: 300));
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
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    AppImage(
                      imageUrl: ApiConfig.buildImageUrl(banner.imageUrl),
                      fit: BoxFit.cover,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.4),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.85),
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
                          if (banner.subtitle.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                banner.subtitle.toUpperCase(),
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
                            banner.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                            ),
                          ),
                          if (banner.description != null &&
                              banner.description!.isNotEmpty) ...[
                            const Gap(12),
                            Text(
                              banner.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                          ],
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
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: viewModel.categories.length,
              itemBuilder: (context, index) {
                final category = viewModel.categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            context.push('/products?category=${category.slug}'),
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.outlineVariant, width: 1.5),
                            boxShadow: [AppShadows.cardSoft],
                          ),
                          child: Center(
                            child: category.iconUrl != null
                                ? AppImage(
                                    imageUrl: ApiConfig.buildImageUrl(
                                        category.iconUrl!),
                                    width: 40,
                                    height: 40)
                                : const Icon(PhosphorIconsRegular.tShirt,
                                    size: 30),
                          ),
                        ),
                      ),
                      const Gap(10),
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
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

  Widget _buildProductList(List<ProductModel> products) {
    if (products.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 310,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Container(
              width: 190,
              margin: const EdgeInsets.only(right: 16),
              child: ProductCard(product: product),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMaterialsSection(HomeViewModel viewModel) {
    final materials = viewModel.materials;
    if (materials.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeaderInline(
            context,
            title: 'Our Materials',
            subtitle: 'Premium fabrics for ultimate comfort',
            onSeeAll: () {},
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: materials.length,
              itemBuilder: (context, index) {
                final material = materials[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 280,
                    margin: const EdgeInsets.only(right: 16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AppImage(
                          imageUrl:
                              ApiConfig.buildImageUrl(material.image ?? ''),
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: AppGradients.heroOverlay,
                          ),
                        ),
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                material.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                material.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
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
          _buildSectionHeaderInline(
            context,
            title: 'Our Creations',
            subtitle: 'Collaborations and custom projects',
            onSeeAll: () => context.push('/portfolio'),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: portfolio.take(4).length,
            itemBuilder: (context, index) {
              final item = portfolio[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppImage(
                      imageUrl: ApiConfig.buildImageUrl(item.imageUrl),
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: AppGradients.heroOverlay,
                        ),
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
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

    final rawData = settings.pricingPlastisolData;
    List<PlastisolPriceItem> items = [];
    if (rawData is List) {
      items = rawData
          .map((e) => PlastisolPriceItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (items.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final rawAddons = settings.pricingAddonsData;
    List<PricingAddonItem> addons = [];
    if (rawAddons is List) {
      addons = rawAddons
          .map((e) => PricingAddonItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final features = settings.pricingFeaturesData;

    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.surface,
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(width: 32, height: 2, color: AppColors.secondary),
              const Gap(10),
              Text('PRICELIST',
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2)),
            ]),
            const Gap(12),
            const Text('Pricelist Sablon Plastisol',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const Gap(6),
            Text(
              'Harga terbaik untuk kualitas premium. Garansi detailing & ketepatan waktu.',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
            ),
            if (features.isNotEmpty) ...[
              const Gap(16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: features
                    .map((f) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  PhosphorIconsRegular.check,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              ),
                              const Gap(6),
                              Text(f.text.toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1)),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ],
            const Gap(24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final pkg = items[i];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: pkg.image != null && pkg.image!.isNotEmpty
                              ? AppImage(
                                  imageUrl: ApiConfig.buildImageUrl(pkg.image!),
                                  fit: BoxFit.contain,
                                )
                              : const Icon(
                                  PhosphorIconsRegular.tShirt,
                                  size: 48,
                                  color: Color(0xFFCBD5E1),
                                ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              pkg.title.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (pkg.minOrder != null &&
                                pkg.minOrder!.isNotEmpty)
                              Text(
                                pkg.minOrder!,
                                style: TextStyle(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.7),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Gap(8),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                        child: Column(
                          children: [
                            _priceRow('Pendek', pkg.short ?? '-'),
                            const Gap(4),
                            _priceRow('Panjang', pkg.long ?? '-'),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            if (addons.isNotEmpty) ...[
              const Gap(24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add-ons & Ketentuan',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900)),
                    const Gap(16),
                    ...addons.map((a) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(a.name,
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                              Text('+ Rp ${a.price}/pcs',
                                  style: TextStyle(
                                      color: AppColors.secondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
          Text(value,
              style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w900)),
        ],
      ),
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
    if (bonuses.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

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
            ...List.generate(bonuses.length, (i) {
              final b = bonuses[i];
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

    return _CategoryPricelistWidget(pricings: pricings);
  }

  Widget _buildOrderFlowSection(HomeViewModel viewModel) {
    final steps = viewModel.orderSteps;
    if (steps.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return _OrderFlowWidget(orderSteps: steps);
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

  Widget _buildSkeletonLoading() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          const HeroSkeleton(),
          const SizedBox(height: 24),
          const CategoriesSkeleton(),
          const SizedBox(height: 24),
          const ProductGridSkeleton(itemCount: 4),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, HomeViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(PhosphorIconsRegular.warningCircle,
              size: 64, color: AppColors.error),
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
          const Gap(32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: viewModel.fetchHomeData,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('RETRY CONNECTION'),
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
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final selected = active[_selectedTab.clamp(0, active.length - 1)];

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
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    if (!types.contains(_activeType)) {
      _activeType = types.first;
    }

    final tabLabels = {
      'langsung': 'Order Langsung',
      'ecommerce': 'Via E-Commerce',
    };

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
      ),
    );
  }
}
