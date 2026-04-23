import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/common/interactive_widgets.dart';

class HeroSection extends StatelessWidget {
  final List<Map<String, dynamic>> heroSlides;
  final int currentHeroIndex;
  final Function(int) onPageChanged;

  const HeroSection({
    super.key,
    required this.heroSlides,
    required this.currentHeroIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final heroHeight = ResponsiveConfig.getResponsiveValue<double>(
      context: context,
      mobile: 220.0,
      tablet: 300.0,
      desktop: 380.0,
    );

    return SliverToBoxAdapter(
      child: Column(
        children: [
          SizedBox(
            height: heroHeight,
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.92),
              onPageChanged: onPageChanged,
              itemCount: heroSlides.length,
              itemBuilder: (context, index) {
                final slide = heroSlides[index];
                String? imageUrl = slide['imageUrl'] ??
                    slide['image_url'] ??
                    slide['image'] ??
                    slide['url'] ??
                    slide['src'] ??
                    slide['path'];

                if (imageUrl != null &&
                    imageUrl.isNotEmpty &&
                    !imageUrl.startsWith('http')) {
                  imageUrl =
                      'https://adminmitologiclothing.center.biz.id/storage/$imageUrl';
                }

                final title = slide['title'] ??
                    slide['heading'] ??
                    slide['headline'] ??
                    '';
                final subtitle = slide['subtitle'] ??
                    slide['description'] ??
                    slide['desc'] ??
                    '';
                final ctaText = slide['ctaText'] ??
                    slide['cta_text'] ??
                    slide['buttonText'] ??
                    'Lihat Produk';
                final ctaLink = slide['ctaLink'] ??
                    slide['cta_link'] ??
                    slide['buttonLink'] ??
                    '/products';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: InteractiveScale(
                    onTap: () {
                      if (ctaLink.toString().startsWith('/')) {
                        context.push(ctaLink.toString());
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background Image
                          imageUrl != null && imageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: AppColors.surfaceContainerLow,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: AppColors.surfaceContainerHigh,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.broken_image_outlined,
                                            size: 48,
                                            color: AppColors.outline),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Gambar tidak tersedia',
                                          style: GoogleFonts.manrope(
                                            fontSize: 12,
                                            color: AppColors.outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(
                                  color: AppColors.surfaceContainerHigh,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image_not_supported_outlined,
                                          size: 48, color: AppColors.outline),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tidak ada gambar',
                                        style: GoogleFonts.manrope(
                                          fontSize: 12,
                                          color: AppColors.outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                          // Dramatic Gradient Overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: const [0.0, 0.35, 0.65, 1.0],
                                colors: [
                                  Colors.black.withValues(alpha: 0.15),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.4),
                                  Colors.black.withValues(alpha: 0.85),
                                ],
                              ),
                            ),
                          ),

                          // Content at bottom
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (subtitle.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary.withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      subtitle.toString(),
                                      style: GoogleFonts.manrope(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSecondaryContainer,
                                      ),
                                    ),
                                  ),
                                if (title.isNotEmpty)
                                  Text(
                                    title.toString(),
                                    style: GoogleFonts.notoSerif(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1.2,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                // Floating CTA button
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.95),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        ctaText.toString(),
                                        style: GoogleFonts.manrope(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Modern page indicators - pill style
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              heroSlides.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutQuart,
                width: currentHeroIndex == index ? 28 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: currentHeroIndex == index
                      ? AppColors.primary
                      : AppColors.outline.withValues(alpha: 0.35),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
