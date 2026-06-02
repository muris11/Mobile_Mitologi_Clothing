import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_model.dart';
import 'package:mitologi_clothing_mobile/core/utils/haptic_feedback.dart';
import 'package:mitologi_clothing_mobile/core/widgets/app_image.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final double? width;
  final bool showBrand;
  final bool isInWishlist;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistToggle;

  const ProductCard({
    super.key,
    required this.product,
    this.width,
    this.showBrand = true,
    this.isInWishlist = false,
    this.onTap,
    this.onWishlistToggle,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = widget.width ?? double.infinity;

    // Calculate discount if on sale
    final double discountPercent =
        widget.product.onSale && widget.product.price > 0
            ? ((widget.product.price - widget.product.displayPrice) /
                widget.product.price *
                100)
            : 0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap ??
          () {
            AppHaptics.tap();
            context.push('/product/${widget.product.slug}');
          },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: cardWidth == double.infinity ? null : cardWidth,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
              width: 0.5,
            ),
            boxShadow: [
              AppShadows.cardSoft,
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Image Section (Float with 8px padding) ──────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Product image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AppImage(
                          imageUrl: ApiConfig.buildImageUrl(
                              widget.product.featuredImageUrl),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          memCacheWidth:
                              400, // Optimize RAM usage for grid thumbnails
                        ),
                      ),

                      // Promo overlay label (top-left)
                      if (widget.product.onSale)
                        Positioned(
                          left: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.promoRed,
                              borderRadius:
                                  BorderRadius.circular(AppBorderRadius.full),
                            ),
                            child: Text(
                              'PROMO',
                              style: AppTextStyles.discountBadge,
                            ),
                          ),
                        ),

                      // Wishlist button (top-right)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: _buildWishlistButton(),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Content Section (Below the Image, padding 10-12) ──────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Brand / Vendor
                    if (widget.showBrand && widget.product.vendor != null) ...[
                      Text(
                        widget.product.vendor!.toUpperCase(),
                        style: AppTextStyles.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondary,
                          letterSpacing: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                    ],

                    // Product Name
                    Text(
                      widget.product.name,
                      style: AppTextStyles.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Price display
                    Text(
                      _formatPrice(widget.product.displayPrice),
                      style: AppTextStyles.productPrice,
                    ),

                    // Old price and discount percent (if on sale)
                    if (widget.product.onSale) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _formatPrice(widget.product.price),
                              style: AppTextStyles.oldPrice,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.promoRedSoft,
                              borderRadius:
                                  BorderRadius.circular(AppBorderRadius.full),
                            ),
                            child: Text(
                              '-${discountPercent.round()}%',
                              style: AppTextStyles.discountBadge.copyWith(
                                color: AppColors.promoRed,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Ratings and Sold count meta row
                    if ((widget.product.rating ?? 0) > 0 ||
                        widget.product.totalSold > 0) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if ((widget.product.rating ?? 0) > 0) ...[
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              widget.product.rating!.toStringAsFixed(1),
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (widget.product.totalSold > 0) ...[
                            Text(
                              '${widget.product.totalSold} terjual',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],

                    // Featured or New badges
                    if (widget.product.isFeatured) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundWarm,
                          borderRadius:
                              BorderRadius.circular(AppBorderRadius.full),
                          border: Border.all(
                              color:
                                  AppColors.secondary.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          'Best Seller',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.secondary,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ] else if (widget.product.isNew) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.infoSoft,
                          borderRadius:
                              BorderRadius.circular(AppBorderRadius.full),
                        ),
                        child: Text(
                          'Baru',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.infoBlue,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
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

  Widget _buildWishlistButton() {
    return Semantics(
      label:
          widget.isInWishlist ? 'Hapus dari wishlist' : 'Tambahkan ke wishlist',
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          AppHaptics.lightImpact();
          widget.onWishlistToggle?.call();
        },
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            widget.isInWishlist
                ? PhosphorIconsFill.heart
                : PhosphorIconsRegular.heart,
            color: widget.isInWishlist
                ? const Color(0xFFE53E3E)
                : AppColors.primary,
            size: 18,
          ),
        ),
      ),
    );
  }
}
