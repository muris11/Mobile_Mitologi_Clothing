import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme.dart';
import '../../../widgets/common/interactive_widgets.dart';

class CategoriesSection extends StatelessWidget {
  final List<Map<String, dynamic>> categories;

  const CategoriesSection({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kategori',
                  style: GoogleFonts.notoSerif(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: -0.3,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/shop'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lihat Semua',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_forward_rounded, size: 14),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                padding: const EdgeInsets.only(right: 8),
                itemBuilder: (context, index) {
                  final category = categories[index];

                  String? imageUrl = category['imageUrl'] ??
                      category['image_url'] ??
                      category['image'] ??
                      category['icon'] ??
                      category['thumbnail'];

                  final name = category['name'] ??
                      category['title'] ??
                      category['label'] ??
                      'Kategori';
                  final handle = category['handle'] ?? category['slug'] ?? '';

                  if (imageUrl != null &&
                      imageUrl.isNotEmpty &&
                      !imageUrl.startsWith('http')) {
                    imageUrl =
                        'https://adminmitologiclothing.center.biz.id/storage/$imageUrl';
                  }

                  // Soft pastel backgrounds based on index
                  final bgColors = [
                    [const Color(0xFFFFF8E1), const Color(0xFFFFECB3)],
                    [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
                    [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
                    [const Color(0xFFF3E5F5), const Color(0xFFE1BEE7)],
                    [const Color(0xFFFFEBEE), const Color(0xFFFFCDD2)],
                    [const Color(0xFFE0F7FA), const Color(0xFFB2EBF2)],
                    [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
                    [const Color(0xFFE8EAF6), const Color(0xFFC5CAE9)],
                  ];
                  final bgPair = bgColors[index % bgColors.length];

                  return InteractiveScale(
                    onTap: () {
                      if (handle.isNotEmpty) {
                        context.push('/products?category=$handle');
                      }
                    },
                    child: Container(
                      width: 90,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Container(
                            width: 74,
                            height: 74,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: bgPair,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: bgPair[1].withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: imageUrl != null && imageUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: bgPair[0],
                                      ),
                                      errorWidget: (context, url, error) =>
                                          _buildFallbackIcon(bgPair[1]),
                                    )
                                  : _buildFallbackIcon(bgPair[1]),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            name.toString(),
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(Color color) {
    return Container(
      color: color.withValues(alpha: 0.2),
      child: Center(
        child: Icon(
          Icons.category_outlined,
          color: color.withValues(alpha: 0.8),
          size: 28,
        ),
      ),
    );
  }
}
