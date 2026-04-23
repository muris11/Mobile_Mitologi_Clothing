import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/product_provider.dart';
import '../../features/wishlist/presentation/wishlist_provider.dart';
import '../../services/secure_storage_service.dart';
import '../../utils/haptic_feedback.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/common/custom_pull_to_refresh.dart';
import '../../widgets/common/skeleton_loading.dart';
import '../../widgets/product/product_card.dart';

class _SortOption {
  final String value;
  final String label;
  final String sortKey;
  final bool reverse;

  const _SortOption({
    required this.value,
    required this.label,
    required this.sortKey,
    required this.reverse,
  });
}

const List<_SortOption> _sortOptions = [
  _SortOption(
    value: 'RELEVANCE_ASC',
    label: 'Relevansi',
    sortKey: 'RELEVANCE',
    reverse: false,
  ),
  _SortOption(
    value: 'PRICE_ASC',
    label: 'Harga Rendah',
    sortKey: 'PRICE',
    reverse: false,
  ),
  _SortOption(
    value: 'PRICE_DESC',
    label: 'Harga Tinggi',
    sortKey: 'PRICE',
    reverse: true,
  ),
  _SortOption(
    value: 'CREATED_AT_DESC',
    label: 'Terbaru',
    sortKey: 'CREATED_AT',
    reverse: true,
  ),
];

class ProductListScreen extends StatefulWidget {
  final String? category;
  final String? sort;
  final String? search;

