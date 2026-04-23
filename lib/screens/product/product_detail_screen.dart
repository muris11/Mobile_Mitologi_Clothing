import 'dart:ui' show ImageFilter;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../features/wishlist/presentation/wishlist_provider.dart';
import '../../models/image_model.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../services/product_service.dart';
import '../../utils/haptic_feedback.dart';
import '../../widgets/common/add_to_cart_sheet.dart';
import '../../widgets/common/animated_button.dart';
import '../../widgets/common/animated_snackbar.dart';
import '../../widgets/common/cart_fly_to_animation.dart';
import '../../widgets/common/confetti_celebration.dart';
import '../../widgets/common/share_sheet.dart';
import '../../widgets/common/shimmer_image.dart';
import '../../widgets/common/skeleton_loading.dart';

class ProductDetailScreen extends StatefulWidget {
  final String handle;
  const ProductDetailScreen({super.key, required this.handle});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _isLoading = true;
  String? _error;
  int _currentImageIndex = 0;
  int _quantity = 1;
  ProductVariant? _selectedVariant;
  final Map<String, String> _selectedOptions = {};
  List<Product> _recommendations = const [];
  Map<String, dynamic>? _reviewsPayload;
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _scrollOffsetNotifier = ValueNotifier(0);
  final GlobalKey _imageKey = GlobalKey();

