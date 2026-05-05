import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/features/catalog/presentation/catalog_view_model.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/home_view_model.dart';
import 'package:mitologi_clothing_mobile/widgets/common/cart_icon_button.dart';
import 'package:mitologi_clothing_mobile/widgets/product/product_card.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class CatalogView extends StatefulWidget {
  final int? categoryId;
  final String? initialQuery;

  const CatalogView({super.key, this.categoryId, this.initialQuery});

  @override
  State<CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<CatalogView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  int? _selectedCategoryId;
  String? _activeQuery;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _selectedCategoryId = widget.categoryId;
    _activeQuery = widget.initialQuery;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogViewModel>().searchProducts(
            query: _activeQuery,
            categoryId: _selectedCategoryId,
          );
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.85) {
      context.read<CatalogViewModel>().searchProducts(
            query: _activeQuery,
            categoryId: _selectedCategoryId,
            refresh: false,
          );
    }
  }

  void _runSearch(String query) {
    setState(() => _activeQuery = query.trim().isEmpty ? null : query.trim());
    context.read<CatalogViewModel>().searchProducts(
          query: _activeQuery,
          categoryId: _selectedCategoryId,
        );
  }

  void _selectCategory(int? categoryId) {
    setState(() => _selectedCategoryId = categoryId);
    context.read<CatalogViewModel>().searchProducts(
          query: _activeQuery,
          categoryId: _selectedCategoryId,
        );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CatalogViewModel>();
    final homeVM = context.watch<HomeViewModel>();
    final categories = homeVM.categories;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            snap: true,
            elevation: 0,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Katalog Produk',
                      style: GoogleFonts.notoSerif(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        height: 1.1,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      '${viewModel.products.length} produk tersedia',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: const [
              CartIconButton(),
              SizedBox(width: 8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0),
              child: Container(
                height: 0.8,
                color: AppColors.outlineVariant,
              ),
            ),
            systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            ),
          ),
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
                      isSelected: _selectedCategoryId == null,
                      onTap: () => _selectCategory(null),
                    ),
                    ...categories.map((cat) => _CategoryChip(
                          label: cat.name,
                          isSelected: _selectedCategoryId == cat.id,
                          onTap: () => _selectCategory(
                            _selectedCategoryId == cat.id ? null : cat.id,
                          ),
                        )),
                  ],
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
                    return ProductCard(product: viewModel.products[index]);
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
