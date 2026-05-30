import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';
import 'package:mitologi_clothing_mobile/core/widgets/premium_section_header.dart';
import 'package:mitologi_clothing_mobile/widgets/shared/mitologi_sliver_app_bar.dart';

class SyaratKetentuanScreen extends StatefulWidget {
  const SyaratKetentuanScreen({super.key});

  @override
  State<SyaratKetentuanScreen> createState() => _SyaratKetentuanScreenState();
}

class _SyaratKetentuanScreenState extends State<SyaratKetentuanScreen> {
  final ScrollController _scrollController = ScrollController();
  String _activeSection = 'definisi';

  // Section keys to measure scroll positions and highlight active section
  final Map<String, GlobalKey> _keys = {
    'definisi': GlobalKey(),
    'umum': GlobalKey(),
    'akun': GlobalKey(),
    'produk': GlobalKey(),
    'pemesanan': GlobalKey(),
    'pengiriman': GlobalKey(),
    'pembatalan': GlobalKey(),
    'hki': GlobalKey(),
    'batasan': GlobalKey(),
    'sengketa': GlobalKey(),
    'hukum': GlobalKey(),
    'perubahan': GlobalKey(),
  };

  final List<Map<String, String>> _sections = [
    {'id': 'definisi', 'label': 'Definisi'},
    {'id': 'umum', 'label': 'Umum'},
    {'id': 'akun', 'label': 'Akun'},
    {'id': 'produk', 'label': 'Produk & Harga'},
    {'id': 'pemesanan', 'label': 'Pemesanan'},
    {'id': 'pengiriman', 'label': 'Pengiriman'},
    {'id': 'pembatalan', 'label': 'Pembatalan'},
    {'id': 'hki', 'label': 'HKI'},
    {'id': 'batasan', 'label': 'Batasan'},
    {'id': 'sengketa', 'label': 'Sengketa'},
    {'id': 'hukum', 'label': 'Hukum'},
    {'id': 'perubahan', 'label': 'Perubahan'},
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
                pageTitle: 'Syarat & Ketentuan',
                showBackButton: true,
                pinned: true,
              ),
              const SliverToBoxAdapter(
                child: PremiumSectionHeader(
                  eyebrow: 'Terms & Conditions',
                  title: 'Syarat &\nKetentuan',
                  subtitle:
                      'Ketentuan penggunaan layanan Mitologi Clothing. Mohon baca dengan saksama sebelum menggunakan layanan kami.',
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
                      
                      // 1. Definisi & Istilah
                      _buildSectionContainer(
                        id: 'definisi',
                        title: '1. Definisi & Istilah',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBodyText('Dalam Syarat & Ketentuan ini, yang dimaksud dengan:'),
                            _buildBulletList([
                              '"Mitologi" atau "Kami": Merujuk pada Mitologi Clothing, termasuk website, layanan, dan seluruh operasional yang terkait.',
                              '"Pengguna" atau "Anda": Setiap individu yang mengakses, mendaftar, atau menggunakan layanan Mitologi Clothing.',
                              '"Website": Situs web resmi Mitologi Clothing yang dapat diakses melalui domain utama kami.',
                              '"Produk": Seluruh barang dagangan yang ditawarkan melalui website, termasuk kaos, kemeja, jaket, dan merchandise lainnya.',
                              '"Pesanan": Pembelian yang dilakukan oleh Pengguna melalui website kami.',
                              '"Layanan": Seluruh fitur dan fungsi yang disediakan melalui website, termasuk namun tidak terbatas pada jual beli produk, pembuatan akun, dan layanan pelanggan.',
                            ]),
                          ],
                        ),
                      ),

