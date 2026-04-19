import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme.dart';

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
            Text(
              'Kategori',
              style: GoogleFonts.notoSerif(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];

                  // Try multiple possible field names
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

                  // Build full URL if needed
                  if (imageUrl != null &&
                      imageUrl.isNotEmpty &&
                      !imageUrl.startsWith('http')) {
                    imageUrl =
                        'https://adminmitologi.based.my.id/storage/$imageUrl';
                  }

                  return GestureDetector(
                    onTap: () {
                      if (handle.isNotEmpty) {
                        context.push('/products?category=$handle');
                      }
                    },
                    child: Container(
                      width: 85,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.shadow.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: imageUrl != null && imageUrl.isNotEmpty
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
                                        child: Icon(
                                          Icons.category,
                                          color: AppColors.secondary,
                                          size: 28,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: AppColors.surfaceContainerHigh,
                                      child: Icon(
                                        Icons.category,
                                        color: AppColors.secondary,
                                        size: 28,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            name,
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
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
}
