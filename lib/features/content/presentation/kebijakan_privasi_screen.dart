import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';
import 'package:mitologi_clothing_mobile/core/widgets/glass_container.dart';
import 'package:mitologi_clothing_mobile/core/widgets/premium_section_header.dart';
import 'package:mitologi_clothing_mobile/widgets/shared/mitologi_sliver_app_bar.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class KebijakanPrivasiScreen extends StatefulWidget {
  const KebijakanPrivasiScreen({super.key});

  @override
  State<KebijakanPrivasiScreen> createState() => _KebijakanPrivasiScreenState();
}

class _KebijakanPrivasiScreenState extends State<KebijakanPrivasiScreen> {
  final ScrollController _scrollController = ScrollController();
  String _activeSection = 'pendahuluan';

  // Section keys to measure scroll positions and highlight active section
  final Map<String, GlobalKey> _keys = {
    'pendahuluan': GlobalKey(),
    'informasi': GlobalKey(),
    'penggunaan': GlobalKey(),
    'perlindungan': GlobalKey(),
    'pihak-ketiga': GlobalKey(),
    'hak-pengguna': GlobalKey(),
    'cookie': GlobalKey(),
    'perubahan': GlobalKey(),
    'kontak': GlobalKey(),
  };

  final List<Map<String, String>> _sections = [
    {'id': 'pendahuluan', 'label': 'Pendahuluan'},
    {'id': 'informasi', 'label': 'Informasi'},
    {'id': 'penggunaan', 'label': 'Penggunaan'},
    {'id': 'perlindungan', 'label': 'Perlindungan'},
    {'id': 'pihak-ketiga', 'label': 'Pihak Ketiga'},
    {'id': 'hak-pengguna', 'label': 'Hak Pengguna'},
    {'id': 'cookie', 'label': 'Cookie'},
    {'id': 'perubahan', 'label': 'Perubahan'},
    {'id': 'kontak', 'label': 'Kontak'},
  ];

