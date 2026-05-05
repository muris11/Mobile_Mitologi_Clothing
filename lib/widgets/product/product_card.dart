import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_model.dart';
import 'package:mitologi_clothing_mobile/utils/haptic_feedback.dart';
import 'package:mitologi_clothing_mobile/widgets/common/interactive_widgets.dart';
import 'package:mitologi_clothing_mobile/widgets/common/shimmer_image.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProductCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = width ?? constraints.maxWidth;
        final isSmallScreen = cardWidth < 160;
        final availableHeight = constraints.maxHeight;
        final imageHeight = availableHeight > 0
            ? availableHeight * 0.6
            : (isSmallScreen ? 136.0 : 176.0);

        return InteractiveScale(
          onTap: onTap ??
              () {
                AppHaptics.tap();
                context.push('/product/${product.slug}');
              },
          child: Container(
            width: cardWidth == double.infinity ? null : cardWidth,
            height: availableHeight > 0 ? availableHeight : null,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: imageHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildProductImage(),
                        if (product.onSale)
                          Positioned(
                            left: 12,
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xD6142033),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'PROMO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          top: isSmallScreen ? 8 : 10,
                          right: isSmallScreen ? 8 : 10,
                          child: _buildWishlistButton(isSmallScreen),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (showBrand && product.vendor != null) ...[
                            Text(
                              product.vendor!.toUpperCase(),
                              style: GoogleFonts.manrope(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.outline,
                                letterSpacing: 0.8,
                                height: 1.0,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: isSmallScreen ? 2 : 4),
                          ],
                          Text(
                            product.name,
                            style: GoogleFonts.manrope(
                              fontSize: isSmallScreen ? 12 : 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF253041),
                              height: 1.28,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  _formatPrice(product.displayPrice),
                                  style: GoogleFonts.manrope(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                    height: 1.0,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if ((product.rating ?? 0) > 0) ...[
                                const Icon(
                                  PhosphorIconsFill.star,
                                  size: 13,
                                  color: Color(0xFFB9955B),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  product.rating!.toStringAsFixed(1),
                                  style: GoogleFonts.manrope(
                                    fontSize: 11,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                              if ((product.rating ?? 0) > 0 &&
                                  product.reviewsCount > 0)
                                Container(
                                  width: 3,
                                  height: 3,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  decoration: const BoxDecoration(
                                    color: AppColors.outlineVariant,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              if (product.reviewsCount > 0)
                                Expanded(
                                  child: Text(
                                    '${product.reviewsCount} review',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.manrope(
                                      fontSize: 11,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                )
                              else
                                Expanded(
                                  child: Text(
                                    'Siap dikirim',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.manrope(
                                      fontSize: 11,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _buildVariantLabel(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.manrope(
                                    fontSize: 11,
                                    color: AppColors.outline,
                                  ),
                                ),
                              ),
                              if (product.stock > 0 && product.stock <= 5)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF1F2),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: const Color(0xFFFFD5DB),
                                    ),
                                  ),
                                  child: Text(
                                    'Sisa ${product.stock}',
                                    style: GoogleFonts.manrope(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFFE53935),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWishlistButton(bool isSmallScreen) {
    return InteractiveScale(
      onTap: () {
        AppHaptics.addToCart();
        onWishlistToggle?.call();
      },
      scaleDown: 0.85,
      child: Container(
        width: isSmallScreen ? 28 : 32,
        height: isSmallScreen ? 28 : 32,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          isInWishlist
              ? Icons.favorite_rounded
              : Icons.favorite_outline_rounded,
          color: isInWishlist
              ? const Color(0xFFE53935)
              : AppColors.onSurfaceVariant,
          size: isSmallScreen ? 14 : 16,
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Hero(
      tag: 'product-image-${product.id}',
      child: ShimmerImage(
        imageUrl: ApiConfig.buildImageUrl(product.featuredImageUrl),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
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

  String _buildVariantLabel() {
    if (product.stock <= 0) {
      return 'Stok habis';
    }

    if (product.onSale) {
      return 'Promo tersedia';
    }

    return 'Siap dikirim';
  }
}
