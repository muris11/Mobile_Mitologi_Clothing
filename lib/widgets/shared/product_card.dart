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
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            border: Border.all(
                color: AppColors.outlineVariant),
            boxShadow: [AppShadows.card],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(AppBorderRadius.lg)),
                    child: AspectRatio(
                      aspectRatio: 0.75, // Lock at premium 3:4 ratio as specified in design.md
                      child: AppImage(
                        imageUrl: ApiConfig.buildImageUrl(widget.product.featuredImageUrl),
                        borderRadius: 0,
                      ),
                    ),
                  ),
                  if (widget.product.onSale)
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                        ),
                        child: Text(
                          'DISKON',
                          style: AppTextStyles.manrope(
                            color: AppColors.error,
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
                    if (widget.showBrand && widget.product.vendor != null) ...[
                      Text(
                        widget.product.vendor!.toUpperCase(),
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
                      widget.product.name,
                      style: AppTextStyles.plusJakartaSans(
                        fontSize: nameFontSize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(2),
                    if (widget.product.rating != null && widget.product.rating! > 0) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...List.generate(5, (i) {
                            final filled = i < widget.product.rating!.round();
                            return Icon(
                              filled ? PhosphorIconsFill.star : PhosphorIconsRegular.star,
                              color: filled ? const Color(0xFFFFC107) : AppColors.onSurface.withValues(alpha: 0.3),
                              size: isMobile ? 11 : 13,
                            );
                          }),
                          const Gap(4),
                          Text(
                            '${widget.product.rating!.toStringAsFixed(1)} (${widget.product.reviewsCount})',
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
                      CurrencyFormatter.formatIDR(widget.product.displayPrice),
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
      ),
    );
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
