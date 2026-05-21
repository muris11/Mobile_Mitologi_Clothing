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

class _ProductCardState extends State<ProductCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
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
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppImage(
                imageUrl: ApiConfig.buildImageUrl(widget.product.featuredImageUrl),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                borderRadius: 0,
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 48, 12, 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.88),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.showBrand && widget.product.vendor != null) ...[
                        Text(
                          widget.product.vendor!.toUpperCase(),
                          style: AppTextStyles.manrope(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.secondary,
                            letterSpacing: 1.5,
                            height: 1.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        widget.product.name,
                        style: AppTextStyles.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatPrice(widget.product.displayPrice),
                        style: AppTextStyles.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.secondary,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if ((widget.product.rating ?? 0) > 0) ...[
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              widget.product.rating!.toStringAsFixed(1),
                              style: AppTextStyles.manrope(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white70),
                            ),
                            if (widget.product.reviewsCount > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                '(${widget.product.reviewsCount})',
                                style: AppTextStyles.manrope(
                                    fontSize: 10, color: Colors.white54),
                              ),
                            ],
                          ] else ...[
                            Text(
                              'Siap dikirim',
                              style: AppTextStyles.manrope(
                                  fontSize: 10, color: Colors.white54),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.product.onSale)
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'PROMO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: _buildWishlistButton(isMobile),
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
    return GestureDetector(
       behavior: HitTestBehavior.opaque,
       onTap: () {
         AppHaptics.lightImpact();
         widget.onWishlistToggle?.call();
       },
       child: SizedBox(
        width: isSmallScreen ? 28 : 32,
        height: isSmallScreen ? 28 : 32,
        child: Icon(
          widget.isInWishlist ? PhosphorIconsFill.heart : PhosphorIconsRegular.heart,
          color: widget.isInWishlist
              ? AppColors.error
              : AppColors.primary.withValues(alpha: 0.6),
          size: isSmallScreen ? 14 : 18,
        ),
      ),
    );
  }
}
