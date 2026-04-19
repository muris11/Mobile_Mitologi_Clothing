import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/product_provider.dart';

class PromoSection extends StatelessWidget {
  const PromoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        // Get first promo from API, fallback to empty if no promos
        final promo = provider.promos.isNotEmpty ? provider.promos.first : null;

        // If no promo from API, hide the section
        if (promo == null) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        final title = promo['title'] as String? ?? 'Penawaran Eksklusif';
        final description = promo['description'] as String? ?? '';
        final promoCode = promo['promo_code'] as String? ?? '';
        final promoUrl = promo['url'] as String? ?? '/products';

        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: GestureDetector(
              onTap: () => context.push(promoUrl),
              child: Container(
                height: 168,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
                  boxShadow: [AppShadows.card],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -36,
                      top: -24,
                      child: Container(
                        width: 148,
                        height: 148,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.notoSerif(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              height: 1.5,
                              color:
                                  AppColors.onPrimary.withValues(alpha: 0.75),
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              if (promoCode.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.onPrimary
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(
                                        AppBorderRadius.full),
                                  ),
                                  child: Text(
                                    'Kode: $promoCode',
                                    style: GoogleFonts.manrope(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                      color: AppColors.secondaryContainer,
                                    ),
                                  ),
                                ),
                              const Spacer(),
                              TextButton(
                                onPressed: () => context.push(promoUrl),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.onPrimary,
                                ),
                                child: const Text('Belanja Sekarang'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
