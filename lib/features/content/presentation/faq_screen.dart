import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

const _faqCategories = [
  {'key': 'umum', 'label': 'Umum'},
  {'key': 'pemesanan', 'label': 'Pemesanan'},
  {'key': 'pengiriman', 'label': 'Pengiriman'},
  {'key': 'pengembalian', 'label': 'Pengembalian'},
  {'key': 'pembayaran', 'label': 'Pembayaran'},
  {'key': 'akun', 'label': 'Akun'},
];

const _faqData = {
  'umum': [
    {
      'q': 'Apa itu Mitologi Clothing?',
      'a':
          'Mitologi Clothing adalah brand pakaian premium yang memproduksi berbagai jenis pakaian seperti kaos, kemeja, jaket, dan merchandise dengan sentuhan budaya Indonesia dan kualitas terbaik. Kami berlokasi di Indramayu, Jawa Barat.'
    },
    {
      'q': 'Apakah produk Mitologi Clothing dibuat secara handmade?',
      'a':
          'Sebagian besar produk kami diproduksi dengan kombinasi teknik modern dan sentuhan tangan terampil. Setiap produk melewati quality control yang ketat untuk memastikan kualitas terbaik.'
    },
    {
      'q': 'Apakah Mitologi Clothing menerima pesanan custom/partai besar?',
      'a':
          'Ya, kami menerima pesanan custom untuk kebutuhan instansi, seragam, komunitas, atau event. Silakan hubungi kami melalui WhatsApp untuk diskusi lebih lanjut.'
    },
    {
      'q': 'Apakah ukuran produk sesuai dengan standar lokal?',
      'a':
          'Produk kami menggunakan standar ukuran lokal (Reguler Fit). Kami sangat menyarankan Anda melihat Panduan Ukuran sebelum membeli.'
    },
  ],
  'pemesanan': [
    {
      'q': 'Bagaimana cara melakukan pemesanan?',
      'a':
          'Pilih produk yang diinginkan, tambahkan ke keranjang, lalu ikuti proses checkout. Anda juga bisa memesan langsung melalui WhatsApp kami.'
    },
    {
      'q': 'Apakah saya perlu membuat akun untuk berbelanja?',
      'a':
          'Tidak wajib, namun kami sarankan membuat akun untuk menikmati riwayat pesanan, pelacakan pengiriman, dan penawaran khusus member.'
    },
    {
      'q': 'Bisakah saya mengubah atau membatalkan pesanan?',
      'a':
          'Perubahan atau pembatalan pesanan dapat dilakukan selama pesanan belum diproses. Hubungi customer service kami sesegera mungkin.'
    },
  ],
  'pengiriman': [
    {
      'q': 'Berapa lama proses pengiriman?',
      'a':
          '2-5 hari kerja untuk Jawa, 5-10 hari kerja untuk luar Jawa. Pesanan diproses 1-2 hari kerja setelah pembayaran dikonfirmasi.'
    },
    {
      'q': 'Jasa pengiriman apa yang digunakan?',
      'a': 'Kami bekerja sama dengan JNE, J&T Express, SiCepat, dan Anteraja.'
    },
    {
      'q': 'Apakah tersedia gratis ongkir?',
      'a':
          'Ya! Gratis ongkir untuk pembelian minimum Rp 200.000 ke seluruh Indonesia.'
    },
    {
      'q': 'Bagaimana cara melacak pesanan saya?',
      'a':
          'Setelah pesanan dikirim, nomor resi akan tersedia di halaman detail pesanan Anda.'
    },
  ],
  'pengembalian': [
    {
      'q': 'Apakah bisa melakukan pengembalian barang?',
      'a':
          'Ya, dalam waktu 7 hari setelah barang diterima, dengan syarat barang masih dalam kondisi original (belum dicuci, belum dipakai, tag masih terpasang).'
    },
    {
      'q': 'Bagaimana proses penukaran ukuran?',
      'a':
          'Ajukan penukaran dalam waktu 7 hari. Hubungi customer service, kirimkan barang kembali, dan kami akan mengirimkan ukuran yang sesuai.'
    },
    {
      'q': 'Siapa yang menanggung biaya pengiriman pengembalian?',
      'a':
          'Jika karena kesalahan kami (cacat/salah kirim), biaya ditanggung Mitologi. Untuk alasan lain, ditanggung pembeli.'
    },
  ],
  'pembayaran': [
    {
      'q': 'Metode pembayaran apa saja yang tersedia?',
      'a':
          'Transfer Bank (BCA, BRI, Mandiri, BNI), E-Wallet (GoPay, OVO, Dana, ShopeePay), Virtual Account, dan Indomaret/Alfamart melalui Midtrans.'
    },
    {
      'q': 'Apakah pembayaran di website ini aman?',
      'a':
          'Sangat aman. Kami menggunakan Midtrans yang tersertifikasi PCI DSS. Data pembayaran Anda dienkripsi.'
    },
    {
      'q': 'Berapa lama batas waktu pembayaran?',
      'a':
          'Batas waktu 24 jam setelah pesanan dibuat. Lewat dari itu, pesanan otomatis dibatalkan.'
    },
  ],
  'akun': [
    {
      'q': 'Bagaimana cara merubah informasi akun saya?',
      'a': 'Melalui menu Profil → Pengaturan setelah login.'
    },
    {
      'q': 'Apa fungsi fitur Wishlist?',
      'a':
          'Menyimpan produk favorit untuk dibeli nanti tanpa harus mencarinya kembali.'
    },
  ],
};

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  String _activeCategory = 'umum';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text('FAQ',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
      ),
      body: Column(
        children: [
          _buildCategoryTabs(),
          Expanded(child: _buildFaqList()),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _faqCategories.map((cat) {
            final isActive = cat['key'] == _activeCategory;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(cat['label']!),
                selected: isActive,
                onSelected: (_) =>
                    setState(() => _activeCategory = cat['key']!),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surfaceContainerLowest,
                labelStyle: TextStyle(
                  color: isActive ? Colors.white : AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                side: BorderSide(
                  color:
                      isActive ? AppColors.primary : AppColors.outlineVariant,
                ),
                showCheckmark: false,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFaqList() {
    final items = _faqData[_activeCategory] ?? [];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        ...items.map((faq) => _FaqItem(question: faq['q']!, answer: faq['a']!)),
      ],
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isOpen
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _isOpen = !_isOpen),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color:
                            _isOpen ? AppColors.primary : AppColors.onSurface,
                      ),
                    ),
                  ),
                  const Gap(8),
                  AnimatedRotation(
                    turns: _isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      PhosphorIconsRegular.caretDown,
                      size: 18,
                      color: _isOpen
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.answer,
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ),
            crossFadeState:
                _isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
