import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';
import 'package:mitologi_clothing_mobile/core/widgets/glass_container.dart';
import 'package:mitologi_clothing_mobile/core/widgets/luxury_button.dart';
import 'package:mitologi_clothing_mobile/core/widgets/premium_section_header.dart';
import 'package:mitologi_clothing_mobile/widgets/shared/mitologi_sliver_app_bar.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

const _steps = [
  {
    'icon': PhosphorIconsRegular.chatCircleDots,
    'title': 'Hubungi CS',
    'description':
        'Hubungi customer service kami melalui WhatsApp atau email untuk mengajukan pengembalian.',
  },
  {
    'icon': PhosphorIconsRegular.truck,
    'title': 'Kirim Barang',
    'description':
        'Kemas barang dengan rapi dan kirimkan ke alamat workshop kami menggunakan jasa pengiriman.',
  },
  {
    'icon': PhosphorIconsRegular.sealCheck,
    'title': 'Verifikasi',
    'description':
        'Tim kami akan memeriksa kondisi barang dalam 1-3 hari kerja setelah barang diterima.',
  },
  {
    'icon': PhosphorIconsRegular.currencyCircleDollar,
    'title': 'Refund / Tukar',
    'description':
        'Dana akan dikembalikan atau produk pengganti dikirimkan dalam 5-14 hari kerja.',
  },
];

const _faqs = [
  {
    'q': 'Berapa lama batas waktu pengajuan pengembalian?',
    'a':
        'Anda memiliki waktu 7 hari kalender setelah barang diterima untuk mengajukan pengembalian. Pengajuan yang melewati batas waktu tersebut tidak dapat diproses.',
  },
  {
    'q': 'Apakah biaya pengiriman pengembalian ditanggung Mitologi?',
    'a':
        'Jika pengembalian disebabkan oleh kesalahan kami (barang cacat, salah produk, salah ukuran dari sisi produksi), biaya pengiriman kami tanggung. Untuk alasan lain, biaya menjadi tanggung jawab pembeli.',
  },
  {
    'q': 'Bagaimana proses refund dilakukan?',
    'a':
        'Refund akan dilakukan melalui Transfer Bank ke rekening yang Anda informasikan. Proses memakan waktu 5-14 hari kerja setelah verifikasi selesai.',
  },
  {
    'q': 'Apakah bisa tukar produk saja tanpa refund?',
    'a':
        'Ya, kami menyediakan opsi penukaran produk (misalnya tukar ukuran atau warna). Penukaran akan diproses setelah barang asli diterima dan diverifikasi oleh tim kami.',
  },
];

