import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme.dart';
import '../../models/product.dart';
import '../../utils/haptic_feedback.dart';
import '../common/interactive_widgets.dart';
import '../common/quick_view_sheet.dart';
import '../common/shimmer_image.dart';

class ProductCard extends StatelessWidget {
  final Product product;
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
    final price = product.price;
    final formattedPrice = price?.formatted ?? 'Rp 0';
    final vendor = (product.vendor ?? '').trim();

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = width ?? constraints.maxWidth;
        final isSmallScreen = cardWidth < 160;
        final availableHeight = constraints.maxHeight;
        final imageHeight = availableHeight > 0
            ? availableHeight * 0.62
            : (isSmallScreen ? 120.0 : 160.0);

        return InteractiveScale(
          onTap: onTap ?? () {
            AppHaptics.tap();
            context.push('/product/${product.handle}');
          },
          child: Container(
            width: cardWidth == double.infinity ? null : cardWidth,
            height: availableHeight > 0 ? availableHeight : null,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
              boxShadow: [
                AppShadows.cardSoft,
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image Section with soft edge fade
                  SizedBox(
                    height: imageHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildProductImage(),
                        // Bottom soft fade for seamless text overlay
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Quick view button
                        Positioned(
                          top: isSmallScreen ? 8 : 10,
                          right: isSmallScreen ? 40 : 46,
                          child: Builder(
                            builder: (context) => _buildQuickViewButton(
                              context,
                              isSmallScreen,
                            ),
                          ),
                        ),
                        // Wishlist button - floating style
                        Positioned(
                          top: isSmallScreen ? 8 : 10,
                          right: isSmallScreen ? 8 : 10,
                          child: _buildWishlistButton(isSmallScreen),
                        ),
                        // Discount badge - bold style
                        if (product.isOnSale &&
                            product.discountPercentage != null)
                          Positioned(
                            top: isSmallScreen ? 8 : 10,
                            left: isSmallScreen ? 8 : 10,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 6 : 8,
                                vertical: isSmallScreen ? 3 : 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFE53935),
                                    Color(0xFFC62828),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFE53935).withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                '-${product.discountPercentage}%',
                                style: GoogleFonts.manrope(
                                  fontSize: isSmallScreen ? 9 : 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Content Section
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        isSmallScreen ? 10 : 12,
                        isSmallScreen ? 6 : 8,
                        isSmallScreen ? 10 : 12,
                        isSmallScreen ? 10 : 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (showBrand && vendor.isNotEmpty) ...[
                            Text(
                              vendor.toUpperCase(),
                              style: GoogleFonts.manrope(
                                fontSize: isSmallScreen ? 8 : 9,
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
                            product.title,
                            style: GoogleFonts.manrope(
                              fontSize: isSmallScreen ? 11 : 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          // Price Row - Bold and prominent
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  formattedPrice,
                                  style: GoogleFonts.manrope(
                                    fontSize: isSmallScreen ? 12 : 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.secondary,
                                    height: 1.0,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (product.isOnSale &&
                                  product.compareAtPrice != null) ...[
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    product.compareAtPrice!.formatted,
                                    style: GoogleFonts.manrope(
                                      fontSize: isSmallScreen ? 9 : 10,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.outline,
                                      decoration: TextDecoration.lineThrough,
                                      height: 1.0,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
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
          color: Colors.white.withValues(alpha: 0.95),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isInWishlist ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
          color: isInWishlist ? const Color(0xFFE53935) : AppColors.onSurfaceVariant,
          size: isSmallScreen ? 14 : 16,
        ),
      ),
    );
  }

  Widget _buildQuickViewButton(BuildContext context, bool isSmallScreen) {
    return InteractiveScale(
      onTap: () {
        AppHaptics.tap();
        QuickViewBottomSheet.show(context, product);
      },
      scaleDown: 0.85,
      child: Container(
        width: isSmallScreen ? 28 : 32,
        height: isSmallScreen ? 28 : 32,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.visibility_outlined,
          color: AppColors.onSurfaceVariant,
          size: isSmallScreen ? 14 : 16,
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    final imageUrl = product.featuredImage?.url;

    return Hero(
      tag: 'product-image-${product.id}',
      child: ShimmerImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
