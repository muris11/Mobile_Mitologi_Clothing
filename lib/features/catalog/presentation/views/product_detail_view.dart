import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/features/cart/presentation/cart_view_model.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_detail_model.dart';
import 'package:mitologi_clothing_mobile/features/catalog/presentation/catalog_view_model.dart';
import 'package:mitologi_clothing_mobile/features/wishlist/presentation/wishlist_provider.dart';
import 'package:mitologi_clothing_mobile/widgets/common/shimmer_image.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

const Color _gold = Color(0xFFB9955B);

class ProductDetailView extends StatefulWidget {
  final String slug;

  const ProductDetailView({super.key, required this.slug});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  int _quantity = 1;
  int _currentImageIndex = 0;
  final Map<String, String> _selectedOptions = {};

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogViewModel>().getProductDetail(widget.slug);
      context.read<WishlistProvider>().loadWishlist();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  ProductVariant? get _matchedVariant {
    final product = context.read<CatalogViewModel>().selectedProduct;
    if (product == null) return null;

    if (_selectedOptions.isEmpty && product.variants.length == 1) {
      return product.variants.first;
    }

    if (_selectedOptions.isEmpty) return null;

    return product.variants.cast<ProductVariant?>().firstWhere(
      (v) {
        if (v == null) return false;
        return v.selectedOptions.every(
          (o) => _selectedOptions[o.name.toLowerCase()] == o.value,
        );
      },
      orElse: () => null,
    );
  }

  String _sortLabel(String label) {
    final lower = label.toLowerCase();
    if (lower == 'size') return 'Ukuran';
    if (lower == 'color') return 'Warna';
    if (lower == 'bahan') return 'Bahan';
    return label;
  }

