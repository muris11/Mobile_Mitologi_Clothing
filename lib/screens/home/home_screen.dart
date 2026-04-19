import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/product_provider.dart';
import '../../utils/debouncer.dart';
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
  int _currentHeroIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () => provider.loadHomeData(),
            color: AppColors.primary,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const AppBarSection(),
                _buildSearchSection(),
                ..._buildConditionalSections(provider),
                const GuaranteesSection(),
                const TestimonialsSection(),
                const PortfolioSection(),
                MaterialsSection(),
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

    // Content sections
    if (provider.heroSlides.isNotEmpty) {
      sections.add(
        HeroSection(
          heroSlides: provider.heroSlides,
          currentHeroIndex: _currentHeroIndex,
          onPageChanged: (index) => setState(() => _currentHeroIndex = index),
        ),
      );
    }

    if (provider.categories.isNotEmpty) {
      sections.add(CategoriesSection(categories: provider.categories));
    }

    if (provider.bestSellers.isNotEmpty || provider.isLoading) {
      sections.add(BestSellersSection(provider: provider));
    }

    sections.add(const PromoSection());

    if (provider.newArrivals.isNotEmpty || provider.isLoading) {
      sections.add(NewArrivalsSection(provider: provider));
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
            onPressed: () {},
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
    return const SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat data...'),
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
            Icon(Icons.store_outlined, size: 64, color: AppColors.outline),
            const SizedBox(height: 16),
            Text(
              'Belum ada data produk',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
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
