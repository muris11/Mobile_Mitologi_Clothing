import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/features/wishlist/presentation/wishlist_provider.dart';
import 'package:mitologi_clothing_mobile/utils/responsive_utils.dart';
import 'package:mitologi_clothing_mobile/widgets/common/custom_pull_to_refresh.dart';
import 'package:mitologi_clothing_mobile/widgets/common/empty_state.dart';
import 'package:mitologi_clothing_mobile/widgets/common/skeleton_loading.dart';
import 'package:mitologi_clothing_mobile/widgets/shared/product_card.dart';
import 'package:mitologi_clothing_mobile/widgets/shared/mitologi_sliver_app_bar.dart';
import 'package:provider/provider.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WishlistProvider>().loadWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomPullToRefresh(
        onRefresh: () => context.read<WishlistProvider>().loadWishlist(),
        child: CustomScrollView(
          slivers: [
            const MitologiSliverAppBar(pageTitle: 'Wishlist'),
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            Consumer<WishlistProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.items.isEmpty) {
                  return SliverPadding(
                    padding: ResponsiveConfig.getResponsivePadding(context),
                    sliver: const WishlistGridSkeleton(itemCount: 4),
                  );
                }

                if (provider.error != null && provider.items.isEmpty) {
                  return SliverFillRemaining(
                    child: AnimatedEmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'Terjadi Kesalahan',
                      subtitle: provider.error!,
                      actionLabel: 'Coba Lagi',
                      onAction: () => provider.loadWishlist(),
                    ),
                  );
                }

                if (provider.items.isEmpty) {
                  return SliverFillRemaining(
                    child: AnimatedEmptyState(
                      icon: Icons.favorite_outline_rounded,
                      title: 'Wishlist Kosong',
                      subtitle:
                          'Simpan produk favorit Anda di sini untuk melihatnya nanti.',
                      actionLabel: 'Mulai Belanja',
                      onAction: () => context.push('/products'),
                    ),
                  );
                }

                return SliverPadding(
                  padding: ResponsiveConfig.getResponsivePadding(context),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          ResponsiveConfig.getGridColumnCount(context),
                      childAspectRatio: 0.55,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = provider.items[index];
                        return _buildAnimatedItem(context, item, index);
                      },
                      childCount: provider.items.length,
                    ),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 2,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                'CURATED SELECTION',
                style: AppTextStyles.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondary,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your Favorites',
            style: AppTextStyles.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Items you\'ve saved for later',
            style: AppTextStyles.plusJakartaSans(
              fontSize: 14,
              color: AppColors.outline,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedItem(BuildContext context, dynamic item, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value < 0.0 ? 0.0 : (value > 1.0 ? 1.0 : value),
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: child,
          ),
        );
      },
      child: ProductCard(
        product: item.toProductModel(),
        isInWishlist: true,
        onWishlistToggle: () {
          context.read<WishlistProvider>().toggleWishlist(item.productId);
        },
      ),
    );
  }
}
