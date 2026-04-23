import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme.dart';

class OrderStepsSection extends StatelessWidget {
  const OrderStepsSection({super.key});

  final List<Map<String, dynamic>> _steps = const [
    {
      'icon': Icons.search_outlined,
      'title': 'Jelajahi',
      'description': 'Temukan produk favorit',
    },
    {
      'icon': Icons.shopping_bag_outlined,
      'title': 'Tambah Keranjang',
      'description': 'Pilih ukuran & warna',
    },
    {
      'icon': Icons.credit_card_outlined,
      'title': 'Checkout',
      'description': 'Pembayaran mudah',
    },
    {
      'icon': Icons.local_mall_outlined,
      'title': 'Terima Pesanan',
      'description': 'Paket sampai rumah',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 1),
            const SizedBox(height: 32),
            Text(
              'Cara Belanja',
              style: GoogleFonts.notoSerif(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hanya 4 langkah mudah untuk mendapatkan fashion berkualitas.',
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: _steps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;
                final isLast = index == _steps.length - 1;

                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStepItem(
                          stepNumber: index + 1,
                          icon: step['icon'] as IconData,
                          title: step['title'] as String,
                          description: step['description'] as String,
                        ),
                      ),
                      if (!isLast)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: AppColors.outlineVariant,
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem({
    required int stepNumber,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: AppGradients.primaryDark,
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              color: AppColors.onPrimary,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'Langkah $stepNumber',
            style: GoogleFonts.manrope(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.onSecondaryContainer,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          description,
          style: GoogleFonts.manrope(
            fontSize: 10,
            color: AppColors.onSurfaceVariant,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
