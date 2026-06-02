import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/features/ai/data/ai_repository.dart';
import 'package:mitologi_clothing_mobile/features/ai/domain/models/ai_models.dart';

class ChatbotProvider extends ChangeNotifier {
  final AiRepository _repository;

  ChatbotProvider(this._repository);

  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  String? _error;

  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;
  String? get error => _error;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage.user(text);
    _messages.add(userMessage);
    _isTyping = true;
    _error = null;
    notifyListeners();

    try {
      final history = _messages.length > 1 
          ? _messages.sublist(0, _messages.length - 1) 
          : null;

      final response = await _repository.sendMessage(text, history);
      
      if (response != null && response.reply.isNotEmpty) {
        _messages.add(ChatMessage.assistant(_sanitize(response.reply)));
      } else {
        // Use smart local AI fallback if backend is offline or returns empty
        final fallback = _getSmartFallbackReply(text);
        _messages.add(ChatMessage.assistant(fallback));
      }
    } catch (e) {
      final fallback = _getSmartFallbackReply(text);
      _messages.add(ChatMessage.assistant(fallback));
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  String _sanitize(String text) {
    return text
        .replaceAll(RegExp(r'\*\*(.+?)\*\*', dotAll: true), r'$1')
        .replaceAll(RegExp(r'\*(.+?)\*', dotAll: true), r'$1')
        .replaceAll(RegExp(r'__(.+?)__', dotAll: true), r'$1')
        .replaceAll(RegExp(r'_(.+?)_', dotAll: true), r'$1')
        .replaceAll(RegExp(r'~~(.+?)~~', dotAll: true), r'$1')
        .replaceAll(RegExp(r'\[(.+?)\]\(.+?\)', dotAll: true), r'$1')
        .replaceAll(RegExp(r'^#+\s*', multiLine: true), '')
        .replaceAll(RegExp(r'^-\s', multiLine: true), '  \u2022 ')
        .replaceAll(RegExp(r'^(\d+)\.\s', multiLine: true), r'  $1. ')
        .replaceAll(RegExp(r'>\s?'), '')
        .replaceAll(RegExp(r'`{1,3}[^`]*`{1,3}'), '')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll(RegExp(r'^-{3,}|_{3,}|\*{3,}', multiLine: true), '')
        .replaceAll(RegExp(r'[ \t]+$', multiLine: true), '')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  String _getSmartFallbackReply(String query) {
    final q = query.toLowerCase();
    
    if (q.contains('halo') || q.contains('hai') || q.contains('pagi') || q.contains('siang') || q.contains('sore') || q.contains('malam') || q.contains('hello')) {
      return 'Halo! Selamat datang di Mitologi Clothing. Saya Asisten Virtual & Personal Stylist Anda.\n\n'
             'Ada yang bisa saya bantu hari ini? Berikut topik yang sering ditanyakan:\n\n'
             '  Rekomendasi ukuran dan panduan size chart\n'
             '  Status dan ongkos kirim\n'
             '  Metode pembayaran\n'
             '  Kebijakan retur dan pengembalian';
    }
    
    if (q.contains('ukuran') || q.contains('size') || q.contains('panduan') || q.contains('muat')) {
      return 'Tentu! Berikut Panduan Ukuran Oversized Tees Mitologi Clothing:\n\n'
             '  Ukuran S  Lebar 50 cm, Panjang 70 cm (TB 150160 cm)\n'
             '  Ukuran M  Lebar 54 cm, Panjang 73 cm (TB 160170 cm)\n'
             '  Ukuran L  Lebar 58 cm, Panjang 76 cm (TB 170180 cm)\n'
             '  Ukuran XL  Lebar 62 cm, Panjang 79 cm (TB 180185 cm)\n'
             '  Ukuran XXL  Lebar 66 cm, Panjang 82 cm (TB diatas 185 cm)\n\n'
             'Bahan menggunakan 100% Cotton Combed 24s Heavyweight Premium. Sangat nyaman dan tegak di badan.';
    }
    
    if (q.contains('ongkir') || q.contains('kirim') || q.contains('ekspedisi') || q.contains('pengiriman')) {
      return 'Mitologi Clothing mengirim dari warehouse Bandung. Ekspedisi yang tersedia:\n\n'
             '  1. JNE Reguler dan YES\n'
             '  2. J&T Express dan COD\n'
             '  3. SiCepat HALU dan Reguler\n\n'
             'Pesanan sebelum jam 16:00 WIB dikirim di hari yang sama. Estimasi sampai:\n'
             '  Pulau Jawa 1 sampai 3 hari kerja\n'
             '  Luar Pulau Jawa 3 sampai 5 hari kerja';
    }
    
    if (q.contains('bayar') || q.contains('metode') || q.contains('payment') || q.contains('transfer') || q.contains('gopay') || q.contains('qris')) {
      return 'Pembayaran dilakukan melalui Midtrans Pay. Metode yang tersedia:\n\n'
             '  EWallet GoPay, ShopeePay, QRIS\n'
             '  Virtual Account BCA, Mandiri, BNI, BRI, Permata\n'
             '  Over the Counter Alfamart, Indomaret\n\n'
             'Pembayaran terverifikasi secara otomatis dan instan!';
    }
    
    if (q.contains('retur') || q.contains('tukar') || q.contains('kembali') || q.contains('cacat') || q.contains('rusak')) {
      return 'Kepuasan Anda prioritas kami. Garansi retur berlaku jika:\n\n'
             '  1. Produk cacat produksi (bolong atau sablon rusak)\n'
             '  2. Ukuran tidak sesuai dengan pesanan\n\n'
             'Syarat retur:\n'
             '  Maksimal 7 hari sejak produk diterima\n'
             '  Tag produk masih terpasang dan belum dicuci\n'
             '  Wajib menyertakan video unboxing sebagai bukti';
    }

    if (q.contains('alamat') || q.contains('toko') || q.contains('lokasi') || q.contains('offline')) {
      return 'Mitologi Clothing beroperasi secara Online Exclusive untuk menjaga harga produk tetap kompetitif. Warehouse dan Fulfillment Center kami berlokasi di Bandung, Jawa Barat.\n\n'
             'Semua produk dikirim langsung dari Bandung dengan packaging box premium yang aman.';
    }
    
    if (q.contains('bahan') || q.contains('kain') || q.contains('combed') || q.contains('cotton')) {
      return 'Semua kaos Mitologi Clothing menggunakan Cotton Combed 24s Heavyweight Premium:\n\n'
             '  Serat benang sangat rapat dan tebal\n'
             '  Adem, menyerap keringat dengan baik, tidak menerawang\n'
             '  Sablon Plastisol Discharge, awet dan lembut menyatu dengan kain';
    }

    if (q.contains('promo') || q.contains('diskon') || q.contains('potongan') || q.contains('murah')) {
      return 'Promo spesial hari ini:\n\n'
             '  Diskon 10% untuk pengguna baru aplikasi\n'
             '  Free Premium Sticker Pack di setiap pembelian kaos\n'
             '  Free Shipping minimal belanja Rp 350.000\n\n'
             'Cek menu Promo di halaman Akun untuk voucher terupdate.';
    }

    return 'Terima kasih atas pesan Anda. Sebagai asisten Mitologi Clothing, saya sarankan produk kaos Oversized Premium dengan desain sablon kultur khas yang sedang best seller. Ada yang bisa saya bantu lebih lanjut?';
  }

  void clearChat() {
    _messages.clear();
    _error = null;
    notifyListeners();
  }
}
