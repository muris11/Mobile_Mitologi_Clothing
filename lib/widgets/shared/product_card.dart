import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_model.dart';
import 'package:mitologi_clothing_mobile/core/utils/haptic_feedback.dart';
import 'package:mitologi_clothing_mobile/core/utils/responsive_utils.dart';
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
    final isMobile = ResponsiveConfig.isMobile(context);

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
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            // radius 18px (radiusLg) sesuai design.md §7.3
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Image section (3:4 ratio, text overlay) ──────────────
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Product image
                    AppImage(
                      imageUrl: ApiConfig.buildImageUrl(
                          widget.product.featuredImageUrl),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: 0,
                    ),
                    // Gradient overlay for text legibility
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding:
                            const EdgeInsets.fromLTRB(10, 40, 10, 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.75),
                            ],
                            stops: const [0.0, 1.0],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.showBrand &&
                                widget.product.vendor != null) ...[
                              Text(
                                widget.product.vendor!.toUpperCase(),
                                style: AppTextStyles.plusJakartaSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.secondary,
                                  letterSpacing: 1.5,
                                  height: 1.0,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                            ],
                            // Product name — max 2 lines, titleCard 15sp w600
                            Text(
                              widget.product.name,
                              style: AppTextStyles.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            // Price — priceCard 16sp w700 gold
                            Text(
                              _formatPrice(widget.product.displayPrice),
                              style: AppTextStyles.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.secondary,
                                height: 1.1,
                              ),
                            ),
                            if ((widget.product.rating ?? 0) > 0) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 12,
                                    color: AppColors.secondary,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    widget.product.rating!.toStringAsFixed(1),
                                    style: AppTextStyles.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  if (widget.product.reviewsCount > 0) ...[
                                    const SizedBox(width: 3),
                                    Text(
                                      '(${widget.product.reviewsCount})',
                                      style: AppTextStyles.plusJakartaSans(
                                        fontSize: 10,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    // ── PROMO badge (top-left) ──────────────────────
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
                            gradient: AppGradients.premiumGold,
                            borderRadius: BorderRadius.circular(AppBorderRadius.xs),
                          ),
                          child: const Text(
                            'PROMO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    // ── Wishlist button (top-right) ─────────────────
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildWishlistButton(isMobile),
                    ),
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

  Widget _buildWishlistButton(bool isSmallScreen) {
    return Semantics(
      label: widget.isInWishlist
          ? 'Hapus dari wishlist'
          : 'Tambahkan ke wishlist',
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
            color: Colors.white.withValues(alpha: 0.9),
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
            size: 16,
          ),
        ),
      ),
    );
  }
}
