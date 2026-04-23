import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../config/theme.dart';
import '../../../providers/product_provider.dart';

class MaterialsSection extends StatelessWidget {
  const MaterialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        final materials = provider.materials;

        if (materials.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1),
                const SizedBox(height: 32),
                Text(
                  'Pilihan Bahan',
                  style: GoogleFonts.notoSerif(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kenali jenis bahan yang kami gunakan',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: materials.length,
                    padding: const EdgeInsets.only(right: 24),
                    itemBuilder: (context, index) {
                      return _MaterialCard(material: materials[index]);
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

class _MaterialCard extends StatelessWidget {
  final Map<String, dynamic> material;

  const _MaterialCard({required this.material});

  @override
  Widget build(BuildContext context) {
    final name = material['name']?.toString() ?? 'Material';
    final description = material['description']?.toString() ?? '';
    final colorTheme = material['colorTheme']?.toString() ??
        material['color_theme']?.toString() ??
        'bg-blue-100';

    final colors = _getColorsFromTheme(colorTheme);

    return Padding(
      padding: const EdgeInsets.only(right: 12),
        child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.bgColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            AppShadows.cardSoft,
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.checkroom,
                color: colors.textColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colors.textColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                description,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  color: colors.textColor.withValues(alpha: 0.8),
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _MaterialColors _getColorsFromTheme(String colorTheme) {
    if (colorTheme.contains('green')) {
      return _MaterialColors(
        bgColor: const Color(0xFFDCFCE7),
        textColor: const Color(0xFF166534),
      );
    } else if (colorTheme.contains('slate') || colorTheme.contains('gray')) {
      return _MaterialColors(
        bgColor: const Color(0xFFF1F5F9),
        textColor: const Color(0xFF475569),
      );
    } else if (colorTheme.contains('indigo') || colorTheme.contains('blue')) {
      return _MaterialColors(
        bgColor: const Color(0xFFE0E7FF),
        textColor: const Color(0xFF3730A3),
      );
    } else if (colorTheme.contains('amber') || colorTheme.contains('yellow')) {
      return _MaterialColors(
        bgColor: const Color(0xFFFEF3C7),
        textColor: const Color(0xFF92400E),
      );
    } else if (colorTheme.contains('teal')) {
      return _MaterialColors(
        bgColor: const Color(0xFFCCFBF1),
        textColor: const Color(0xFF0F766E),
      );
    }
    return _MaterialColors(
      bgColor: AppColors.surfaceContainerLowest,
      textColor: AppColors.primary,
    );
  }
}

class _MaterialColors {
  final Color bgColor;
  final Color textColor;

  const _MaterialColors({required this.bgColor, required this.textColor});
}