                      // 2. Persyaratan Umum
                      _buildSectionContainer(
                        id: 'umum',
                        title: '2. Persyaratan Umum Penggunaan',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBodyText('Dengan menggunakan layanan kami, Anda menyatakan dan menjamin bahwa:'),
                            _buildBulletList([
                              'Anda berusia minimal 17 tahun atau memiliki izin dari orang tua/wali yang sah.',
                              'Anda memberikan informasi yang benar, akurat, dan lengkap saat mendaftar dan melakukan transaksi.',
                              'Anda bertanggung jawab atas keamanan akun dan password Anda.',
                              'Anda tidak akan menggunakan layanan kami untuk tujuan ilegal atau yang melanggar ketentuan ini.',
                              'Anda tidak akan berusaha mengakses sistem kami secara tidak sah atau mengganggu operasional website.',
                            ]),
                          ],
                        ),
                      ),

                      // 3. Akun Pengguna
                      _buildSectionContainer(
                        id: 'akun',
                        title: '3. Akun Pengguna',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBodyText('Untuk menikmati layanan penuh, Anda dapat membuat akun di website kami. Ketentuan terkait akun meliputi:'),
                            _buildBulletList([
                              'Setiap pengguna hanya diperbolehkan memiliki satu akun.',
                              'Anda bertanggung jawab penuh atas semua aktivitas yang dilakukan melalui akun Anda.',
                              'Segera hubungi kami jika Anda menduga ada penggunaan tidak sah atas akun Anda.',
                              'Kami berhak menangguhkan atau menutup akun yang melanggar ketentuan ini.',
                              'Anda dapat menghapus akun Anda kapan saja melalui pengaturan akun atau dengan menghubungi layanan pelanggan kami.',
                            ]),
                          ],
                        ),
                      ),

                      // 4. Produk & Harga
                      _buildSectionContainer(
                        id: 'produk',
                        title: '4. Produk & Harga',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBulletList([
                              'Kami berusaha menyajikan informasi produk (deskripsi, gambar, ukuran) seakurat mungkin. Namun, perbedaan warna minor dapat terjadi akibat pengaturan layar perangkat Anda.',
                              'Semua harga yang ditampilkan dalam mata uang Rupiah (IDR) dan sudah termasuk PPN jika berlaku.',
                              'Harga dapat berubah sewaktu-waktu tanpa pemberitahuan sebelumnya, namun perubahan tidak berlaku untuk pesanan yang sudah dikonfirmasi.',
                              'Ketersediaan produk tergantung pada stok yang tersedia. Kami berhak membatalkan pesanan jika stok habis setelah pemesanan dilakukan.',
                              'Produk promo atau diskon memiliki ketentuan khusus yang berlaku selama periode promo.',
                            ]),
                          ],
                        ),
                      ),

                      // 5. Pemesanan & Pembayaran
                      _buildSectionContainer(
                        id: 'pemesanan',
                        title: '5. Proses Pemesanan & Pembayaran',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBulletList([
                              'Pesanan dianggap sah setelah pembayaran berhasil dikonfirmasi oleh sistem kami.',
                              'Batas waktu pembayaran untuk metode Transfer Bank dan Virtual Account adalah 24 jam. Pembayaran yang melewati batas waktu akan dibatalkan secara otomatis.',
                              'Semua transaksi pembayaran diproses melalui Midtrans, payment gateway yang tersertifikasi keamanan PCI DSS.',
                              'Kami tidak menyimpan informasi kartu kredit/debit Anda di server kami.',
                              'Bukti pembayaran resmi berupa email konfirmasi yang dikirimkan setelah pembayaran diverifikasi.',
                              'Kami berhak menolak pesanan jika terdapat indikasi penipuan atau aktivitas mencurigakan.',
                            ]),
                          ],
                        ),
                      ),

                      // 6. Pengiriman
                      _buildSectionContainer(
                        id: 'pengiriman',
                        title: '6. Pengiriman',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBulletList([
                              'Pesanan akan diproses dalam 1-2 hari kerja setelah pembayaran dikonfirmasi.',
                              'Estimasi pengiriman: 2-5 hari kerja (Jawa) dan 5-10 hari kerja (luar Jawa), tergantung jasa pengiriman.',
                              'Nomor resi akan dikirimkan melalui email atau WhatsApp setelah paket dikirimkan.',
                              'Pastikan alamat pengiriman yang diberikan sudah benar dan lengkap. Kesalahan alamat yang mengakibatkan pengiriman gagal menjadi tanggung jawab pembeli.',
                              'Risiko kerusakan atau kehilangan selama pengiriman menjadi tanggung jawab jasa pengiriman. Kami akan membantu klaim jika disertai bukti yang memadai.',
                              'Gratis ongkir berlaku untuk pembelian minimum Rp 200.000 (syarat dan ketentuan berlaku).',
                            ]),
                          ],
                        ),
                      ),

                      // 7. Pembatalan & Pengembalian
                      _buildSectionContainer(
                        id: 'pembatalan',
                        title: '7. Pembatalan & Pengembalian',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBodyText(
                              'Untuk kebijakan lengkap mengenai pengembalian dan refund, silakan kunjungi halaman Kebijakan Pengembalian kami.',
                            ),
                            _buildBulletList([
                              'Pembatalan pesanan hanya dapat dilakukan sebelum pesanan diproses/dikemas.',
                              'Pengembalian produk dapat dilakukan dalam waktu 7 hari setelah barang diterima.',
                              'Produk yang dikembalikan harus dalam kondisi original (belum dicuci, belum dipakai, tag masih terpasang).',
                              'Proses refund memakan waktu 5-14 hari kerja setelah barang diterima dan diverifikasi oleh tim kami.',
                            ]),
                          ],
                        ),
                      ),

                      // 8. HKI
                      _buildSectionContainer(
                        id: 'hki',
                        title: '8. Hak Kekayaan Intelektual',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBodyText(
                              'Seluruh konten yang ditampilkan di website ini, termasuk namun tidak terbatas pada logo, desain, teks, grafis, gambar, foto produk, dan kode program, merupakan hak kekayaan intelektual Mitologi Clothing dan dilindungi oleh undang-undang hak cipta yang berlaku di Republik Indonesia.',
                            ),
                            const Gap(12),
                            _buildBodyText('Pengguna dilarang untuk:'),
                            _buildBulletList([
                              'Menyalin, memodifikasi, atau memproduksi ulang konten tanpa izin tertulis.',
                              'Menggunakan merek, logo, atau desain Mitologi untuk kepentingan komersial.',
                              'Menggunakan konten website untuk membuat produk atau layanan yang bersaing.',
                            ]),
                          ],
                        ),
                      ),

                      // 9. Batasan Tanggung Jawab
                      _buildSectionContainer(
                        id: 'batasan',
                        title: '9. Batasan Tanggung Jawab',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBulletList([
                              'Layanan kami disediakan "sebagaimana adanya" tanpa jaminan dari segala jenis, baik tersurat maupun tersirat.',
                              'Kami tidak bertanggung jawab atas kerugian tidak langsung, insidental, atau konsekuensial yang timbul dari penggunaan layanan kami.',
                              'Kami tidak menjamin bahwa website akan selalu tersedia tanpa gangguan atau bebas dari kesalahan.',
                              'Total tanggung jawab kami terbatas pada jumlah yang Anda bayarkan untuk produk terkait.',
                            ]),
                          ],
                        ),
                      ),

                      // 10. Penyelesaian Sengketa
                      _buildSectionContainer(
                        id: 'sengketa',
                        title: '10. Penyelesaian Sengketa',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBodyText('Setiap sengketa yang timbul dari penggunaan layanan kami akan diselesaikan dengan cara berikut:'),
                            _buildBulletList([
                              'Musyawarah: Para pihak akan berusaha menyelesaikan sengketa secara musyawarah dalam waktu 30 hari kalender.',
                              'Mediasi: Jika musyawarah gagal, sengketa akan diselesaikan melalui mediasi di bawah lembaga mediasi yang disepakati bersama.',
                              'Arbitrase/Pengadilan: Sebagai upaya terakhir, sengketa akan diselesaikan melalui Pengadilan Negeri yang berwenang di wilayah Indramayu, Jawa Barat.',
                            ]),
                          ],
                        ),
                      ),

                      // 11. Hukum
                      _buildSectionContainer(
                        id: 'hukum',
                        title: '11. Hukum yang Berlaku',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBodyText(
                              'Syarat & Ketentuan ini diatur dan ditafsirkan berdasarkan hukum Republik Indonesia. Dengan menggunakan layanan kami, Anda tunduk pada yurisdiksi pengadilan Republik Indonesia.',
                            ),
                          ],
                        ),
                      ),

                      // 12. Perubahan
                      _buildSectionContainer(
                        id: 'perubahan',
                        title: '12. Perubahan Syarat & Ketentuan',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBodyText(
                              'Kami berhak mengubah Syarat & Ketentuan ini kapan saja. Perubahan signifikan akan diumumkan melalui website dan akan berlaku efektif sejak tanggal publikasi. Penggunaan berkelanjutan atas layanan kami setelah perubahan diposting berarti Anda menerima syarat yang telah diperbarui.',
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



  Widget _buildRelatedLinks(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => context.push('/kebijakan-privasi'),
          child: Text(
            '← Kebijakan Privasi',
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
