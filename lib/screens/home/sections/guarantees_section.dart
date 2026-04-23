import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/product_provider.dart';

class GuaranteesSection extends StatelessWidget {
  const GuaranteesSection({super.key});

  IconData _getIconFromName(String iconName) {
    // Handle heroicon format from backend (heroicon-o-xxx)
    final cleanName = iconName
        .toLowerCase()
        .replaceAll('heroicon-o-', '')
        .replaceAll('heroicon-s-', '')
        .replaceAll('heroicon-m-', '')
        .replaceAll('-', '_');

    switch (cleanName) {
      case 'timer':
      case 'time':
      case 'clock':
      case 'clock_24':
        return Icons.timer;
      case 'verified':
      case 'check':
      case 'check_circle':
      case 'shield_check':
      case 'shield':
        return Icons.verified;
      case 'card_giftcard':
      case 'gift':
      case 'bonus':
        return Icons.card_giftcard;
      case 'local_shipping':
      case 'shipping':
      case 'truck':
        return Icons.local_shipping;
      case 'assignment_return':
      case 'return':
      case 'arrow_uturn_left':
        return Icons.assignment_return;
      case 'pencil_square':
      case 'pencil':
      case 'edit':
        return Icons.edit;
      case 'bolt':
      case 'flash':
        return Icons.flash_on;
      case 'users':
      case 'group':
      case 'people':
        return Icons.people;
      case 'currency_dollar':
      case 'dollar':
      case 'money':
        return Icons.attach_money;
      case 'chat_bubble_left_right':
      case 'chat':
      case 'message':
        return Icons.chat;
      case 'star':
        return Icons.star;
      default:
        return Icons.verified; // Default icon for guarantees
    }
  }

  Widget _buildGuaranteeSlideCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceContainerLowest,
            AppColors.surfaceContainerLow,
          ],
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
        boxShadow: [
          AppShadows.cardSoft,
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        final guarantees = provider.guarantees;

        // If no data from API, don't show section
        if (guarantees.isEmpty) {
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
                  'Si & Bonus Eksklusif',
                  style: GoogleFonts.notoSerif(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kami tidak hanya berkomitmen pada kualitas, tapi juga memberikan apresiasi lebih untuk setiap pesanan Anda.',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Horizontal scrollable cards from API
                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: guarantees.length,
                    padding: const EdgeInsets.only(right: 24),
                    itemBuilder: (context, index) {
                      final guarantee = guarantees[index];

                      // Backend Feature model: title, description, icon, sort_order
                      // SiteSettings (JSON): title/name, description/desc/content, icon, color
                      final title = guarantee['title']?.toString() ??
                          guarantee['name']?.toString() ??
                          'Garansi';
                      final description =
                          guarantee['description']?.toString() ??
                              guarantee['desc']?.toString() ??
                              guarantee['content']?.toString() ??
                              '';
                      final iconName =
                          guarantee['icon']?.toString() ?? 'verified';

                      // Color dari API atau fallback ke rotation warna
                      final colorName = guarantee['color']?.toString();
                      Color color = AppColors.primary;
                      if (colorName == 'secondary') color = AppColors.secondary;
                      if (colorName == 'tertiary') color = AppColors.tertiary;
                      if (colorName == null || colorName == 'primary') {
                        // Rotasi warna jika tidak ada color dari API
                        if (index % 3 == 1) color = AppColors.secondary;
                        if (index % 3 == 2) color = AppColors.tertiary;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _buildGuaranteeSlideCard(
                          icon: _getIconFromName(iconName),
                          title: title,
                          description: description,
                          color: color,
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
