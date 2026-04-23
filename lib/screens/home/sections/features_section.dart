import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  final List<Map<String, dynamic>> _features = const [
    {
      'icon': Icons.local_shipping_outlined,
      'title': 'Gratis Ongkir',
      'subtitle': 'Pengiriman cepat',
    },
    {
      'icon': Icons.headset_mic_outlined,
      'title': '24/7 Support',
      'subtitle': 'Siap membantu Anda',
    },
    {
      'icon': Icons.verified_user_outlined,
      'title': 'Pembayaran Aman',
      'subtitle': 'Transaksi terenkripsi',
    },
    {
      'icon': Icons.replay_outlined,
      'title': 'Mudah Return',
      'subtitle': '7 hari garansi retur',
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
              'Mengapa Memilih Kami',
              style: GoogleFonts.notoSerif(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kami berkomitmen memberikan pengalaman belanja terbaik dengan layanan premium.',
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: _features.asMap().entries.map((entry) {
                final index = entry.key;
                final feature = entry.value;
                final isLast = index == _features.length - 1;

                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildFeatureCard(
                          icon: feature['icon'] as IconData,
                          title: feature['title'] as String,
                          subtitle: feature['subtitle'] as String,
                        ),
                      ),
                      if (!isLast) const SizedBox(width: 12),
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

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppGradients.cardSoft,
        borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
        boxShadow: [
          AppShadows.cardSoft,
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(height: 10),
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
            subtitle,
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
      ),
    );
  }
}
