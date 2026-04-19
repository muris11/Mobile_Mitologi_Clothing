import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme.dart';
import '../../../utils/responsive_utils.dart';

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
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SizedBox(
            height: ResponsiveConfig.getResponsiveValue(
              context: context,
              mobile: 200,
              tablet: 280,
              desktop: 350,
            ),
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.9),
              onPageChanged: onPageChanged,
              itemCount: heroSlides.length,
              itemBuilder: (context, index) {
                final slide = heroSlides[index];

                // Try multiple possible field names for image URL
                String? imageUrl = slide['imageUrl'] ??
                    slide['image_url'] ??
                    slide['image'] ??
                    slide['url'] ??
                    slide['src'] ??
                    slide['path'];

                // If image URL is a relative path, prepend the base URL
                if (imageUrl != null &&
                    imageUrl.isNotEmpty &&
                    !imageUrl.startsWith('http')) {
                  imageUrl =
                      'https://adminmitologi.based.my.id/storage/$imageUrl';
                }

                final title = slide['title'] ??
                    slide['heading'] ??
                    slide['headline'] ??
                    '';
                final subtitle = slide['subtitle'] ??
                    slide['description'] ??
                    slide['desc'] ??
                    '';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
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
                                errorWidget: (context, url, error) => Container(
                                  color: AppColors.surfaceContainerHigh,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.broken_image,
                                          size: 48, color: Colors.grey),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Gambar tidak tersedia',
                                        style: GoogleFonts.manrope(
                                          fontSize: 12,
                                          color: Colors.grey,
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
                                    const Icon(Icons.image_not_supported,
                                        size: 48, color: Colors.grey),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tidak ada gambar',
                                      style: GoogleFonts.manrope(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                        // Gradient Overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (subtitle.isNotEmpty)
                                Text(
                                  subtitle,
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              if (title.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  title,
                                  style: GoogleFonts.notoSerif(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              heroSlides.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: currentHeroIndex == index ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: currentHeroIndex == index
                      ? AppColors.primary
                      : AppColors.outline.withValues(alpha: 0.5),
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
