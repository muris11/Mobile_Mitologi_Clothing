import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme.dart';
import '../../models/product.dart';

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

        // Calculate available height and adjust aspect ratio accordingly
        final availableHeight = constraints.maxHeight;
        final imageHeight = availableHeight > 0
            ? availableHeight * 0.65 // Image takes 65% of height
            : (isSmallScreen ? 120.0 : 160.0); // Fallback

        return GestureDetector(
          onTap: onTap ?? () => context.push('/product/${product.handle}'),
          child: Container(
            width: cardWidth == double.infinity ? null : cardWidth,
            height: availableHeight > 0 ? availableHeight : null,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image Section with fixed height
                SizedBox(
                  height: imageHeight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(isSmallScreen ? 12 : 16),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildProductImage(),
                        // Wishlist button
                        Positioned(
                          top: isSmallScreen ? 4 : 6,
                          right: isSmallScreen ? 4 : 6,
                          child: Container(
                            width: isSmallScreen ? 24 : 28,
                            height: isSmallScreen ? 24 : 28,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.shadow.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: isSmallScreen ? 12 : 14,
                              icon: Icon(
                                isInWishlist
                                    ? Icons.favorite
                                    : Icons.favorite_outline,
                                color: isInWishlist ? AppColors.error : null,
                              ),
                              onPressed: onWishlistToggle,
                            ),
                          ),
                        ),
                        // Discount badge
                        if (product.isOnSale &&
                            product.discountPercentage != null)
                          Positioned(
                            top: isSmallScreen ? 4 : 6,
                            left: isSmallScreen ? 4 : 6,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 4 : 6,
                                vertical: isSmallScreen ? 2 : 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '-${product.discountPercentage}%',
                                style: GoogleFonts.manrope(
                                  fontSize: isSmallScreen ? 8 : 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // Content Section - Compact
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
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
                              fontWeight: FontWeight.w600,
                              color: AppColors.outline,
                              letterSpacing: 0.5,
                              height: 1.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: isSmallScreen ? 1 : 2),
                        ],
                        Text(
                          product.title,
                          style: GoogleFonts.manrope(
                            fontSize: isSmallScreen ? 11 : 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: isSmallScreen ? 1 : 2),
                        // Price Row - Single line
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                formattedPrice,
                                style: GoogleFonts.manrope(
                                  fontSize: isSmallScreen ? 10 : 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondary,
                                  height: 1.0,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (product.isOnSale &&
                                product.compareAtPrice != null) ...[
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  product.compareAtPrice!.formatted,
                                  style: GoogleFonts.manrope(
                                    fontSize: isSmallScreen ? 8 : 9,
                                    fontWeight: FontWeight.w400,
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
        );
      },
    );
  }

  Widget _buildProductImage() {
    final imageUrl = product.featuredImage?.url;

    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: AppColors.surfaceContainerHigh,
        child: const Icon(Icons.image_not_supported, size: 32),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColors.surfaceContainerLow,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.surfaceContainerHigh,
        child: const Icon(Icons.image_not_supported, size: 32),
      ),
    );
  }
}
