import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/product_provider.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        final testimonials = provider.testimonials;

        // Don't show if no data from API
        if (testimonials.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1),
                const SizedBox(height: 32),

                // Section Title
                Text(
                  'Apa Kata Mereka',
                  style: GoogleFonts.notoSerif(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Testimoni dari customer yang sudah order di Mitologi Clothing',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Horizontal scrollable testimonials
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: testimonials.length,
                    padding: const EdgeInsets.only(right: 24),
                    itemBuilder: (context, index) {
                      final testimonial = testimonials[index];
                      final name =
                          testimonial['name']?.toString() ?? 'Anonymous';
                      final role =
                          testimonial['role']?.toString() ?? 'Customer';
                      final content = testimonial['content']?.toString() ??
                          testimonial['testimonial']?.toString() ??
                          '';
                      final rating = testimonial['rating'] ?? 5;

                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                          child: Container(
                          width: 300,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.surfaceContainerLowest,
                                AppColors.surfaceContainerLow,
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(AppBorderRadius.xxl),
                            boxShadow: [
                              AppShadows.cardSoft,
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Rating stars
                              Row(
                                children: List.generate(5, (i) {
                                  return Icon(
                                    i < rating ? Icons.star : Icons.star_border,
                                    color: i < rating
                                        ? Colors.amber
                                        : AppColors.outline,
                                    size: 16,
                                  );
                                }),
                              ),
                              const SizedBox(height: 12),

                              // Testimonial content
                              Expanded(
                                child: Text(
                                  content,
                                  style: GoogleFonts.manrope(
                                    fontSize: 13,
                                    color: AppColors.onSurface,
                                    height: 1.5,
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Name and role
                              Text(
                                name,
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                role,
                                style: GoogleFonts.manrope(
                                  fontSize: 11,
                                  color: AppColors.onSurfaceVariant,
                                ),
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
      },
    );
  }
}