  void _handleAddToCart({bool goToCheckout = false}) async {
    final product = context.read<CatalogViewModel>().selectedProduct;
    if (product == null) return;

    final cartVM = context.read<CartViewModel>();
    final variant = _matchedVariant;

    await cartVM.addToCart(
      quantity: _quantity,
      variantId: variant?.id ?? 0,
    );

    if (!mounted) return;

    if (cartVM.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(cartVM.error!)),
      );
      return;
    }

    if (goToCheckout) {
      context.push('/checkout');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ditambahkan ke keranjang'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Lihat',
            onPressed: () => context.push('/cart'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CatalogViewModel>();
    final product = viewModel.selectedProduct;
    final isLoading = viewModel.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : product == null
              ? _buildError()
              : _buildContent(product),
      bottomNavigationBar:
          product != null && !isLoading ? _buildBottomBar(product) : null,
    );
  }

  Widget _buildError() {
    return Center(
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
            const Gap(24),
            FilledButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(PhosphorIconsRegular.arrowLeft),
              label: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ProductDetailModel product) {
    final gallery = product.images.isNotEmpty
        ? product.images
        : [product.featuredImageUrl].where((e) => e.isNotEmpty).toList();
    final viewModel = context.watch<CatalogViewModel>();
    final showReviews =
        viewModel.reviews.isNotEmpty || product.reviewsCount > 0;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildGallery(gallery),
        ),
        SliverToBoxAdapter(
          child: _buildProductInfo(product),
        ),
        SliverToBoxAdapter(
          child: _buildSpecs(product),
        ),
        if (product.descriptionHtml != null || product.description.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildDescription(product),
          ),
        if (showReviews || viewModel.isLoadingReviews)
          SliverToBoxAdapter(
            child: _buildReviewsSection(product),
          ),
        if (viewModel.relatedProducts.isNotEmpty || viewModel.isLoadingRelated)
          SliverToBoxAdapter(
            child: _buildRelatedProducts(),
          ),
      ],
    );
  }

  Widget _buildGallery(List<String> images) {
    if (images.isEmpty) {
      return Container(
        height: 400,
        color: AppColors.surfaceContainerLow,
        child: const Center(
          child: Icon(PhosphorIconsRegular.image,
              size: 48, color: AppColors.outline),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: images.length,
                onPageChanged: (i) => setState(() => _currentImageIndex = i),
                itemBuilder: (context, index) {
                  return ShimmerImage(
                    imageUrl: ApiConfig.buildImageUrl(images[index]),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  );
                },
              ),
              if (images.length > 1)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      images.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _currentImageIndex == i ? 24 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _currentImageIndex == i
                              ? _gold
                              : Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 8,
                top: 8,
                child: SafeArea(
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(PhosphorIconsRegular.arrowLeft,
                          size: 20, color: AppColors.onSurface),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: SafeArea(
                  child: Consumer<WishlistProvider>(
                    builder: (context, wishlist, _) {
                      final inWishlist =
                          wishlist.isInWishlist(
                              context.read<CatalogViewModel>()
                                  .selectedProduct?.id ?? 0);
                      return GestureDetector(
                        onTap: () {
                          final pid = context
                              .read<CatalogViewModel>()
                              .selectedProduct
                              ?.id;
                          if (pid != null) wishlist.toggleWishlist(pid);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            inWishlist
                                ? PhosphorIconsFill.heart
                                : PhosphorIconsRegular.heart,
                            size: 20,
                            color: inWishlist ? _gold : AppColors.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        if (images.length > 1)
          Container(
            height: 72,
            color: AppColors.background,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final isActive = index == _currentImageIndex;
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 56,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isActive ? _gold : AppColors.outlineVariant,
                        width: isActive ? 2 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ShimmerImage(
                      imageUrl: ApiConfig.buildImageUrl(images[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildProductInfo(ProductDetailModel product) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: GoogleFonts.notoSerif(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: AppColors.onSurface,
            ),
          ),
          const Gap(10),
          Row(
            children: [
              if ((product.rating ?? 0) > 0) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _gold.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: _gold.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 14, color: _gold),
                      const SizedBox(width: 3),
                      Text(
                        product.rating!.toStringAsFixed(1),
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _gold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
              ],
              if (product.reviewsCount > 0) ...[
                Text(
                  '${product.reviewsCount} ulasan',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              if (product.reviewsCount > 0 && product.totalSold > 0)
                Container(
                  width: 3,
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: const BoxDecoration(
                    color: AppColors.outline,
                    shape: BoxShape.circle,
                  ),
                ),
              if (product.totalSold > 0)
                Text(
                  '${_formatCount(product.totalSold)}+ terjual',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const Gap(16),
          Text(
            _formatPrice(product.displayPrice),
            style: GoogleFonts.manrope(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: _gold,
              height: 1.1,
            ),
          ),
          if (product.onSale)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _formatPrice(product.price),
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  color: AppColors.outline,
                  decoration: TextDecoration.lineThrough,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (product.options.isNotEmpty) ...[
            const Divider(height: 28),
            ...product.options.map((option) => _buildOptionGroup(option)),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionGroup(ProductOption option) {
    final optionKey = option.name.toLowerCase();
    final selectedValue = _selectedOptions[optionKey];

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _sortLabel(option.name),
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const Gap(8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: option.values.map((value) {
              final isSelected = selectedValue == value;

              final product = context.read<CatalogViewModel>().selectedProduct!;
              final isAvailable = product.variants.any((v) =>
                  v.availableForSale &&
                  v.selectedOptions.any(
                      (o) => o.name.toLowerCase() == optionKey && o.value == value));

              return GestureDetector(
                onTap: isAvailable
                    ? () {
                        setState(() {
                          _selectedOptions[optionKey] =
                              isSelected ? '' : value;
                        });
                      }
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : isAvailable
                              ? AppColors.outlineVariant
                              : AppColors.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    value,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : isAvailable
                              ? AppColors.onSurface
                              : AppColors.onSurfaceVariant.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecs(ProductDetailModel product) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          children: [
            _SpecRow(
              label: 'Kategori',
              value: product.tags.isNotEmpty ? product.tags.first : 'Produk',
            ),
            const Divider(height: 20),
            _SpecRow(label: 'Stok', value: '${product.stock} tersedia'),
            const Divider(height: 20),
            _SpecRow(
              label: 'Dikirim dari',
              value: 'Cirebon, Jawa Barat',
            ),
            if (product.variants.firstOrNull?.sku != null) ...[
              const Divider(height: 20),
              _SpecRow(
                label: 'SKU',
                value: product.variants.first.sku!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(ProductDetailModel product) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deskripsi Produk',
            style: GoogleFonts.notoSerif(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(12),
          Text(
            product.descriptionHtml?.isNotEmpty == true
                ? product.descriptionHtml!
                    .replaceAll(RegExp(r'<[^>]*>'), '')
                : product.description,
            style: GoogleFonts.manrope(
              fontSize: 14,
              height: 1.7,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(ProductDetailModel product) {
    final viewModel = context.watch<CatalogViewModel>();
    final summary = viewModel.reviewSummary;
    final avgRating = summary?.averageRating ?? product.rating ?? 0;
    final totalRev = summary?.totalReviews ?? product.reviewsCount;
    final breakdown = summary?.ratingBreakdown ?? {};
    final reviews = viewModel.reviews;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Ulasan',
                style: GoogleFonts.notoSerif(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (totalRev > 0) ...[
                const SizedBox(width: 8),
                Text(
                  '($totalRev)',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          if (avgRating > 0) ...[
            const Gap(12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  avgRating.toStringAsFixed(1),
                  style: GoogleFonts.manrope(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: _gold,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < avgRating.round()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 16,
                          color: _gold,
                        ),
                      ),
                    ),
                    Text(
                      '$totalRev ulasan',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (breakdown.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [5, 4, 3, 2, 1].map((star) {
                      final count = breakdown[star] ?? 0;
                      final pct = totalRev > 0 ? count / totalRev : 0.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              child: Text(
                                '$star',
                                style: GoogleFonts.manrope(
                                  fontSize: 10,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 60,
                              height: 4,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  backgroundColor:
                                      AppColors.outlineVariant,
                                  valueColor: const AlwaysStoppedAnimation(
                                      _gold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 20,
                              child: Text(
                                '$count',
                                style: GoogleFonts.manrope(
                                  fontSize: 10,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ],
          const Gap(16),
          if (viewModel.isLoadingReviews && reviews.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (reviews.isNotEmpty) ...[
            ...reviews.map((review) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildReviewItem(review),
                )),
            if (viewModel.hasMoreReviews)
              Center(
                child: TextButton.icon(
                  onPressed: viewModel.isLoadingReviews
                      ? null
                      : () => viewModel.loadMoreReviews(),
                  icon: viewModel.isLoadingReviews
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(PhosphorIconsRegular.arrowDown,
                          size: 16),
                  label: Text(
                    viewModel.isLoadingReviews
                        ? 'Memuat...'
                        : 'Lihat ulasan lainnya',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ] else if (summary != null)
            Text(
              'Belum ada ulasan untuk produk ini.',
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildReviewItem(ProductReview review) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.outlineVariant,
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : '?',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < review.rating.round()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 12,
                          color: _gold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(review.createdAt),
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const Gap(8),
            Text(
              review.comment,
              style: GoogleFonts.manrope(
                fontSize: 13,
                height: 1.5,
                color: AppColors.onSurface,
              ),
            ),
          ],
          if (review.adminReply != null) ...[
            const Gap(8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(PhosphorIconsRegular.storefront,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      review.adminReply!,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        height: 1.4,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRelatedProducts() {
    final viewModel = context.watch<CatalogViewModel>();
    final products = viewModel.relatedProducts;

    if (viewModel.isLoadingRelated && products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Produk Terkait',
            style: GoogleFonts.notoSerif(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(16),
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length.clamp(0, 8),
              itemBuilder: (context, index) {
                final p = products[index];
                return GestureDetector(
                  onTap: () {
                    context.push('/product/${p.slug}');
                  },
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: AppColors.surfaceContainerLowest,
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ShimmerImage(
                            imageUrl:
                                ApiConfig.buildImageUrl(p.featuredImageUrl),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatPrice(p.displayPrice),
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: _gold,
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

  Widget _buildBottomBar(ProductDetailModel product) {
    final variant = _matchedVariant;
    final canAdd = product.availableForSale && (variant?.availableForSale ?? true);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              height: 44,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _QtyButton(
                    icon: PhosphorIconsRegular.minus,
                    onTap: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                  ),
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text(
                      '$_quantity',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  _QtyButton(
                    icon: PhosphorIconsRegular.plus,
                    onTap: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: canAdd ? () => _handleAddToCart() : null,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: canAdd ? AppColors.primary : AppColors.outlineVariant,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Keranjang',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: canAdd ? AppColors.primary : AppColors.outline,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 44,
                child: FilledButton(
                  onPressed: canAdd
                      ? () => _handleAddToCart(goToCheckout: true)
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Beli',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
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

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(count >= 10000 ? 0 : 1)}rb';
    }
    return count.toString();
  }

  String _formatDate(DateTime date) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;

  const _SpecRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QtyButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 44,
        alignment: Alignment.center,
        child: Icon(icon, size: 16,
            color: onTap != null
                ? AppColors.onSurface
                : AppColors.outlineVariant),
      ),
    );
  }
}
