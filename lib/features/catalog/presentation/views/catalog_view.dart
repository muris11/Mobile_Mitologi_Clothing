import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_model.dart';
import 'package:mitologi_clothing_mobile/features/catalog/presentation/catalog_view_model.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/home_view_model.dart';
import 'package:mitologi_clothing_mobile/features/wishlist/presentation/wishlist_provider.dart';
import 'package:mitologi_clothing_mobile/widgets/product/product_card.dart';
import 'package:mitologi_clothing_mobile/widgets/common/shimmer_image.dart';
import 'package:mitologi_clothing_mobile/widgets/shared/mitologi_sliver_app_bar.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class CatalogView extends StatefulWidget {
  final String? initialQuery;
  final String? initialCategoryHandle;

  const CatalogView({super.key, this.initialQuery, this.initialCategoryHandle});

  @override
  State<CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<CatalogView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoryHandle;
  String? _activeQuery;
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _selectedCategoryHandle = widget.initialCategoryHandle;
    _activeQuery = widget.initialQuery;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogViewModel>().searchProducts(
            query: _activeQuery,
            categoryHandle: _selectedCategoryHandle,
          );
      context.read<CatalogViewModel>().getRecommendations();
      context.read<WishlistProvider>().loadWishlist();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.85) {
      context.read<CatalogViewModel>().searchProducts(
            query: _activeQuery,
            categoryHandle: _selectedCategoryHandle,
            refresh: false,
          );
    }
  }

  void _runSearch(String query) {
    setState(() => _activeQuery = query.trim().isEmpty ? null : query.trim());
    context.read<CatalogViewModel>().searchProducts(
          query: _activeQuery,
          categoryHandle: _selectedCategoryHandle,
        );
  }

  void _selectCategory(String? handle) {
    setState(() => _selectedCategoryHandle = handle);
    context.read<CatalogViewModel>().searchProducts(
          query: _activeQuery,
          categoryHandle: _selectedCategoryHandle,
        );
  }

  void _openFilterSheet() {
    final vm = context.read<CatalogViewModel>();
    _minPriceController.text = vm.minPrice?.toStringAsFixed(0) ?? '';
    _maxPriceController.text = vm.maxPrice?.toStringAsFixed(0) ?? '';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            String? localSortKey = vm.sortKey;
            bool localSortReverse = vm.sortReverse;

            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Gap(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter',
                        style: GoogleFonts.notoSerif(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          vm.clearFilters();
                          _minPriceController.clear();
                          _maxPriceController.clear();
                          Navigator.pop(sheetContext);
                        },
                        child: Text(
                          'Hapus Semua',
                          style: GoogleFonts.manrope(
                            color: const Color(0xFFB9955B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(20),
                  Text(
                    'Urutkan',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(8),
                  _SortOption(
                    label: 'Terbaru',
                    isSelected: localSortKey == null,
                    onTap: () {
                      localSortKey = null;
                      vm.setSort(null);
                      Navigator.pop(sheetContext);
                    },
                  ),
                  _SortOption(
                    label: 'Harga: Rendah ke Tinggi',
                    isSelected: localSortKey == 'PRICE' && !localSortReverse,
                    onTap: () {
                      localSortKey = 'PRICE';
                      localSortReverse = false;
                      vm.setSort('PRICE', reverse: false);
                      Navigator.pop(sheetContext);
                    },
                  ),
                  _SortOption(
                    label: 'Harga: Tinggi ke Rendah',
                    isSelected: localSortKey == 'PRICE' && localSortReverse,
                    onTap: () {
                      localSortKey = 'PRICE';
                      localSortReverse = true;
                      vm.setSort('PRICE', reverse: true);
                      Navigator.pop(sheetContext);
                    },
                  ),
                  _SortOption(
                    label: 'Terlaris',
                    isSelected: localSortKey == 'BEST_SELLING',
                    onTap: () {
                      localSortKey = 'BEST_SELLING';
                      vm.setSort('BEST_SELLING');
                      Navigator.pop(sheetContext);
                    },
                  ),
                  const Gap(20),
                  Text(
                    'Rentang Harga',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minPriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Min',
                            hintStyle: GoogleFonts.manrope(fontSize: 13),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.outlineVariant),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12,
                            ),
                          ),
                          style: GoogleFonts.manrope(fontSize: 14),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('—',
                            style: GoogleFonts.manrope(
                                color: AppColors.onSurfaceVariant)),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _maxPriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Max',
                            hintStyle: GoogleFonts.manrope(fontSize: 13),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.outlineVariant),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12,
                            ),
                          ),
                          style: GoogleFonts.manrope(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final min = double.tryParse(_minPriceController.text);
                        final max = double.tryParse(_maxPriceController.text);
                        vm.setPriceRange(min, max);
                        Navigator.pop(sheetContext);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFB9955B),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Terapkan', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _sortLabel(CatalogViewModel vm) {
    if (vm.sortKey == 'PRICE' && !vm.sortReverse) return 'Harga ↑';
    if (vm.sortKey == 'PRICE' && vm.sortReverse) return 'Harga ↓';
    if (vm.sortKey == 'BEST_SELLING') return 'Terlaris';
    return 'Terbaru';
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CatalogViewModel>();
    final homeVM = context.watch<HomeViewModel>();
    final categories = homeVM.categories;
    final showRecommendations = viewModel.recommendations.isNotEmpty &&
        _selectedCategoryHandle == null &&
        (_activeQuery == null || _activeQuery!.isEmpty) &&
        !viewModel.hasActiveFilters;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          const MitologiSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: _runSearch,
                  onChanged: (v) {
                    if (v.isEmpty) _runSearch('');
                  },
                  textInputAction: TextInputAction.search,
                  style: GoogleFonts.manrope(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Cari produk, kategori, tema...',
                    hintStyle: GoogleFonts.manrope(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                    prefixIcon: const Icon(
                      PhosphorIconsRegular.magnifyingGlass,
                      size: 20,
                      color: AppColors.onSurfaceVariant,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(PhosphorIconsRegular.x, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _runSearch('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (categories.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _CategoryChip(
                      label: 'Semua',
                      isSelected: _selectedCategoryHandle == null,
                      onTap: () => _selectCategory(null),
                    ),
                    ...categories.map((cat) => _CategoryChip(
                          label: cat.name,
                          isSelected: _selectedCategoryHandle == cat.slug,
                          onTap: () => _selectCategory(
                            _selectedCategoryHandle == cat.slug ? null : cat.slug,
                          ),
                        )),
                  ],
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _FilterChipButton(
                    label: 'Filter',
                    icon: PhosphorIconsRegular.faders,
                    onTap: _openFilterSheet,
                    isActive: viewModel.hasActiveFilters,
                  ),
                  const Gap(8),
                  _FilterChipButton(
                    label: _sortLabel(viewModel),
                    icon: PhosphorIconsRegular.arrowsDownUp,
                    onTap: () => _openFilterSheet(),
                    isActive: viewModel.sortKey != null,
                  ),
                  const Spacer(),
                  Text(
                    '${viewModel.products.length} produk',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showRecommendations)
            SliverToBoxAdapter(
              child: _buildRecommendationsSection(viewModel.recommendations),
            ),
          if (showRecommendations && viewModel.products.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  height: 1,
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
          if (viewModel.isLoading && viewModel.products.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (viewModel.error != null && viewModel.products.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(PhosphorIconsRegular.wifiSlash,
                          size: 48, color: AppColors.outline),
                      const Gap(16),
                      Text(
                        'Gagal memuat produk',
                        style: GoogleFonts.notoSerif(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const Gap(8),
                      Text(
                        viewModel.error!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                            fontSize: 13, color: AppColors.onSurfaceVariant),
                      ),
                      const Gap(24),
                      FilledButton.icon(
                        onPressed: () => context
                            .read<CatalogViewModel>()
                            .searchProducts(query: _activeQuery),
                        icon: const Icon(PhosphorIconsRegular.arrowClockwise),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (viewModel.products.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(PhosphorIconsRegular.package,
                          size: 48, color: AppColors.outline),
                      const Gap(16),
                      Text(
                        'Produk tidak ditemukan',
                        style: GoogleFonts.notoSerif(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const Gap(8),
                      Text(
                        'Coba kata kunci lain atau hapus filter.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                            fontSize: 13, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == viewModel.products.length) {
                      return const Center(
                          child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ));
                    }
                    final product = viewModel.products[index];
                    return Consumer<WishlistProvider>(
                      builder: (context, wishlist, _) => ProductCard(
                        product: product,
                        isInWishlist: wishlist.isInWishlist(product.id),
                        onWishlistToggle: () => wishlist.toggleWishlist(product.id),
                      ),
                    );
                  },
                  childCount:
                      viewModel.products.length + (viewModel.hasMore ? 1 : 0),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(List<ProductModel> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFB9955B),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(10),
              Text(
                'Rekomendasi Untukmu',
                style: GoogleFonts.notoSerif(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return GestureDetector(
                onTap: () => context.push('/product/${product.slug}'),
                child: Container(
                  width: 200,
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
                  child: Consumer<WishlistProvider>(
                    builder: (context, wishlist, _) {
                      final inWishlist = wishlist.isInWishlist(product.id);
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          ShimmerImage(
                            imageUrl: ApiConfig.buildImageUrl(product.featuredImageUrl),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => wishlist.toggleWishlist(product.id),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  inWishlist
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_outline_rounded,
                                  size: 16,
                                  color: inWishlist
                                      ? const Color(0xFFE53935)
                                      : Colors.white,
                                ),
                              ),
                            ),
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
                                  Row(
                                    children: [
                                      Text(
                                        _formatPrice(product.displayPrice),
                                    style: const TextStyle(
                                      color: Color(0xFFB9955B),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const Spacer(),
                                  if ((product.rating ?? 0) > 0) ...[
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 16,
                                      color: Color(0xFFB9955B),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      product.rating!.toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
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
                  );
                },
              ),
            ),
            );
          },
          ),
        ),
        const Gap(8),
      ],
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  const _FilterChipButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFB9955B).withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFFB9955B) : AppColors.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14,
                color: isActive ? const Color(0xFFB9955B) : AppColors.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? const Color(0xFFB9955B) : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? PhosphorIconsFill.radioButton
                    : PhosphorIconsRegular.radioButton,
                size: 18,
                color: isSelected ? const Color(0xFFB9955B) : AppColors.outline,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFFB9955B) : AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
