import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';
import 'package:mitologi_clothing_mobile/core/widgets/animated_snackbar.dart';
import 'package:mitologi_clothing_mobile/core/widgets/empty_state.dart';
import 'package:mitologi_clothing_mobile/features/cart/presentation/cart_view_model.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_detail_model.dart';
import 'package:mitologi_clothing_mobile/features/catalog/presentation/catalog_view_model.dart';
import 'package:mitologi_clothing_mobile/features/wishlist/presentation/wishlist_provider.dart';
import 'package:mitologi_clothing_mobile/widgets/common/cached_image_widget.dart';
import 'package:mitologi_clothing_mobile/widgets/common/shimmer_image.dart';
import 'package:mitologi_clothing_mobile/widgets/common/skeleton_loading.dart';
import 'package:mitologi_clothing_mobile/widgets/shared/product_card.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

const Color _gold = AppColors.secondary;

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
      AnimatedSnackbar.error(
        context,
        cartVM.error!,
        title: 'Gagal',
      );
      return;
    }

    if (goToCheckout) {
      context.push('/checkout');
    } else {
      AnimatedSnackbar.success(
        context,
        '${product.name} berhasil ditambahkan ke keranjang belanja Anda.',
        title: 'Berhasil',
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
          ? const ProductDetailSkeleton()
          : product == null
              ? _buildError()
              : _buildContent(product),
      bottomNavigationBar:
          product != null && !isLoading ? _buildBottomBar(product) : null,
    );
  }

  Widget _buildError() {
    return Center(
      child: AnimatedEmptyState(
        icon: PhosphorIconsRegular.package,
        title: 'Produk tidak ditemukan',
        subtitle: 'Produk yang Anda cari mungkin telah dihapus atau tidak tersedia.',
        actionLabel: 'Kembali',
        onAction: () => context.pop(),
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
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: const Icon(PhosphorIconsRegular.caretLeft,
                          size: 20, color: AppColors.primary),
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
                      final inWishlist = wishlist.isInWishlist(context
                              .read<CatalogViewModel>()
                              .selectedProduct
                              ?.id ??
                          0);
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
                            color:
                                inWishlist ? _gold : AppColors.onSurfaceVariant,
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
            style: AppTextStyles.plusJakartaSans(
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
                      const Icon(Icons.star_rounded, size: 14, color: _gold),
                      const SizedBox(width: 3),
                      Text(
                        product.rating!.toStringAsFixed(1),
                        style: AppTextStyles.plusJakartaSans(
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
                  style: AppTextStyles.plusJakartaSans(
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
                  style: AppTextStyles.plusJakartaSans(
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
            style: AppTextStyles.plusJakartaSans(
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
                style: AppTextStyles.plusJakartaSans(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _sortLabel(option.name),
                style: AppTextStyles.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              if (optionKey == 'size')
                GestureDetector(
                  onTap: _showSizeCalculator,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        PhosphorIconsRegular.ruler,
                        size: 14,
                        color: _gold,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Panduan Ukuran',
                        style: AppTextStyles.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _gold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
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
                  v.selectedOptions.any((o) =>
                      o.name.toLowerCase() == optionKey && o.value == value));

              return GestureDetector(
                onTap: isAvailable
                    ? () {
                        setState(() {
                          _selectedOptions[optionKey] = isSelected ? '' : value;
                        });
                      }
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppGradients.primaryGradient : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : isAvailable
                              ? AppColors.outlineVariant
                              : AppColors.outlineVariant.withValues(alpha: 0.3),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                  ),
                  child: Text(
                    value,
                    style: AppTextStyles.plusJakartaSans(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : isAvailable
                              ? AppColors.onSurface
                              : AppColors.onSurfaceVariant
                                  .withValues(alpha: 0.3),
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

  void _showSizeCalculator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _PremiumSizeCalculatorSheet(),
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
            style: AppTextStyles.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(12),
          Text(
            product.descriptionHtml?.isNotEmpty == true
                ? product.descriptionHtml!.replaceAll(RegExp(r'<[^>]*>'), '')
                : product.description,
            style: AppTextStyles.plusJakartaSans(
              fontSize: 14,
              height: 1.7,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _openReviewFormBottomSheet(ProductDetailModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return _ReviewFormSheet(
          productSlug: product.slug,
          onSubmitted: () {
            // Reload product detail and reviews on success
            context.read<CatalogViewModel>().getProductDetail(product.slug);
          },
        );
      },
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Ulasan',
                    style: AppTextStyles.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (totalRev > 0) ...[
                    const SizedBox(width: 8),
                    Text(
                      '($totalRev)',
                      style: AppTextStyles.plusJakartaSans(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
              TextButton.icon(
                onPressed: () => _openReviewFormBottomSheet(product),
                icon: const Icon(PhosphorIconsRegular.pencilSimpleLine,
                    size: 16, color: _gold),
                label: Text(
                  'Tulis Ulasan',
                  style: AppTextStyles.plusJakartaSans(
                    color: _gold,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (avgRating > 0) ...[
            const Gap(12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  avgRating.toStringAsFixed(1),
                  style: AppTextStyles.plusJakartaSans(
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
                      style: AppTextStyles.plusJakartaSans(
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
                                style: AppTextStyles.plusJakartaSans(
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
                                  backgroundColor: AppColors.outlineVariant,
                                  valueColor:
                                      const AlwaysStoppedAnimation(_gold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 20,
                              child: Text(
                                '$count',
                                style: AppTextStyles.plusJakartaSans(
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
                      : const Icon(PhosphorIconsRegular.arrowDown, size: 16),
                  label: Text(
                    viewModel.isLoadingReviews
                        ? 'Memuat...'
                        : 'Lihat ulasan lainnya',
                    style: AppTextStyles.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ] else if (summary != null)
            Text(
              'Belum ada ulasan untuk produk ini.',
              style: AppTextStyles.plusJakartaSans(
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
                radius: 17,
                backgroundColor: AppColors.outlineVariant,
                child: ProductReviewAvatar(review: review, radius: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: AppTextStyles.plusJakartaSans(
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
                style: AppTextStyles.plusJakartaSans(
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
              style: AppTextStyles.plusJakartaSans(
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
                      style: AppTextStyles.plusJakartaSans(
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
            style: AppTextStyles.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(16),
          SizedBox(
            height: 280, // Updated height to match standard ProductCard 3:4 ratio
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length.clamp(0, 8),
              itemBuilder: (context, index) {
                final p = products[index];
                return Consumer<WishlistProvider>(
                  builder: (context, wishlist, _) {
                    return Container(
                      width: 175,
                      margin: const EdgeInsets.only(right: 12),
                      child: ProductCard(
                        product: p,
                        showBrand: false,
                        isInWishlist: wishlist.isInWishlist(p.id),
                        onWishlistToggle: () => wishlist.toggleWishlist(p.id),
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
  }

  Widget _buildBottomBar(ProductDetailModel product) {
    final variant = _matchedVariant;
    final canAdd =
        product.availableForSale && (variant?.availableForSale ?? true);

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 360;
            final qtySelectorWidth = isNarrow ? 96.0 : 120.0;
            final qtyButtonWidth = isNarrow ? 30.0 : 40.0;
            final spacing = isNarrow ? 6.0 : 10.0;

            return Row(
              children: [
                Container(
                  height: 44,
                  width: qtySelectorWidth,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                        child: Container(
                          width: qtyButtonWidth,
                          height: 44,
                          alignment: Alignment.center,
                          child: Icon(
                            PhosphorIconsRegular.minus,
                            size: 16,
                            color: _quantity > 1
                                ? AppColors.onSurface
                                : AppColors.outlineVariant,
                          ),
                        ),
                      ),
                      Text(
                        '$_quantity',
                        style: AppTextStyles.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: isNarrow ? 13 : 15,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _quantity++),
                        child: Container(
                          width: qtyButtonWidth,
                          height: 44,
                          alignment: Alignment.center,
                          child: const Icon(
                            PhosphorIconsRegular.plus,
                            size: 16,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: spacing),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: canAdd ? () => _handleAddToCart() : null,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color:
                              canAdd ? AppColors.primary : AppColors.outlineVariant,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: isNarrow ? 4 : 8),
                      ),
                      child: Text(
                        'Keranjang',
                        style: AppTextStyles.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: isNarrow ? 11 : 13,
                          color: canAdd ? AppColors.primary : AppColors.outline,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isNarrow ? 4.0 : 8.0),
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
                        padding: EdgeInsets.symmetric(horizontal: isNarrow ? 4 : 8),
                      ),
                      child: Text(
                        'Beli',
                        style: AppTextStyles.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: isNarrow ? 11 : 13,
                          color: Colors.white,
                        ),
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
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
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
          style: AppTextStyles.plusJakartaSans(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class ProductReviewAvatar extends StatelessWidget {
  final ProductReview review;
  final double radius;

  const ProductReviewAvatar({
    super.key,
    required this.review,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = review.userAvatar?.trim() ?? '';
    final size = radius * 2;

    if (avatar.isEmpty) {
      return _fallback(size);
    }

    return ClipOval(
      child: CachedImageWidget(
        imageUrl: ApiConfig.buildImageUrl(avatar),
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: _fallback(size),
        errorWidget: _fallback(size),
      ),
    );
  }

  Widget _fallback(double size) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: AppColors.surfaceContainerLow,
      child: Text(
        review.userName.isNotEmpty ? review.userName[0].toUpperCase() : '?',
        style: AppTextStyles.plusJakartaSans(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ReviewFormSheet extends StatefulWidget {
  final String productSlug;
  final VoidCallback onSubmitted;

  const _ReviewFormSheet({
    required this.productSlug,
    required this.onSubmitted,
  });

  @override
  State<_ReviewFormSheet> createState() => _ReviewFormSheetState();
}

class _ReviewFormSheetState extends State<_ReviewFormSheet> {
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() async {
    final comment = _commentController.text.trim();
    if (comment.length < 10) {
      setState(() {
        _errorMessage = 'Ulasan wajib diisi minimal 10 karakter.';
      });
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    final success = await context.read<CatalogViewModel>().submitReview(
          widget.productSlug,
          rating: _rating,
          comment: comment,
        );

    if (mounted) {
      setState(() {
        _submitting = false;
      });

      if (success) {
        widget.onSubmitted();
        Navigator.pop(sheetContext);
        AnimatedSnackbar.success(
          context,
          'Ulasan Anda berhasil dikirim!',
          title: 'Terima Kasih',
        );
      } else {
        final errorMsg = context.read<CatalogViewModel>().error;
        setState(() {
          _errorMessage = errorMsg ?? 'Gagal mengirim ulasan. Silakan coba lagi.';
        });
      }
    }
  }

  BuildContext get sheetContext => context;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorderRadius.xxl),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).padding.bottom + 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tulis Ulasan Produk',
                style: AppTextStyles.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    PhosphorIconsRegular.x,
                    size: 16,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const Gap(20),
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AppColors.error.withValues(alpha: 0.2)),
              ),
              child: Text(
                _errorMessage!,
                style: AppTextStyles.plusJakartaSans(
                  color: AppColors.error,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Gap(16),
          ],
          Text(
            'Rating Bintang',
            style: AppTextStyles.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const Gap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              final isFilled = starValue <= _rating;
              return GestureDetector(
                onTap: () => setState(() => _rating = starValue),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(
                    isFilled
                        ? PhosphorIconsFill.star
                        : PhosphorIconsRegular.star,
                    color: _gold,
                    size: 32,
                  ),
                ),
              );
            }),
          ),
          const Gap(20),
          Text(
            'Komentar Ulasan',
            style: AppTextStyles.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const Gap(8),
          TextField(
            controller: _commentController,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            style: AppTextStyles.plusJakartaSans(fontSize: 14),
            decoration: InputDecoration(
              hintText:
                  'Tuliskan ulasan pengalaman Anda terhadap produk ini...',
              hintStyle:
                  AppTextStyles.plusJakartaSans(fontSize: 13, color: AppColors.outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _gold, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const Gap(24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _submitting ? null : _submitReview,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      'Kirim Ulasan',
                      style: AppTextStyles.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumSizeCalculatorSheet extends StatefulWidget {
  const _PremiumSizeCalculatorSheet();

  @override
  State<_PremiumSizeCalculatorSheet> createState() =>
      _PremiumSizeCalculatorSheetState();
}

class _PremiumSizeCalculatorSheetState
    extends State<_PremiumSizeCalculatorSheet> {
  double _height = 170; // cm
  double _weight = 65; // kg
  String? _calculatedSize;
  double _matchPercentage = 0;
  String _fitFeedback = '';

  @override
  void initState() {
    super.initState();
    _calculateSize();
  }

  void _calculateSize() {
    // Elegant heuristic size calculator matching premium fashion design
    // Height & Weight based sizing logic
    String size = 'M';
    double pct = 95.0;
    String feedback = '';

    if (_height < 160) {
      if (_weight < 50) {
        size = 'S';
        pct = 98.0;
        feedback = 'Sangat pas di bahu & dada.';
      } else if (_weight < 65) {
        size = 'M';
        pct = 92.0;
        feedback = 'Pas di bahu, sedikit longgar di dada.';
      } else if (_weight < 75) {
        size = 'L';
        pct = 88.0;
        feedback = 'Panjang lengan pas, cukup longgar.';
      } else {
        size = 'XL';
        pct = 85.0;
        feedback = 'Ukuran XL disarankan untuk kenyamanan extra.';
      }
    } else if (_height < 175) {
      if (_weight < 55) {
        size = 'S';
        pct = 90.0;
        feedback = 'Panjang baju pas, agak ramping di badan.';
      } else if (_weight < 70) {
        size = 'M';
        pct = 96.0;
        feedback = 'Ukuran ideal untuk postur Anda. Sangat pas!';
      } else if (_weight < 82) {
        size = 'L';
        pct = 93.0;
        feedback = 'Lebar dada pas, nyaman untuk bergerak.';
      } else if (_weight < 95) {
        size = 'XL';
        pct = 89.0;
        feedback = 'Sedikit longgar di lengan, pas di pinggang.';
      } else {
        size = 'XXL';
        pct = 91.0;
        feedback = 'XXL disarankan untuk fitting kasual yang nyaman.';
      }
    } else {
      if (_weight < 65) {
        size = 'M';
        pct = 87.0;
        feedback = 'Panjang baju ideal, siluet lebih loose.';
      } else if (_weight < 78) {
        size = 'L';
        pct = 95.0;
        feedback = 'Sangat pas di bahu & panjang kaos/kemeja ideal.';
      } else if (_weight < 90) {
        size = 'XL';
        pct = 94.0;
        feedback = 'Pas di bahu & dada. Ruang gerak sangat nyaman.';
      } else {
        size = 'XXL';
        pct = 92.0;
        feedback = 'Ukuran XXL paling ideal untuk kenyamanan maksimal.';
      }
    }

    setState(() {
      _calculatedSize = size;
      _matchPercentage = pct;
      _fitFeedback = feedback;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorderRadius.xxl),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).padding.bottom + 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kalkulator Ukuran Premium',
                style: AppTextStyles.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    PhosphorIconsRegular.x,
                    size: 16,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const Gap(8),
          Text(
            'Masukkan tinggi dan berat badan Anda untuk mendapatkan rekomendasi ukuran terbaik dari koleksi premium kami.',
            style: AppTextStyles.plusJakartaSans(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const Gap(24),

          // Height Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tinggi Badan',
                style: AppTextStyles.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: _height.toStringAsFixed(0),
                      style: AppTextStyles.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _gold,
                      ),
                    ),
                    TextSpan(
                      text: ' cm',
                      style: AppTextStyles.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor:
                  AppColors.outlineVariant.withValues(alpha: 0.3),
              thumbColor: _gold,
              overlayColor: _gold.withValues(alpha: 0.15),
              valueIndicatorTextStyle: AppTextStyles.plusJakartaSans(color: Colors.white),
            ),
            child: Slider(
              value: _height,
              min: 140,
              max: 210,
              divisions: 70,
              onChanged: (val) {
                setState(() {
                  _height = val;
                });
                _calculateSize();
              },
            ),
          ),
          const Gap(16),

          // Weight Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Berat Badan',
                style: AppTextStyles.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: _weight.toStringAsFixed(0),
                      style: AppTextStyles.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _gold,
                      ),
                    ),
                    TextSpan(
                      text: ' kg',
                      style: AppTextStyles.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor:
                  AppColors.outlineVariant.withValues(alpha: 0.3),
              thumbColor: _gold,
              overlayColor: _gold.withValues(alpha: 0.15),
              valueIndicatorTextStyle: AppTextStyles.plusJakartaSans(color: Colors.white),
            ),
            child: Slider(
              value: _weight,
              min: 35,
              max: 130,
              divisions: 95,
              onChanged: (val) {
                setState(() {
                  _weight = val;
                });
                _calculateSize();
              },
            ),
          ),
          const Gap(24),

          // Calculation Result Box
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _gold.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _gold.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Premium Medal/Circle with Recommended Size
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: AppGradients.premiumGold,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _gold.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _calculatedSize ?? 'M',
                    style: AppTextStyles.plusJakartaSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Gap(20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Rekomendasi Anda',
                            style: AppTextStyles.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  PhosphorIconsFill.checkCircle,
                                  size: 12,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Cocok ${_matchPercentage.toStringAsFixed(0)}%',
                                  style: AppTextStyles.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Gap(4),
                      Text(
                        'Ukuran ${_calculatedSize ?? "M"}',
                        style: AppTextStyles.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const Gap(6),
                      Text(
                        _fitFeedback,
                        style: AppTextStyles.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(24),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: () {
                // Apply the calculated size back to the main detail view
                final detailState =
                    context.findAncestorStateOfType<_ProductDetailViewState>();
                if (detailState != null) {
                  detailState.setState(() {
                    detailState._selectedOptions['size'] =
                        _calculatedSize ?? 'M';
                  });
                  AnimatedSnackbar.success(
                    context,
                    'Ukuran ${_calculatedSize ?? "M"} telah diterapkan.',
                    title: 'Berhasil',
                  );
                }
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Terapkan Ukuran',
                style: AppTextStyles.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