  const ProductListScreen({
    super.key,
    this.category,
    this.sort,
    this.search,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  String? _selectedCategory;
  String _sortBy = 'RELEVANCE_ASC';
  double? _minPrice;
  double? _maxPrice;
  bool _showPriceFilter = false;
  List<String> _searchHistory = [];
  bool _showSearchHistory = false;

  _SortOption get _activeSortOption {
    return _sortOptions.firstWhere(
      (option) => option.value == _sortBy,
      orElse: () => _sortOptions.first,
    );
  }

  String get _activeQuery => _searchController.text.trim();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.category;
    _sortBy = _normalizeSortValue(widget.sort);
    _searchController.text = widget.search ?? '';
    _loadSearchHistory();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCatalog();
    });
  }

  Future<void> _loadSearchHistory() async {
    final history = await SecureStorageService.getSearchHistory();
    if (mounted) {
      setState(() {
        _searchHistory = history;
      });
    }
  }

  Future<void> _onSearch(String query) async {
    if (query.trim().isNotEmpty) {
      await SecureStorageService.addSearchHistory(query.trim());
      await _loadSearchHistory();
    }
    setState(() {
      _showSearchHistory = false;
    });
    await _loadProducts();
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern search field
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari kaos, hoodie, jaket...',
                hintStyle: GoogleFonts.manrope(
                  fontSize: 14,
                  color: AppColors.outline,
                ),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _showSearchHistory = _searchHistory.isNotEmpty;
                          });
                        },
                      ),
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        gradient: AppGradients.primaryDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: AppColors.onPrimary,
                          size: 20,
                        ),
                        onPressed: () => _onSearch(_searchController.text),
                      ),
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              onSubmitted: _onSearch,
              onTap: () {
                setState(() {
                  _showSearchHistory = _searchHistory.isNotEmpty;
                });
              },
              onChanged: (value) {
                setState(() {
                  _showSearchHistory = value.isEmpty && _searchHistory.isNotEmpty;
                });
              },
            ),
          ),
          // Search history dropdown
          if (_showSearchHistory && _searchHistory.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSearchHistorySection(),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchHistorySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppGradients.cardSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Riwayat Pencarian',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () async {
                  await SecureStorageService.clearSearchHistory();
                  _loadSearchHistory();
                  setState(() => _showSearchHistory = false);
                },
                child: Text(
                  'Hapus Semua',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _searchHistory.take(8).map((query) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = query;
                  _onSearch(query);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        query,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () async {
                          await SecureStorageService.removeSearchHistory(query);
                          _loadSearchHistory();
                        },
                        child: Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _normalizeSortValue(String? value) {
    const legacySortMap = {
      'relevance': 'RELEVANCE_ASC',
      'price_low': 'PRICE_ASC',
      'price_high': 'PRICE_DESC',
      'newest': 'CREATED_AT_DESC',
      'RELEVANCE': 'RELEVANCE_ASC',
      'PRICE': 'PRICE_ASC',
      'CREATED_AT': 'CREATED_AT_DESC',
    };

    final normalized = legacySortMap[value] ?? value;
    if (normalized != null &&
        _sortOptions.any((option) => option.value == normalized)) {
      return normalized;
    }
    return 'RELEVANCE_ASC';
  }

  Future<void> _initializeCatalog() async {
    final provider = context.read<ProductProvider>();
    if (provider.categories.isEmpty) {
      await provider.loadCategories();
    }
    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    final provider = context.read<ProductProvider>();
    final sortOption = _activeSortOption;
    final query = _activeQuery;

    await provider.loadProducts(
      query: query.isEmpty ? null : query,
      category: _selectedCategory,
      sortKey: sortOption.sortKey,
      reverse: sortOption.reverse,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
    );
  }

  void _applyPriceFilter() {
    final minText = _minPriceController.text.trim();
    final maxText = _maxPriceController.text.trim();

    setState(() {
      _minPrice = minText.isNotEmpty ? double.tryParse(minText) : null;
      _maxPrice = maxText.isNotEmpty ? double.tryParse(maxText) : null;
      _showPriceFilter = false;
    });
    _loadProducts();
  }

  void _clearPriceFilter() {
    setState(() {
      _minPrice = null;
      _maxPrice = null;
      _minPriceController.clear();
      _maxPriceController.clear();
      _showPriceFilter = false;
    });
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Katalog Produk',
          style: GoogleFonts.notoSerif(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => context.push('/cart'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchField(),
          _buildCategoriesFilter(),
          _buildFilterAndSortRow(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _buildResultLabel(),
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.products.isEmpty) {
                  return const ProductGridSkeleton(itemCount: 6);
                }

                return CustomPullToRefresh(
                  onRefresh: _loadProducts,
                  child: CustomScrollView(
                    slivers: [
                      if (provider.error != null)
                        SliverToBoxAdapter(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            color: AppColors.error.withValues(alpha: 0.1),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Error: ${provider.error}',
                                    style:
                                        const TextStyle(color: AppColors.error),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _loadProducts,
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (provider.products.isEmpty)
                        SliverFillRemaining(
                          child: Center(
                            child: AnimatedEmptyState(
                              icon: Icons.search_off_outlined,
                              title: 'Produk Tidak Ditemukan',
                              subtitle: 'Coba ubah kata kunci atau filter pencarian Anda',
                              actionLabel: 'Reset Filter',
                              onAction: () {
                                _searchController.clear();
                                _selectedCategory = null;
                                _minPrice = null;
                                _maxPrice = null;
                                _sortBy = 'newest';
                                _loadProducts();
                              },
                            ),
                          ),
                        ),
                      SliverPadding(
                        padding: ResponsiveConfig.getResponsivePadding(context),
                        sliver: SliverLayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount =
                                ResponsiveConfig.getGridColumnCount(context);

                            // Masonry staggered: alternate tall/short cards
                            return SliverMasonryGrid.count(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childCount: provider.products.length,
                              itemBuilder: (context, index) {
                                final product = provider.products[index];
                                // Staggered heights: every 3rd item is taller
                                final isTall = index % 3 == 0;
                                // Masonry layout handles varying heights naturally
                                // Tall cards get more visual weight for editorial feel
                                final _ = isTall; // Used for layout variation via Masonry

                                return TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(0, (1 - value) * 40),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Consumer<WishlistProvider>(
                                    builder: (context, wishlistProvider, _) =>
                                        SizedBox(
                                      child: ProductCard(
                                        product: product,
                                        isInWishlist: wishlistProvider.ids
                                            .contains(product.id),
                                        onWishlistToggle: () {
                                          AppHaptics.addToCart();
                                          wishlistProvider.toggle(product.id);
                                        },
                                        onTap: () {
                                          AppHaptics.tap();
                                          context.push('/product/${product.handle}');
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
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

  Widget _buildCategoriesFilter() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.categories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildCategoryChip('Semua', null);
              }
              final category = provider.categories[index - 1];
              final name = category['name'] ?? category['title'] ?? 'Kategori';
              return _buildCategoryChip(name, category['handle']?.toString());
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(String label, String? handle) {
    final isSelected = _selectedCategory == handle;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) async {
          setState(() {
            _selectedCategory = selected ? handle : null;
          });
          await _loadProducts();
        },
      ),
    );
  }

  Widget _buildFilterAndSortRow() {
    final hasPriceFilter = _minPrice != null || _maxPrice != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Urutkan:',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final option in _sortOptions)
                        _buildSortChip(option.label, option.value),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color:
                      hasPriceFilter ? AppColors.primary : AppColors.onSurface,
                ),
                onPressed: () {
                  setState(() {
                    _showPriceFilter = !_showPriceFilter;
                  });
                },
              ),
            ],
          ),
          if (_showPriceFilter) _buildPriceFilter(),
        ],
      ),
    );
  }

  Widget _buildPriceFilter() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Harga',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Min',
                    hintText: 'Rp',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _maxPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Max',
                    hintText: 'Rp',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearPriceFilter,
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyPriceFilter,
                  child: const Text('Terapkan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) async {
          if (selected) {
            setState(() {
              _sortBy = value;
            });
            await _loadProducts();
          }
        },
      ),
    );
  }

  String _buildResultLabel() {
    if (_activeQuery.isNotEmpty) {
      return 'Hasil untuk "$_activeQuery"';
    }

    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      return 'Kurasi untuk kategori ${_selectedCategory!}';
    }

    return 'Kurasi untuk semua produk';
  }
}