  void _scrollToSection(String id) {
    final key = _keys[id];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() {
        _activeSection = id;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              const MitologiSliverAppBar(
                pageTitle: 'Privasi',
                showBackButton: true,
                pinned: true,
              ),
              const SliverToBoxAdapter(
                child: PremiumSectionHeader(
                  eyebrow: 'Privacy Policy',
                  title: 'Kebijakan\nPrivasi',
                  subtitle:
                      'Komitmen kami dalam melindungi privasi dan data pribadi Anda saat menggunakan layanan Mitologi.',
                ),
              ),
              
              // Horizontal Table of Contents Tab
              SliverToBoxAdapter(
                child: Container(
                  height: 52,
                  margin: const EdgeInsets.only(bottom: 24),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _sections.length,
                    itemBuilder: (context, index) {
                      final sec = _sections[index];
                      final isActive = _activeSection == sec['id'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          showCheckmark: false,
                          label: Text(
                            sec['label']!,
                            style: AppTextStyles.manrope(
                              fontSize: 12,
                              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                              color: isActive ? Colors.white : AppColors.primary,
                            ),
                          ),
                          selected: isActive,
                          selectedColor: AppColors.primary,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isActive ? Colors.transparent : AppColors.outlineVariant.withValues(alpha: 0.5),
                            ),
                          ),
                          onSelected: (_) => _scrollToSection(sec['id']!),
                        ),
                      );
                    },
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Terakhir diperbarui: Februari 2026',
                        style: AppTextStyles.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const Gap(24),
                      
                      // 1. Pendahuluan
                      _buildSectionContainer(
                        id: 'pendahuluan',
                        title: '1. Pendahuluan',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBodyText(
                              'Mitologi Clothing ("kami", "milik kami", atau "Mitologi") berkomitmen untuk melindungi privasi dan data pribadi Anda. Kebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, menyimpan, dan melindungi informasi pribadi Anda saat Anda menggunakan website kami, melakukan pembelian, atau berinteraksi dengan layanan kami.',
                            ),
                            const Gap(12),
                            _buildBodyText(
                              'Dengan mengakses dan menggunakan layanan kami, Anda menyetujui pengumpulan dan penggunaan informasi sesuai dengan kebijakan ini. Jika Anda tidak setuju dengan ketentuan ini, mohon untuk tidak menggunakan layanan kami.',
                            ),
                          ],
                        ),
                      ),

                      // 2. Informasi yang Dikumpulkan
                      _buildSectionContainer(
                        id: 'informasi',
                        title: '2. Informasi yang Kami Kumpulkan',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSubTitleText('a. Data Pribadi'),
                            _buildBodyText('Informasi yang Anda berikan secara langsung kepada kami, termasuk:'),
                            _buildBulletList([
                              'Nama lengkap dan alamat email saat mendaftar akun',
                              'Nomor telepon untuk keperluan komunikasi pesanan',
                              'Alamat pengiriman untuk proses pengiriman produk',
                              'Informasi pembayaran yang diproses melalui payment gateway',
                            ]),
                            const Gap(16),
                            _buildSubTitleText('b. Data Transaksi'),
                            _buildBodyText('Informasi terkait aktivitas belanja Anda, meliputi:'),
                            _buildBulletList([
                              'Riwayat pembelian dan detail pesanan',
                              'Produk yang ditambahkan ke keranjang belanja',
                              'Preferensi produk dan wishlist',
                              'Interaksi dengan fitur rekomendasi produk',
                            ]),
                            const Gap(16),
                            _buildSubTitleText('c. Data Perangkat & Teknis'),
                            _buildBodyText('Informasi yang dikumpulkan secara otomatis saat Anda mengunjungi website kami:'),
                            _buildBulletList([
                              'Alamat IP dan informasi browser',
                              'Jenis perangkat dan sistem operasi',
                              'Halaman yang dikunjungi dan durasi kunjungan',
                              'Sumber referral dan interaksi dengan website',
                            ]),
                          ],
                        ),
                      ),

                      // 3. Penggunaan Informasi
                      _buildSectionContainer(
                        id: 'penggunaan',
                        title: '3. Penggunaan Informasi',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBodyText('Kami menggunakan informasi yang dikumpulkan untuk tujuan berikut:'),
                            _buildBulletList([
                              'Pemrosesan Pesanan: Memproses, mengirimkan, dan mengelola pesanan Anda.',
                              'Komunikasi: Mengirimkan konfirmasi pesanan, update pengiriman, dan notifikasi penting.',
                              'Personalisasi: Memberikan rekomendasi produk yang relevan berdasarkan preferensi Anda.',
                              'Peningkatan Layanan: Menganalisis pola penggunaan website untuk meningkatkan pengalaman berbelanja.',
                              'Keamanan: Mendeteksi dan mencegah aktivitas penipuan atau penyalahgunaan.',
                              'Pemasaran: Mengirimkan newsletter, penawaran khusus, dan informasi promo (dengan persetujuan Anda).',
                            ]),
                          ],
                        ),
                      ),

                      // 4. Perlindungan Data
                      _buildSectionContainer(
                        id: 'perlindungan',
                        title: '4. Perlindungan Data',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBodyText(
                              'Kami menerapkan langkah-langkah keamanan teknis dan organisasi yang sesuai untuk melindungi data pribadi Anda, termasuk:',
                            ),
                            _buildBulletList([
                              'Enkripsi data saat transmisi menggunakan SSL/TLS',
                              'Penyimpanan password menggunakan algoritma hashing yang aman',
                              'Pembatasan akses data hanya kepada karyawan yang membutuhkan',
                              'Pemrosesan pembayaran melalui gateway yang tersertifikasi PCI DSS (Midtrans)',
                              'Pemantauan keamanan sistem secara berkala',
                            ]),
                            const Gap(12),
                            _buildBodyText(
                              'Meskipun kami berusaha melindungi data Anda, tidak ada metode transmisi data melalui internet yang 100% aman. Kami tidak dapat menjamin keamanan absolut data yang ditransmisikan ke website kami.',
                            ),
                          ],
                        ),
                      ),

                      // 5. Pihak Ketiga
                      _buildSectionContainer(
                        id: 'pihak-ketiga',
                        title: '5. Berbagi Informasi dengan Pihak Ketiga',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBodyText(
                              'Kami tidak menjual, memperdagangkan, atau menyewakan data pribadi Anda kepada pihak ketiga. Kami hanya membagikan informasi dalam situasi berikut:',
                            ),
                            _buildBulletList([
                              'Payment Gateway: Data pembayaran diproses oleh Midtrans untuk memfasilitasi transaksi.',
                              'Jasa Pengiriman: Nama dan alamat pengiriman diberikan kepada kurir (JNE, J&T, SiCepat, dll.) untuk mengirimkan pesanan Anda.',
                              'Kewajiban Hukum: Jika diwajibkan oleh hukum, regulasi, atau perintah pengadilan yang berlaku di Indonesia.',
                              'Perlindungan Hak: Untuk melindungi hak, keamanan, atau properti kami, pengguna kami, atau publik.',
                            ]),
                          ],
                        ),
                      ),

                      // 6. Hak Pengguna
                      _buildSectionContainer(
                        id: 'hak-pengguna',
                        title: '6. Hak Pengguna',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBodyText('Anda memiliki hak-hak berikut terkait data pribadi Anda:'),
                            _buildBulletList([
                              'Hak Akses: Anda dapat mengakses dan meninjau data pribadi yang kami simpan tentang Anda melalui halaman akun Anda.',
                              'Hak Koreksi: Anda dapat memperbarui atau memperbaiki data yang tidak akurat melalui pengaturan profil.',
                              'Hak Penghapusan: Anda dapat meminta penghapusan akun dan data pribadi Anda dengan menghubungi kami.',
                              'Hak Penarikan Persetujuan: Anda dapat berhenti berlangganan newsletter kapan saja melalui link unsubscribe.',
                            ]),
                            const Gap(12),
                            _buildBodyText(
                              'Untuk menggunakan hak-hak Anda, silakan hubungi kami melalui email di mitologiclothing@gmail.com.',
                            ),
                          ],
                        ),
                      ),

                      // 7. Cookie
                      _buildSectionContainer(
                        id: 'cookie',
                        title: '7. Kebijakan Cookie',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBodyText(
                              'Website kami menggunakan cookie dan teknologi penyimpanan lokal untuk meningkatkan pengalaman Anda. Cookie yang kami gunakan meliputi:',
                            ),
                            _buildBulletList([
                              'Cookie Esensial: Diperlukan untuk fungsi dasar website seperti autentikasi dan keranjang belanja.',
                              'Cookie Preferensi: Menyimpan preferensi sesi Anda untuk pengalaman yang lebih personal.',
                              'Cookie Analitik: Membantu kami memahami bagaimana pengunjung berinteraksi dengan website.',
                            ]),
                            const Gap(12),
                            _buildBodyText(
                              'Anda dapat mengelola pengaturan cookie melalui pengaturan browser Anda. Perlu diketahui bahwa menonaktifkan cookie tertentu dapat memengaruhi fungsionalitas website.',
                            ),
                          ],
                        ),
                      ),

                      // 8. Perubahan
                      _buildSectionContainer(
                        id: 'perubahan',
                        title: '8. Perubahan Kebijakan',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBodyText(
                              'Kami berhak untuk memperbarui Kebijakan Privasi ini dari waktu ke waktu. Perubahan signifikan akan diumumkan melalui website kami dan/atau melalui email. Kami menyarankan Anda untuk meninjau kebijakan ini secara berkala.',
                            ),
                            const Gap(12),
                            _buildBodyText(
                              'Penggunaan berkelanjutan atas layanan kami setelah perubahan diposting berarti Anda menerima kebijakan yang telah diperbarui.',
                            ),
                          ],
                        ),
                      ),

                      // 9. Kontak
                      _buildSectionContainer(
                        id: 'kontak',
                        title: '9. Hubungi Kami',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBodyText(
                              'Jika Anda memiliki pertanyaan, keluhan, atau permintaan terkait Kebijakan Privasi ini atau pengelolaan data pribadi Anda, silakan hubungi kami:',
                            ),
                            const Gap(16),
                            GlassContainer(
                              padding: const EdgeInsets.all(20),
                              borderRadius: BorderRadius.circular(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mitologi Clothing',
                                    style: AppTextStyles.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const Gap(12),
                                  _buildContactRow(PhosphorIconsRegular.envelope, 'mitologiclothing@gmail.com'),
                                  _buildContactRow(PhosphorIconsRegular.phone, '+62 813-2217-0902'),
                                  _buildContactRow(PhosphorIconsRegular.mapPin, 'Desa Leuwigede Kec. Widasari, Kab. Indramayu 45271'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Gap(24),
                      _buildRelatedLinks(context),
                      const Gap(100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({
    required String id,
    required String title,
    required Widget child,
  }) {
    return Container(
      key: _keys[id],
      margin: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.notoSerif(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const Gap(16),
          child,
        ],
      ),
    );
  }

  Widget _buildBodyText(String text) {
    return Text(
      text,
      style: AppTextStyles.manrope(
        fontSize: 13.5,
        color: AppColors.onSurfaceVariant,
        height: 1.6,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildSubTitleText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        text,
        style: AppTextStyles.plusJakartaSans(
          fontSize: 14.5,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, left: 4.0),
      child: Column(
        children: items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 7),
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
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.secondary),
          const Gap(12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.manrope(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
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
          onTap: () => context.push('/syarat-ketentuan'),
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
          onTap: () => context.push('/kebijakan-pengembalian'),
          child: Text(
            'Kebijakan Pengembalian →',
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