  void _debugLog(String message) {}

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadProduct();
  }

  void _onScroll() {
    _scrollOffsetNotifier.value = _scrollController.offset;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _scrollOffsetNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    try {
      final productService = context.read<ProductService>();
      final product = await productService.getProductDetail(widget.handle);

      // Load reviews and recommendations separately to handle errors independently
      Map<String, dynamic>? reviews;
      List<Product> recommendations = [];

      try {
        reviews = await productService.getProductReviews(widget.handle);
      } catch (e) {
        _debugLog('Failed to load reviews: $e');
        // Non-critical error, continue without reviews
      }

      try {
        recommendations =
            await productService.getProductRecommendations(product.id);
        if (recommendations.isEmpty) {
          recommendations =
              await productService.getUserRecommendations(limit: 6);
        }
        recommendations = recommendations
            .where((candidate) => candidate.id != product.id)
            .toList();
      } catch (e) {
        _debugLog('Failed to load recommendations: $e');
        // Non-critical error, continue without recommendations
      }

      if (!mounted) return;
      setState(() {
        _product = product;
        _reviewsPayload = reviews;
        _recommendations = recommendations;
        _isLoading = false;
        _error = null;
        if (product.variants != null && product.variants!.isNotEmpty) {
          _selectedVariant = product.variants!.first;
        }
      });
    } on FormatException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Format error: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load product: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _onOptionSelected(String optionName, String value) {
    setState(() {
      _selectedOptions[optionName] = value;
      _updateSelectedVariant();
    });
  }

  void _updateSelectedVariant() {
    if (_product?.variants == null) return;

    // Find variant matching selected options
    for (final variant in _product!.variants!) {
      final selectedOptions = variant.selectedOptions;
      if (selectedOptions != null) {
        bool matches = true;
        for (final entry in _selectedOptions.entries) {
          final hasOption = selectedOptions.any(
            (opt) => opt.name == entry.key && opt.value == entry.value,
          );
          if (!hasOption) {
            matches = false;
            break;
          }
        }
        if (matches) {
          _selectedVariant = variant;
          return;
        }
      }
    }
  }

  Future<bool> _addToCart() async {
    if (_product == null) return false;

    final product = _product!;
    final cartProvider = context.read<CartProvider>();
    final merchandiseId = _selectedVariant?.id ?? product.firstVariant?.id;

    if (merchandiseId == null || merchandiseId.isEmpty) {
      AppHaptics.error();
      AnimatedSnackbar.error(context, 'Varian produk tidak valid');
      return false;
    }

    final success = await cartProvider.addItem(
      merchandiseId: merchandiseId,
      quantity: _quantity,
    );

    if (success && mounted) {
      AppHaptics.addToCart();

      // Trigger cart fly-to animation
      final renderBox = _imageKey.currentContext?.findRenderObject();
      if (renderBox is RenderBox) {
        final sourceRect = renderBox.localToGlobal(Offset.zero) & renderBox.size;
        CartFlyToAnimation.start(
          context: context,
          imageUrl: product.featuredImage?.url ?? '',
          sourceRect: sourceRect,
        );
      }

      // Show beautiful bottom sheet
      AddToCartBottomSheet.show(
        context: context,
        product: product,
        selectedVariant: _selectedVariant,
        quantity: _quantity,
        onContinueShopping: () => Navigator.of(context).pop(),
        onViewCart: () {
          Navigator.of(context).pop();
          context.push('/cart');
        },
      );
      return true;
    }

    if (mounted) {
      AppHaptics.error();
      AnimatedSnackbar.error(
        context,
        cartProvider.error ?? 'Gagal menambahkan ke keranjang',
      );
    }

    return false;
  }

  Future<void> _buyNow() async {
    final added = await _addToCart();
    if (!mounted || !added) return;
    AppHaptics.success();
    ConfettiCelebration.show(context);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) context.push('/checkout');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: ProductDetailSkeleton(),
        ),
      );
    }

    if (_error != null || _product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Produk')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error ?? 'Product not found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProduct,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final product = _product!;
    final images = product.images ??
        (product.featuredImage != null ? [product.featuredImage!] : []);
    final price = _selectedVariant?.price ?? product.price;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Image Gallery
              SliverToBoxAdapter(
                child: _buildImageGallery(images),
              ),

              // Product Info
              SliverToBoxAdapter(
                child: _buildProductInfo(product, price),
              ),

              // Shipping Info
              SliverToBoxAdapter(
                child: _buildShippingCard(),
              ),

              // Variant Selection
              if (product.options != null && product.options!.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildVariantSelection(product),
                ),

              // Description
              SliverToBoxAdapter(
                child: _buildDescription(product),
              ),

              // Specifications
              if (product.options != null && product.options!.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildSpecifications(product),
                ),

              // Reviews Section
              SliverToBoxAdapter(child: _buildReviewsSection()),

              // Recommendations
              if (_recommendations.isNotEmpty)
                SliverToBoxAdapter(child: _buildRecommendationsSection()),

              // Bottom padding for sticky CTA
              const SliverToBoxAdapter(
                child: SizedBox(height: 120),
              ),
            ],
          ),

          // Sticky Bottom CTA
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildStickyCTA(),
          ),

          // Frosted Glass App Bar
          ValueListenableBuilder<double>(
            valueListenable: _scrollOffsetNotifier,
            builder: (context, scrollOffset, child) {
              final appBarOpacity = (scrollOffset / 100).clamp(0.0, 1.0);
              final blurSigma = (scrollOffset / 20).clamp(0.0, 15.0);
              return Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: blurSigma,
                      sigmaY: blurSigma,
                    ),
                    child: Container(
                      color: AppColors.surface.withValues(alpha: 0.7 * appBarOpacity),
                      child: SafeArea(
                        bottom: false,
                        child: Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () => context.pop(),
                              ),
                              Expanded(
                                child: Opacity(
                                  opacity: appBarOpacity,
                                  child: Text(
                                    'Detail Produk',
                                    style: GoogleFonts.notoSerif(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.share_outlined),
                                onPressed: () {
                                  AppHaptics.tap();
                                  ShareSheet.show(context, product);
                                },
                              ),
                              Consumer<WishlistProvider>(
                                builder: (context, wishlistProvider, _) {
                                  final isInWishlist =
                                      wishlistProvider.ids.contains(product.id);
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: AnimatedFavoriteButton(
                                      isFavorite: isInWishlist,
                                      size: 28,
                                      onToggle: () async {
                                        final scaffoldContext = context;
                                        final result =
                                            await wishlistProvider.toggle(product.id);
                                        if (!mounted) return;
                                        if (wishlistProvider.error != null) {
                                          AppHaptics.error();
                                          if (scaffoldContext.mounted) {
                                            AnimatedSnackbar.error(
                                              scaffoldContext,
                                              wishlistProvider.error!,
                                            );
                                          }
                                          return;
                                        }
                                        AppHaptics.addToCart();
                                        if (scaffoldContext.mounted) {
                                          AnimatedSnackbar.success(
                                            scaffoldContext,
                                            result
                                                ? 'Ditambahkan ke wishlist'
                                                : 'Dihapus dari wishlist',
                                          );
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(List<ImageModel> images) {
    return Column(
      children: [
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: PageView.builder(
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: images.isEmpty ? 1 : images.length,
            itemBuilder: (context, index) {
              final imageUrl = images.isNotEmpty ? images[index].url : '';
              final imageWidget = ShimmerImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  key: index == 0 ? _imageKey : null,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withAlpha(30),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0,
                      boundaryMargin: const EdgeInsets.all(20),
                      child: index == 0 && _product != null
                          ? Hero(
                              tag: 'product-image-${_product!.id}',
                              child: imageWidget,
                            )
                          : imageWidget,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        // Pagination Dots
        if (images.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _currentImageIndex == index ? 32 : 8,
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: _currentImageIndex == index
                      ? AppColors.primary
                      : AppColors.outline.withAlpha(100),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildProductInfo(Product product, dynamic price) {
    final collectionLabel =
        (product.collection?.title.trim().isNotEmpty ?? false)
            ? product.collection!.title.toUpperCase()
            : 'KOLEKSI';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Collection badge and rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  collectionLabel,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              if (product.averageRating != null && product.averageRating! > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.averageRating!.toStringAsFixed(1),
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (product.reviewCount != null &&
                          product.reviewCount! > 0)
                        Text(
                          '(${product.reviewCount} ulasan)',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            color: AppColors.outline,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Product title
          Text(
            product.title,
            style: GoogleFonts.notoSerif(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          // Price and availability
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price?.formatted ?? 'Rp 0',
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tersedia',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildShippingCard() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.secondary.withAlpha(40),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.local_shipping,
                color: AppColors.secondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gratis Ongkir',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Berlaku untuk seluruh pengiriman di Indonesia.',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      color: AppColors.onPrimary.withAlpha(180),
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

  Widget _buildVariantSelection(Product product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 24),
          ...product.options!.map((option) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.name,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: option.values.map((value) {
                    final isSelected = _selectedOptions[option.name] == value;
                    return GestureDetector(
                      onTap: () => _onOptionSelected(option.name, value),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.outlineVariant,
                          ),
                        ),
                        child: Text(
                          value,
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.onPrimary
                                : AppColors.onSurface,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDescription(Product product) {
    // Use product description from API only
    final description = product.descriptionHtml ?? product.description;

    if (description == null || description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 24),
          Text(
            'Deskripsi',
            style: GoogleFonts.notoSerif(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: GoogleFonts.manrope(
              fontSize: 14,
              height: 1.6,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSpecifications(Product product) {
    // Build specs from product data
    final specs = <Map<String, String>>[];

    // Add category
    if (product.productType != null && product.productType!.isNotEmpty) {
      specs.add({'label': 'Kategori', 'value': product.productType!});
    }

    // Add vendor/brand
    if (product.vendor != null && product.vendor!.isNotEmpty) {
      specs.add({'label': 'Merek', 'value': product.vendor!});
    }

    // Add stock info
    if (product.totalStock != null && product.totalStock! > 0) {
      specs.add({'label': 'Stok', 'value': '${product.totalStock} tersedia'});
    }

    // Add tags if any
    if (product.tags != null && product.tags!.isNotEmpty) {
      specs.add({'label': 'Tag', 'value': product.tags!.join(', ')});
    }

    // If variants exist, add variant options as specs
    if (product.options != null && product.options!.isNotEmpty) {
      for (final option in product.options!) {
        if (option.values.isNotEmpty) {
          specs.add({
            'label': option.name,
            'value': option.values.join(', '),
          });
        }
      }
    }

    if (specs.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 24),
          Text(
            'Spesifikasi Produk',
            style: GoogleFonts.notoSerif(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          ...specs.map((spec) => _buildSpecRow(spec['label']!, spec['value']!)),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: AppColors.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    _debugLog('Reviews Payload: $_reviewsPayload');

    if (_reviewsPayload == null) {
      _debugLog('Reviews payload is NULL');
      // Show write review button even if no reviews
      return _buildWriteReviewCard();
    }

    // Handle nested data structure
    final responseData = _reviewsPayload!['data'] is Map<String, dynamic>
        ? _reviewsPayload!['data'] as Map<String, dynamic>
        : _reviewsPayload!;

    // Try multiple possible field names
    final reviews = responseData['reviews'] ??
        responseData['items'] ??
        responseData['data'] ??
        [];

    final reviewItems = reviews is List
        ? reviews
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList()
        : <Map<String, dynamic>>[];

    // Parse average rating safely
    double averageRating = 0.0;
    final avgRatingData = responseData['average_rating'] ??
        responseData['averageRating'] ??
        responseData['rating'] ??
        responseData['avg_rating'];
    if (avgRatingData != null) {
      if (avgRatingData is double) {
        averageRating = avgRatingData;
      } else if (avgRatingData is int) {
        averageRating = avgRatingData.toDouble();
      } else if (avgRatingData is String) {
        averageRating = double.tryParse(avgRatingData) ?? 0.0;
      }
    }

    // Parse total reviews safely
    int totalReviews = 0;
    final totalData = responseData['total_reviews'] ??
        responseData['totalReviews'] ??
        responseData['count'] ??
        responseData['total'];
    if (totalData != null) {
      if (totalData is int) {
        totalReviews = totalData;
      } else if (totalData is double) {
        totalReviews = totalData.toInt();
      } else if (totalData is String) {
        totalReviews =
            int.tryParse(totalData) ?? (reviews is List ? reviews.length : 0);
      }
    } else {
      totalReviews = reviews is List ? reviews.length : 0;
    }

    if (averageRating <= 0 && reviewItems.isNotEmpty) {
      final ratings = reviewItems
          .map((review) => review['rating'])
          .where((value) => value != null)
          .map((value) {
            if (value is num) return value.toDouble();
            return double.tryParse(value.toString()) ?? 0.0;
          })
          .where((value) => value > 0)
          .toList();
      if (ratings.isNotEmpty) {
        averageRating = ratings.reduce((a, b) => a + b) / ratings.length;
      }
    }

    _debugLog('Parsed reviews count: ${reviewItems.length}');
    _debugLog('Average rating: $averageRating');
    _debugLog('Total reviews: $totalReviews');

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ulasan Pembeli',
                style: GoogleFonts.notoSerif(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              if (totalReviews > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        averageRating > 0
                            ? averageRating.toStringAsFixed(1)
                            : '0.0',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '($totalReviews)',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Write Review Button
          _buildWriteReviewButton(),
          const SizedBox(height: 16),

          // Reviews List
          if (reviewItems.isNotEmpty)
            ...reviewItems.take(5).map((review) => _buildReviewItem(review))
          else
            Text(
              'Belum ada ulasan. Jadilah yang pertama memberikan ulasan!',
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: AppColors.outline,
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWriteReviewCard() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 24),
          Text(
            'Ulasan Pembeli',
            style: GoogleFonts.notoSerif(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          _buildWriteReviewButton(),
          const SizedBox(height: 16),
          Text(
            'Belum ada ulasan. Jadilah yang pertama memberikan ulasan!',
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: AppColors.outline,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWriteReviewButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          _showWriteReviewDialog();
        },
        icon: const Icon(Icons.edit, size: 16),
        label: Text(
          'Tulis Ulasan',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showWriteReviewDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _WriteReviewBottomSheet(
        productId: _product?.id ?? 0,
        onSubmit: (rating, comment) async {
          try {
            final product = _product;
            if (product == null) return;

            final productService = context.read<ProductService>();
            await productService.addReview(
              product.handle,
              rating: rating,
              comment: comment,
            );
            if (!mounted) return;

            _loadProduct();
            Navigator.of(context).pop();
            AppHaptics.success();
            ConfettiCelebration.show(context);
            AnimatedSnackbar.success(
              context,
              'Ulasan berhasil ditambahkan!',
            );
          } catch (e) {
            if (!mounted) return;
            AppHaptics.error();
            AnimatedSnackbar.error(
              context,
              'Gagal menambahkan ulasan: $e',
            );
          }
        },
      ),
    );
  }

  String _anonymizeReviewerName(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return 'Anonim';

    return trimmed
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) {
      if (part.length == 1) return '*';
      return '${part[0]}${'*' * (part.length - 1)}';
    }).join(' ');
  }

  Widget _buildReviewItem(dynamic reviewData) {
    // Handle if review is a Map
    final review =
        reviewData is Map<String, dynamic> ? reviewData : <String, dynamic>{};

    _debugLog('Review item data: $review');

    // Try multiple field names for reviewer name - check user object first
    String reviewerName = 'Anonim';

    // Check if there's a user object with name
    final userData = review['user'];
    if (userData is Map<String, dynamic>) {
      reviewerName = userData['name']?.toString() ??
          userData['full_name']?.toString() ??
          userData['username']?.toString() ??
          'Anonim';
    } else if (userData is String) {
      // Sometimes user might just be the name string
      reviewerName = userData;
    } else {
      // Try direct fields
      reviewerName = review['reviewer_name']?.toString() ??
          review['customer_name']?.toString() ??
          review['customer']?.toString() ??
          review['fullname']?.toString() ??
          review['user_name']?.toString() ??
          review['name']?.toString() ??
          review['author']?.toString() ??
          review['author_name']?.toString() ??
          'Anonim';
    }

    // Parse rating safely
    int rating = 5;
    final ratingData = review['rating'];
    if (ratingData != null) {
      if (ratingData is int) {
        rating = ratingData.clamp(1, 5);
      } else if (ratingData is double) {
        rating = ratingData.toInt().clamp(1, 5);
      } else if (ratingData is String) {
        final parsed = int.tryParse(ratingData);
        if (parsed != null) {
          rating = parsed.clamp(1, 5);
        }
      }
    }

    // Try multiple field names for comment
    final comment = review['comment']?.toString() ??
        review['review']?.toString() ??
        review['content']?.toString() ??
        review['text']?.toString() ??
        '';

    // Try multiple field names for date
    final date = review['created_at']?.toString() ??
        review['date']?.toString() ??
        review['createdAt']?.toString() ??
        '';

    // Admin response - check multiple possible field names
    final adminResponse = review['admin_response']?.toString() ??
        review['response']?.toString() ??
        review['adminReply']?.toString() ??
        review['reply']?.toString() ??
        '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _anonymizeReviewerName(reviewerName),
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    size: 12,
                    color: AppColors.secondary,
                  );
                }),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            // Show full comment without truncation
            Text(
              comment,
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
          if (date.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              date.toString().substring(0, 10),
              style: GoogleFonts.manrope(
                fontSize: 10,
                color: AppColors.outline,
              ),
            ),
          ],
          // Seller Response Section
          if (adminResponse.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.store,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Balasan Penjual',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    adminResponse,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
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

  Widget _buildRecommendationsSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 24),
          Text(
            'Rekomendasi Untuk Anda',
            style: GoogleFonts.notoSerif(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _recommendations.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = _recommendations[index];
                return _buildRecommendationCard(product);
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(Product product) {
    final imageUrl = product.featuredImage?.url ??
        (product.images?.isNotEmpty == true ? product.images!.first.url : null);

    return GestureDetector(
      onTap: () {
        context.push('/product/${product.handle}');
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.surfaceContainerLow,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image_not_supported, size: 40),
                    )
                  : const Icon(Icons.image_not_supported, size: 40),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.price?.formatted ?? 'Rp 0',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
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

  Widget _buildStickyCTA() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(240),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withAlpha(15),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quantity selector
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 20),
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                  ),
                  Text(
                    '$_quantity',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    onPressed: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Add to cart button
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainerHighest,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Keranjang',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Buy now button
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primaryContainer,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(60),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _buyNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: AppColors.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Beli Sekarang',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
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
}

// Write Review Bottom Sheet Widget
class _WriteReviewBottomSheet extends StatefulWidget {
  final int productId;
  final Function(int rating, String comment) onSubmit;

  const _WriteReviewBottomSheet({
    required this.productId,
    required this.onSubmit,
  });

  @override
  State<_WriteReviewBottomSheet> createState() {
    return _WriteReviewBottomSheetState();
  }
}

class _WriteReviewBottomSheetState extends State<_WriteReviewBottomSheet>
    with TickerProviderStateMixin {
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  late AnimationController _entranceController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  final List<AnimationController> _starControllers = [];

  final Map<int, String> _ratingLabels = {
    1: 'Sangat Buruk',
    2: 'Buruk',
    3: 'Cukup',
    4: 'Bagus',
    5: 'Sempurna',
  };

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOut,
      ),
    );

    for (int i = 0; i < 5; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      );
      _starControllers.add(controller);
    }

    // Staggered entrance for stars
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _entranceController.forward();
      for (int i = 0; i < 5; i++) {
        Future.delayed(Duration(milliseconds: 200 + i * 80), () {
          if (mounted) _starControllers[i].forward(from: 0);
        });
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _commentController.dispose();
    for (final c in _starControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onStarTap(int index) {
    setState(() => _rating = index + 1);
    _starControllers[index].forward(from: 0).then((_) {
      _starControllers[index].reverse();
    });
  }

  Future<void> _handleSubmit() async {
    if (_commentController.text.trim().isEmpty) return;
    setState(() => _isSubmitting = true);
    await widget.onSubmit(_rating, _commentController.text.trim());
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.surface,
              AppColors.surfaceContainerLow,
            ],
          ),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.2),
              blurRadius: 40,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom + 32,
          left: 24,
          right: 24,
          top: 16,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar with brand accent
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primaryContainer,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Header with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppGradients.primaryDark,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.rate_review_outlined,
                      color: AppColors.onPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tulis Ulasan',
                          style: GoogleFonts.notoSerif(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Bagikan pengalaman Anda',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Rating section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppGradients.cardSoft,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Berapa rating Anda?',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final isSelected = index < _rating;
                        return AnimatedBuilder(
                          animation: _starControllers[index],
                          builder: (context, child) {
                            final scale = 1.0 +
                                (_starControllers[index].value * 0.3);
                            return Transform.scale(
                              scale: scale,
                              child: GestureDetector(
                                onTap: () => _onStarTap(index),
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  padding: const EdgeInsets.all(4),
                                  decoration: isSelected
                                      ? BoxDecoration(
                                          color: AppColors.secondaryContainer
                                              .withValues(alpha: 0.3),
                                          shape: BoxShape.circle,
                                        )
                                      : null,
                                  child: Icon(
                                    isSelected
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    color: isSelected
                                        ? AppColors.secondary
                                        : AppColors.outlineVariant,
                                    size: 36,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _ratingLabels[_rating]!,
                        key: ValueKey(_rating),
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Comment field
              Text(
                'Komentar',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: TextField(
                  controller: _commentController,
                  maxLines: 4,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: AppColors.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Ceritakan detail pengalaman Anda dengan produk ini...',
                    hintStyle: GoogleFonts.manrope(
                      fontSize: 14,
                      color: AppColors.outline.withValues(alpha: 0.6),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _commentController,
                  builder: (context, value, _) {
                    return Text(
                      '${value.text.length} karakter',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: AppColors.outline,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Submit button
              GestureDetector(
                onTap: _isSubmitting ? null : _handleSubmit,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: _isSubmitting
                        ? LinearGradient(
                            colors: [
                              AppColors.outline,
                              AppColors.outlineVariant,
                            ],
                          )
                        : AppGradients.primaryDark,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _isSubmitting
                        ? []
                        : [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                  ),
                  child: Center(
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.onPrimary,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.send_rounded,
                                color: AppColors.onPrimary,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Kirim Ulasan',
                                style: GoogleFonts.manrope(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onPrimary,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
