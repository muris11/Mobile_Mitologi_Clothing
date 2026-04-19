import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/image_model.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../services/product_service.dart';
import '../../features/wishlist/presentation/wishlist_provider.dart';

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

  void _debugLog(String message) {}

  @override
  void initState() {
    super.initState();
    _loadProduct();
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
      if (variant.selectedOptions != null) {
        bool matches = true;
        for (final entry in _selectedOptions.entries) {
          final hasOption = variant.selectedOptions!.any(
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

  Future<void> _addToCart() async {
    if (_product == null) return;

    final cartProvider = context.read<CartProvider>();
    final merchandiseId = _selectedVariant?.id;

    if (merchandiseId == null || merchandiseId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Varian produk tidak valid',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success = await cartProvider.addItem(
      merchandiseId: merchandiseId,
      quantity: _quantity,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ditambahkan ke keranjang',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _buyNow() {
    _addToCart().then((_) {
      if (mounted) {
        context.push('/checkout');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                pinned: true,
                elevation: 0,
                backgroundColor: AppColors.surface.withValues(alpha: 0.95),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  'Detail Produk',
                  style: GoogleFonts.notoSerif(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                centerTitle: true,
                actions: [
                  Consumer<WishlistProvider>(
                    builder: (context, wishlistProvider, _) {
                      final isInWishlist = wishlistProvider.ids.contains(product.id);
                      return IconButton(
                        icon: Icon(
                          isInWishlist ? Icons.favorite : Icons.favorite_outline,
                        ),
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          await wishlistProvider.toggle(product.id);
                          if (!mounted) return;
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                isInWishlist
                                    ? 'Dihapus dari wishlist'
                                    : 'Ditambahkan ke wishlist',
                                style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),

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
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
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
                    child: imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.surfaceContainerLow,
                              child: const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.surfaceContainerHigh,
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 64,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.surfaceContainerHigh,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 64,
                            ),
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
          // TODO: Navigate to write review page or show dialog
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ulasan berhasil ditambahkan!')),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal menambahkan ulasan: $e')),
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
        })
        .join(' ');
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
  State<_WriteReviewBottomSheet> createState() =>
      _WriteReviewBottomSheetState();
}

class _WriteReviewBottomSheetState extends State<_WriteReviewBottomSheet> {
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
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
          const SizedBox(height: 24),

          Text(
            'Tulis Ulasan',
            style: GoogleFonts.notoSerif(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),

          // Rating selector
          Text(
            'Rating',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: AppColors.secondary,
                  size: 32,
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          // Comment field
          Text(
            'Komentar',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Bagikan pengalaman Anda dengan produk ini...',
              hintStyle: GoogleFonts.manrope(
                color: AppColors.outline,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_commentController.text.trim().isNotEmpty) {
                  widget.onSubmit(_rating, _commentController.text.trim());
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Kirim Ulasan',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
