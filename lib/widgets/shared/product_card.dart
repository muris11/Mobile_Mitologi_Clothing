import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_model.dart';
import 'package:mitologi_clothing_mobile/core/utils/currency_formatter.dart';
import 'package:mitologi_clothing_mobile/core/utils/haptic_feedback.dart';
import 'package:mitologi_clothing_mobile/core/utils/responsive_utils.dart';
import 'package:mitologi_clothing_mobile/core/widgets/app_image.dart';
import 'package:mitologi_clothing_mobile/core/widgets/glass_container.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';
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
    final cardWidth = width ?? double.infinity;
    final radius = ResponsiveConfig.borderRadius(context, base: 28);
    final padH = ResponsiveConfig.value(
        context: context, mobile: 12.0, tablet: 16.0, desktop: 20.0);
    final padV = ResponsiveConfig.value(
        context: context, mobile: 8.0, tablet: 10.0, desktop: 12.0);
    final nameFontSize = ResponsiveConfig.sp(context, 13);
    final priceFontSize = ResponsiveConfig.sp(context, 14);
    final brandFontSize = ResponsiveConfig.sp(context, 9);
    final isMobile = ResponsiveConfig.isMobile(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap ??
          () {
            AppHaptics.tap();
            context.push('/product/${product.slug}');
          },
      child: Container(
        width: cardWidth == double.infinity ? null : cardWidth,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.55)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(radius)),
                  child: AspectRatio(
                    aspectRatio: isMobile ? 0.88 : 0.85,
                    child: AppImage(
                      imageUrl: ApiConfig.buildImageUrl(product.featuredImageUrl),
                      borderRadius: 0,
                    ),
                  ),
                ),
                if (product.onSale)
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'PILIHAN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GlassContainer(
                    padding: EdgeInsets.zero,
                    blur: 12,
                    borderRadius: AppBorderRadius.circular,
                    child: _buildWishlistButton(isMobile),
                  ),
                ),
              ],
            ),
              Padding(
              padding: EdgeInsets.fromLTRB(padH, padV, padH, padH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showBrand && product.vendor != null) ...[
                    Text(
                      product.vendor!.toUpperCase(),
                      style: AppTextStyles.manrope(
                        fontSize: brandFontSize,
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondary,
                        letterSpacing: 1.5,
                        height: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(2),
                  ],
                  Text(
                    product.name,
                    style: AppTextStyles.plusJakartaSans(
                      fontSize: nameFontSize,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(2),
                  if (product.rating != null && product.rating! > 0) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...List.generate(5, (i) {
                          final filled = i < product.rating!.round();
                          return Icon(
                            filled ? PhosphorIconsFill.star : PhosphorIconsRegular.star,
                            color: filled ? const Color(0xFFFFC107) : AppColors.onSurface.withValues(alpha: 0.3),
                            size: isMobile ? 11 : 13,
                          );
                        }),
                        const Gap(4),
                        Text(
                          '${product.rating!.toStringAsFixed(1)} (${product.reviewsCount})',
                          style: AppTextStyles.manrope(
                            fontSize: ResponsiveConfig.sp(context, 10),
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const Gap(2),
                  ],
                  Text(
                    CurrencyFormatter.formatIDR(product.displayPrice),
                    style: AppTextStyles.notoSerif(
                      fontSize: priceFontSize,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistButton(bool isSmallScreen) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        AppHaptics.lightImpact();
        onWishlistToggle?.call();
      },
      child: SizedBox(
        width: isSmallScreen ? 28 : 32,
        height: isSmallScreen ? 28 : 32,
        child: Icon(
          isInWishlist ? PhosphorIconsFill.heart : PhosphorIconsRegular.heart,
          color: isInWishlist
              ? const Color(0xFFE53935)
              : AppColors.primary.withValues(alpha: 0.6),
          size: isSmallScreen ? 14 : 18,
        ),
      ),
    );
  }
}
