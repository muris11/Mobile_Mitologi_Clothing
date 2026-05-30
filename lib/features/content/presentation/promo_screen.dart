import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';
import 'package:mitologi_clothing_mobile/widgets/common/premium_back_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

const _promos = [
  {
    'title': 'Gratis Ongkir',
    'subtitle': 'Untuk semua pesanan di atas Rp 200.000',
    'badge': 'Gratis Ongkir',
    'desc':
        'Nikmati gratis ongkos kirim ke seluruh Indonesia untuk setiap pembelian minimum Rp 200.000.',
    'color': 0xFF10B981,
    'bg': 0xFFECFDF5,
    'icon': PhosphorIconsFill.truck,
    'terms':
        'Berlaku untuk semua jasa pengiriman reguler. Minimum pembelian Rp 200.000.',
  },
  {
    'title': 'Diskon Member Baru',
    'subtitle': 'Diskon 10% untuk pembelian pertama',
    'badge': 'Member Baru',
    'desc':
        'Daftar sekarang dan dapatkan diskon 10% untuk pembelian pertama Anda!',
    'color': 0xFF7C3AED,
    'bg': 0xFFF5F3FF,
    'icon': PhosphorIconsFill.star,
    'terms': 'Berlaku untuk member baru. Satu kali penggunaan per akun.',
  },
  {
    'title': 'Cashback Pembelian Bulk',
    'subtitle': 'Cashback hingga 15% untuk pesanan partai',
    'badge': 'Pesanan Partai',
    'desc':
        'Pesan dalam jumlah besar (min. 24 pcs) dan dapatkan cashback hingga 15%.',
    'color': 0xFFB45309,
    'bg': 0xFFFFFBEB,
    'icon': PhosphorIconsFill.package,
    'terms': 'Berlaku untuk pesanan minimal 24 pcs dalam satu transaksi.',
  },
];

const _benefits = [
  {
    'title': 'Kualitas Premium',
    'desc': 'Bahan berkualitas tinggi dengan jahitan rapi dan tahan lama.',
    'icon': PhosphorIconsFill.medal,
    'color': 0xFF7C3AED,
  },
  {
    'title': 'Desain Custom',
    'desc': 'Tersedia layanan desain custom sesuai kebutuhan Anda.',
    'icon': PhosphorIconsFill.pencilSimple,
    'color': 0xFF1D4ED8,
  },
  {
    'title': 'Pengiriman Cepat',
    'desc': 'Proses cepat dan pengiriman ke seluruh Indonesia.',
    'icon': PhosphorIconsFill.rocket,
    'color': 0xFF059669,
  },
];

class PromoScreen extends StatelessWidget {
  const PromoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: PremiumBackButton(onPressed: () => context.pop()),
        leadingWidth: 64,
        title: Text(
          'Promo & Penawaran',
          style: AppTextStyles.plusJakartaSans(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: AppColors.primary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            height: 0.5,
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(context),
            const Gap(24),
            Text(
              'Promo Aktif',
              style: AppTextStyles.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: AppColors.onBackground,
              ),
            ),
            const Gap(12),
            ..._promos.map((p) => _buildPromoCard(p)),
            const Gap(24),
            Text(
              'Keuntungan Berbelanja',
              style: AppTextStyles.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: AppColors.onBackground,
              ),
            ),
            const Gap(12),
            _buildBenefitsGrid(),
            const Gap(24),
            _buildMemberCta(context),
            const Gap(32),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Penawaran Terbatas',
              style: AppTextStyles.plusJakartaSans(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Gap(12),
          Text(
            'Promo Spesial\nMitologi Clothing',
            style: AppTextStyles.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 28,
              height: 1.2,
            ),
          ),
          const Gap(8),
          Text(
            'Dapatkan penawaran terbaik dan nikmati berbagai keuntungan eksklusif.',
            style: AppTextStyles.plusJakartaSans(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard(Map<String, dynamic> promo) {
    final color = Color(promo['color'] as int);
    final bg = Color(promo['bg'] as int);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [AppShadows.cardSoft],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Icon(promo['icon'] as IconData, color: color, size: 22),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          promo['badge'] as String,
                          style: AppTextStyles.plusJakartaSans(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Gap(4),
                      Text(
                        promo['title'] as String,
                        style: AppTextStyles.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promo['subtitle'] as String,
                  style: AppTextStyles.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.onBackground,
                  ),
                ),
                const Gap(6),
                Text(
                  promo['desc'] as String,
                  style: AppTextStyles.plusJakartaSans(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const Gap(10),
                Row(
                  children: [
                    const Icon(PhosphorIconsRegular.info,
                        size: 14, color: AppColors.onSurfaceVariant),
                    const Gap(4),
                    Expanded(
                      child: Text(
                        promo['terms'] as String,
                        style: AppTextStyles.plusJakartaSans(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.9,
      children: _benefits.map((b) {
        final color = Color(b['color'] as int);
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(b['icon'] as IconData, color: color, size: 20),
              ),
              const Gap(8),
              Text(
                b['title'] as String,
                style: AppTextStyles.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: AppColors.onBackground,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMemberCta(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(PhosphorIconsFill.crown, color: Colors.white, size: 36),
          const Gap(12),
          Text(
            'Jadi Member Eksklusif',
            style: AppTextStyles.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(8),
          Text(
            'Daftar dan nikmati akses ke promo eksklusif, diskon member, dan penawaran spesial lainnya.',
            style: AppTextStyles.plusJakartaSans(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => context.push('/register'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF7C3AED),
                padding: const EdgeInsets.all(14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Daftar Sekarang',
                style: AppTextStyles.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF7C3AED),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
