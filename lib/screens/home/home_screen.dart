import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/product_provider.dart';
import '../../utils/debouncer.dart';
import '../../widgets/common/custom_pull_to_refresh.dart';
import '../../widgets/common/scroll_reveal.dart';
import '../../widgets/common/success_animations.dart';
import 'sections/index.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadHomeData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _searchDebouncer.run(() {
      if (query.isNotEmpty) {
        context.push('/products?search=${Uri.encodeComponent(query)}');
      }
    });
  }

  Widget _wrapWithReveal(Widget child) {
    return SliverToBoxAdapter(
      child: ScrollReveal(
        animation: ScrollRevealAnimation.fadeUp,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          return CustomPullToRefresh(
            onRefresh: () => provider.loadHomeData(),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const AppBarSection(),
                _buildSearchSection(),
                ..._buildConditionalSections(provider),
                _wrapWithReveal(const FeaturesSection()),
                _wrapWithReveal(const GuaranteesSection()),
                _wrapWithReveal(const OrderStepsSection()),
                _wrapWithReveal(const TestimonialsSection()),
                _wrapWithReveal(const PortfolioSection()),
                _wrapWithReveal(const TeamMembersSection()),
                _wrapWithReveal(MaterialsSection()),
                _wrapWithReveal(const CTABannerSection()),
                const SliverToBoxAdapter()
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: SearchBar(
          controller: _searchController,
          onChanged: _onSearchChanged,
        ),
      ),
    );
  }

  List<Widget> _buildConditionalSections(ProductProvider provider) {
    final sections = <Widget>[];

    // Loading state
    if (provider.isLoading &&
        provider.heroSlides.isEmpty &&
        provider.bestSellers.isEmpty) {
      sections.add(const _LoadingSection());
      return sections;
    }

    // Error state
    if (provider.error != null && !provider.isLoading) {
      sections.add(_ErrorSection(error: provider.error!));
      return sections;
    }

    // Empty state
    if (!provider.isLoading &&
        provider.error == null &&
        provider.heroSlides.isEmpty &&
        provider.bestSellers.isEmpty) {
      sections.add(const _EmptySection());
      return sections;
    }

    // Content sections with scroll reveal
    if (provider.heroSlides.isNotEmpty) {
      sections.add(
        SliverToBoxAdapter(
          child: ScrollReveal(
            animation: ScrollRevealAnimation.fade,
            child: HeroSection(
              heroSlides: provider.heroSlides,
            ),
          ),
        ),
      );
    }

    if (provider.categories.isNotEmpty) {
      sections.add(
        SliverToBoxAdapter(
          child: ScrollReveal(
            animation: ScrollRevealAnimation.fadeUp,
            child: CategoriesSection(categories: provider.categories),
          ),
        ),
      );
    }

    if (provider.bestSellers.isNotEmpty || provider.isLoading) {
      sections.add(
        SliverToBoxAdapter(
          child: ScrollReveal(
            animation: ScrollRevealAnimation.fadeUp,
            child: BestSellersSection(provider: provider),
          ),
        ),
      );
    }

    sections.add(
      SliverToBoxAdapter(
        child: ScrollReveal(
          animation: ScrollRevealAnimation.scale,
          child: const PromoSection(),
        ),
      ),
    );

    if (provider.newArrivals.isNotEmpty || provider.isLoading) {
      sections.add(
        SliverToBoxAdapter(
          child: ScrollReveal(
            animation: ScrollRevealAnimation.fadeUp,
            child: NewArrivalsSection(provider: provider),
          ),
        ),
      );
    }

    return sections;
  }
}

// Simple helper widgets that stay in main file
class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const SearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Cari produk...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Filter lanjutan akan segera hadir',
                    style: GoogleFonts.manrope(),
                  ),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onChanged: onChanged,
        onSubmitted: (query) {
          if (query.isNotEmpty) {
            context.push('/products?search=${Uri.encodeComponent(query)}');
          }
        },
      ),
    );
  }
}

class _LoadingSection extends StatelessWidget {
  const _LoadingSection();

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingAnimation(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryDark,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.onPrimary,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Memuat data...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorSection extends StatelessWidget {
  final String error;

  const _ErrorSection({required this.error});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade700, size: 48),
              const SizedBox(height: 8),
              Text(
                error,
                style: TextStyle(color: Colors.red.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<ProductProvider>().loadHomeData();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection();

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingAnimation(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Icon(
                  Icons.store_outlined,
                  size: 48,
                  color: AppColors.outline.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum ada data produk',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coba muat ulang untuk melihat koleksi terbaru',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.outline,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ProductProvider>().loadHomeData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Muat Ulang'),
            ),
          ],
        ),
      ),
    );
  }
}
