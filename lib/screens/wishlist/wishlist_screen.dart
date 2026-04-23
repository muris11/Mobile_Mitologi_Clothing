import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../features/wishlist/presentation/wishlist_provider.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../services/secure_storage_service.dart';
import '../../services/wishlist_service.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/common/custom_pull_to_refresh.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/shimmer_image.dart';
import '../../widgets/common/skeleton_loading.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<Product> _wishlistItems = [];
  bool _isLoading = true;
  bool _needsLogin = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadWishlist();
    });
  }

  Future<void> _loadWishlist() async {
    try {
      final token = await SecureStorageService.getAuthToken();
      if (!mounted) return;
      if (token == null) {
        setState(() {
          _wishlistItems = [];
          _isLoading = false;
          _needsLogin = true;
        });
        return;
      }

      final wishlistProvider = context.read<WishlistProvider>();
      final wishlistService = context.read<WishlistService>();
      await wishlistProvider.load();
      final items = await wishlistService.getWishlist();
      if (!mounted) return;
      final ids = wishlistProvider.ids;
      setState(() {
        _wishlistItems = items.where((item) => ids.contains(item.id)).toList();
        _isLoading = false;
        _needsLogin = false;
      });
    } catch (e) {
      if (!mounted) return;
      final errorStr = e.toString().toLowerCase();
      final isAuthError = errorStr.contains('unauthorized') ||
          errorStr.contains('401') ||
          errorStr.contains('not authenticated');
      setState(() {
        _isLoading = false;
        _needsLogin = isAuthError;
        if (!isAuthError) {
          _errorMessage = 'Gagal memuat wishlist. Silakan coba lagi.';
        }
      });
    }
  }

  Future<void> _removeFromWishlist(int productId) async {
    final wishlistProvider = context.read<WishlistProvider>();
    final wishlistService = context.read<WishlistService>();
    await wishlistService.removeFromWishlist(productId);
    await wishlistProvider.load();
    if (mounted) {
      _loadWishlist();
    }
  }

  Future<void> _addToCart(Product product) async {
    final merchandiseId = product.firstVariant?.id;
    if (merchandiseId == null || merchandiseId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Varian produk tidak tersedia',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      return;
    }

    final cartProvider = context.read<CartProvider>();
    final success = await cartProvider.addItem(
      merchandiseId: merchandiseId,
      quantity: 1,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${product.title} ditambahkan ke keranjang',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomPullToRefresh(
        onRefresh: _loadWishlist,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.surface.withAlpha(240),
            title: Text(
              'Daftar Keinginan',
              style: GoogleFonts.notoSerif(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: () => context.push('/cart'),
              ),
            ],
          ),

          // Header
          SliverToBoxAdapter(
            child: _buildHeader(),
          ),

          // Wishlist Grid
          if (_isLoading)
            SliverPadding(
              padding: ResponsiveConfig.getResponsivePadding(context),
              sliver: const WishlistGridSkeleton(itemCount: 4),
            )
          else if (_errorMessage != null)
            SliverFillRemaining(
              child: AnimatedEmptyState(
                icon: Icons.error_outline,
                title: 'Terjadi Kesalahan',
                subtitle: _errorMessage!,
                actionLabel: 'Coba Lagi',
                onAction: () {
                  setState(() => _errorMessage = null);
                  _loadWishlist();
                },
              ),
            )
          else if (_needsLogin)
            SliverFillRemaining(
              child: LoginRequiredState(
                title: 'Login Diperlukan',
                subtitle: 'Silakan login untuk melihat wishlist Anda',
                onLogin: () => context.push('/login'),
              ),
            )
          else if (_wishlistItems.isEmpty)
            SliverFillRemaining(
              child: AnimatedEmptyState(
                icon: Icons.favorite_outline,
                title: 'Wishlist Kosong',
                subtitle: 'Simpan produk favorit Anda di sini untuk melihatnya nanti',
                actionLabel: 'Jelajahi Produk',
                onAction: () => context.push('/products'),
              ),
            )
          else
            SliverPadding(
              padding: ResponsiveConfig.getResponsivePadding(context),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveConfig.getGridColumnCount(context),
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = _wishlistItems[index];
                    return _buildAnimatedWishlistItem(product, index);
                  },
                  childCount: _wishlistItems.length,
                ),
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildAnimatedWishlistItem(Product product, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 30),
            child: child,
          ),
        );
      },
      child: _buildWishlistItem(product, index),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        children: [
          Text(
            'Simpanan Anda'.toUpperCase(),
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Keinginan Terpilih',
            style: GoogleFonts.notoSerif(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistItem(Product product, int index) {
    final price = product.price?.formatted ?? 'Rp 0';
    final imageUrl = product.featuredImage?.url ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Container
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/product/${product.handle}'),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withAlpha(15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'product-image-${product.id}',
                      child: ShimmerImage(
                        imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    // Remove button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _removeFromWishlist(product.id),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color:
                                AppColors.surfaceContainerLowest.withAlpha(230),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow.withAlpha(20),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Product Info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.title,
                style: GoogleFonts.notoSerif(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 8),
              // Add to cart button
              GestureDetector(
                onTap: () => _addToCart(product),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_shopping_cart,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tambah ke Keranjang',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