class KebijakanPengembalianScreen extends StatelessWidget {
  const KebijakanPengembalianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const MitologiSliverAppBar(
            pageTitle: 'Pengembalian',
            showBackButton: true,
            pinned: true,
          ),
          const SliverToBoxAdapter(
            child: PremiumSectionHeader(
              eyebrow: 'Return Policy',
              title: 'Kebijakan\nPengembalian',
              subtitle:
                  'Kami ingin Anda puas dengan setiap pembelian. Jika tidak sesuai, kami siap membantu.',
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(8),
                  _buildStepsSection(),
                  const Gap(40),
                  _buildSyaratSection(),
                  const Gap(40),
                  _buildProsedurSection(),
                  const Gap(40),
                  _buildRefundSection(),
                  const Gap(40),
                  _buildFaqSection(),
                  const Gap(40),
                  _buildCtaSection(context),
                  const Gap(32),
                  _buildRelatedLinks(context),
                  const Gap(100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(PhosphorIconsRegular.arrowsClockwise, size: 22, color: AppColors.primary),
            const Gap(10),
            Text(
              'Langkah Pengembalian',
              style: AppTextStyles.notoSerif(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const Gap(6),
        Text(
          'Proses pengembalian barang di Mitologi Clothing mudah dan transparan.',
          style: AppTextStyles.manrope(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Gap(20),
        ...List.generate(_steps.length, (i) {
          final step = _steps[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: BorderRadius.circular(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.secondarySoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Icon(step['icon'] as IconData, size: 22, color: AppColors.primary),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '0${i + 1}',
                              style: AppTextStyles.manrope(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: AppColors.secondary,
                              ),
                            ),
                            const Gap(8),
                            Text(
                              step['title'] as String,
                              style: AppTextStyles.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const Gap(6),
                        Text(
                          step['description'] as String,
                          style: AppTextStyles.manrope(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                            height: 1.6,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSyaratSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Syarat Pengembalian',
          style: AppTextStyles.notoSerif(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const Gap(20),
        _buildSubSection(
          'Produk yang Dapat Dikembalikan',
          [
            'Produk yang diterima dalam kondisi cacat/rusak dari pabrik',
            'Produk yang tidak sesuai dengan pesanan (salah warna, salah model, salah ukuran karena kesalahan produksi)',
            'Produk yang berbeda dari deskripsi di website secara signifikan',
            'Produk yang masih dalam kondisi baru, belum dicuci, belum dipakai, dan tag masih melekat',
          ],
        ),
        const Gap(24),
        _buildSubSection(
          'Produk yang Tidak Dapat Dikembalikan',
          [
            'Produk yang sudah dicuci, dipakai, atau dimodifikasi dengan cara apapun',
            'Produk dengan tag yang sudah dilepas atau rusak',
            'Produk yang dikembalikan setelah melewati batas waktu 7 hari',
            'Produk custom atau pesanan khusus yang dibuat sesuai permintaan spesifik',
            'Produk yang rusak akibat kelalaian pembeli (bukan dari pabrik)',
            'Produk sale/clearance dengan keterangan "tanpa pengembalian"',
          ],
        ),
        const Gap(24),
        GlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: BorderRadius.circular(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.secondarySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(PhosphorIconsRegular.arrowsClockwise, size: 22, color: AppColors.primary),
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '7 Hari Kalender',
                      style: AppTextStyles.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      'Pengajuan pengembalian harus dilakukan dalam waktu 7 hari kalender setelah barang diterima. Tanggal penerimaan dihitung berdasarkan konfirmasi penerimaan dari jasa pengiriman.',
                      style: AppTextStyles.manrope(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const Gap(12),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTextStyles.manrope(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildProsedurSection() {
    final procedures = [
      'Hubungi customer service kami melalui WhatsApp (+62 813-2217-0902) atau email (mitologiclothing@gmail.com) dengan menyertakan: Nomor pesanan, Foto produk, dan Alasan pengembalian.',
      'Tunggu konfirmasi dari tim kami (maksimal 1×24 jam pada hari kerja).',
      'Kemas produk dengan rapi menggunakan kemasan yang aman untuk pengiriman.',
      'Kirimkan produk ke alamat yang diberikan oleh tim kami beserta salinan nomor pesanan.',
      'Konfirmasi pengiriman dengan mengirimkan nomor resi kepada tim kami.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prosedur Pengembalian',
          style: AppTextStyles.notoSerif(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const Gap(16),
        ...List.generate(procedures.length, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: AppTextStyles.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const Gap(14),
                  Expanded(
                    child: Text(
                      procedures[i],
                      style: AppTextStyles.manrope(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildRefundSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Proses Pengembalian Dana',
          style: AppTextStyles.notoSerif(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const Gap(16),
        _buildSubSection('', [
          'Refund diproses setelah barang diterima dan lolos verifikasi oleh tim kami (1-3 hari kerja)',
          'Dana akan dikembalikan melalui Transfer Bank ke rekening yang Anda informasikan',
          'Proses transfer refund memakan waktu 5-14 hari kerja setelah verifikasi selesai',
          'Jumlah refund mencakup harga produk. Biaya pengiriman awal tidak dikembalikan kecuali pengembalian disebabkan oleh kesalahan kami',
        ]),
        const Gap(20),
        Text(
          'Penukaran Produk',
          style: AppTextStyles.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const Gap(10),
        Text(
          'Jika Anda memilih untuk menukar produk (misalnya tukar ukuran atau warna), proses pengiriman produk pengganti akan dilakukan setelah barang asli diterima dan diverifikasi. Biaya pengiriman produk pengganti ditanggung oleh Mitologi Clothing jika penukaran disebabkan oleh kesalahan kami.',
          style: AppTextStyles.manrope(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
            height: 1.6,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFaqSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(PhosphorIconsRegular.chatCircleDots, size: 22, color: AppColors.primary),
            const Gap(10),
            Text(
              'Pertanyaan Umum',
              style: AppTextStyles.notoSerif(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const Gap(6),
        Text(
          'Jawaban atas pertanyaan yang sering diajukan terkait pengembalian.',
          style: AppTextStyles.manrope(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Gap(20),
        ..._faqs.map((faq) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GlassContainer(
                padding: const EdgeInsets.all(20),
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      faq['q']!,
                      style: AppTextStyles.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      faq['a']!,
                      style: AppTextStyles.manrope(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildCtaSection(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(28),
      borderRadius: BorderRadius.circular(28),
      color: AppColors.primary,
      child: Column(
        children: [
          Text(
            'Butuh Bantuan dengan Pengembalian?',
            style: AppTextStyles.notoSerif(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(10),
          Text(
            'Tim customer service kami siap membantu Anda. Hubungi kami untuk proses pengembalian yang cepat dan mudah.',
            style: AppTextStyles.manrope(
              fontSize: 13,
              color: Colors.white70,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(24),
          LuxuryButton(
            onPressed: () async {
              final uri = Uri.parse(
                  'https://wa.me/6281322170902?text=Halo%2C%20saya%20ingin%20mengajukan%20pengembalian%20produk');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            label: 'Chat WhatsApp',
            icon: PhosphorIconsRegular.whatsappLogo,
            variant: LuxuryButtonVariant.secondary,
            expand: true,
          ),
          const Gap(12),
          LuxuryButton(
            onPressed: () => context.push('/kontak'),
            label: 'Hubungi Kami',
            icon: PhosphorIconsRegular.phone,
            variant: LuxuryButtonVariant.ghost,
            expand: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedLinks(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => context.push('/pages/terms-conditions'),
          child: Text(
            '← Syarat & Ketentuan',
            style: AppTextStyles.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => context.push('/pages/privacy-policy'),
          child: Text(
            'Kebijakan Privasi →',
            style: AppTextStyles.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
