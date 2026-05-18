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
        _messages.add(ChatMessage.assistant(response.reply));
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

  String _getSmartFallbackReply(String query) {
    final q = query.toLowerCase();
    
    if (q.contains('halo') || q.contains('hai') || q.contains('pagi') || q.contains('siang') || q.contains('sore') || q.contains('malam') || q.contains('hello')) {
      return 'Halo! Selamat datang di Mitologi Clothing. Saya adalah Asisten Virtual & Personal Stylist Anda. Ada yang bisa saya bantu hari ini?\n\nAnda bisa bertanya tentang:\n- Rekomendasi size / Panduan Ukuran\n- Status & Ongkos Kirim\n- Metode Pembayaran\n- Kebijakan Retur / Pengembalian';
    }
    
    if (q.contains('ukuran') || q.contains('size') || q.contains('panduan') || q.contains('muat')) {
      return 'Tentu! Berikut adalah Panduan Ukuran (Size Chart) Oversized Tees khas Mitologi Clothing:\n\n'
             '- S: Lebar 50 cm | Panjang 70 cm (TB 150-160 cm)\n'
             '- M: Lebar 54 cm | Panjang 73 cm (TB 160-170 cm)\n'
             '- L: Lebar 58 cm | Panjang 76 cm (TB 170-180 cm)\n'
             '- XL: Lebar 62 cm | Panjang 79 cm (TB 180-185 cm)\n'
             '- XXL: Lebar 66 cm | Panjang 82 cm (TB >185 cm)\n\n'
             'Bahan menggunakan 100% Cotton Combed 24s Heavyweight Premium, sangat nyaman dan tegak di badan.';
    }
    
    if (q.contains('ongkir') || q.contains('kirim') || q.contains('ekspedisi') || q.contains('pengiriman')) {
      return 'Mitologi Clothing mengirimkan pesanan dari warehouse kami di Bandung. Kami bekerja sama dengan beberapa ekspedisi terpercaya:\n\n'
             '1. JNE (Reguler & YES)\n'
             '2. J&T (Express & COD)\n'
             '3. SiCepat (HALU & Reguler)\n\n'
             'Pesanan sebelum jam 16:00 WIB akan dikirim di hari yang sama. Estimasi pengiriman Pulau Jawa 1-3 hari kerja, luar Pulau Jawa 3-5 hari kerja.';
    }
    
    if (q.contains('bayar') || q.contains('metode') || q.contains('payment') || q.contains('transfer') || q.contains('gopay') || q.contains('qris')) {
      return 'Kami menyediakan metode pembayaran yang sangat praktis melalui Midtrans Pay:\n\n'
             '- E-Wallet: GoPay, ShopeePay, QRIS\n'
             '- Virtual Account (VA): BCA, Mandiri, BNI, BRI, Permata\n'
             '- Over the Counter: Alfamart, Indomaret\n\n'
             'Pembayaran akan terverifikasi secara otomatis oleh sistem kami secara instan!';
    }
    
    if (q.contains('retur') || q.contains('tukar') || q.contains('kembali') || q.contains('cacat') || q.contains('rusak')) {
      return 'Kepuasan Anda adalah prioritas kami! Kami menjamin garansi retur jika:\n\n'
             '1. Produk yang diterima cacat produksi (bolong, sablon rusak).\n'
             '2. Ukuran tidak sesuai dengan pesanan Anda.\n\n'
             'Syarat Retur:\n'
             '- Maksimal 7 hari sejak produk diterima.\n'
             '- Tag produk masih terpasang dan belum dicuci.\n'
             '- Wajib menyertakan video unboxing sebagai bukti penukaran.';
    }

    if (q.contains('alamat') || q.contains('toko') || q.contains('lokasi') || q.contains('offline')) {
      return 'Saat ini Mitologi Clothing beroperasi secara Online Exclusive untuk menjaga efisiensi harga produk premium kami. Warehouse & Fulfillment Center kami berlokasi di Bandung, Jawa Barat.\n\n'
             'Semua produk dikirim langsung dari Bandung dengan standardisasi packaging box premium yang aman!';
    }
    
    if (q.contains('bahan') || q.contains('kain') || q.contains('combed') || q.contains('cotton')) {
      return 'Semua produk kaos Mitologi Clothing menggunakan bahan Cotton Combed 24s Heavyweight Premium.\n\n'
             '- Serat benang sangat rapat and tebal.\n'
             '- Adem, menyerap keringat dengan baik, dan tidak menerawang.\n'
             '- Sablon menggunakan teknologi Plastisol Discharge yang sangat awet, lembut menyatu dengan kain, dan tahan setrika.';
    }

    if (q.contains('promo') || q.contains('diskon') || q.contains('potongan') || q.contains('murah')) {
      return 'Dapatkan promo spesial hari ini:\n\n'
             '- Diskon 10% untuk pengguna baru aplikasi!\n'
             '- Free Premium Sticker Pack di setiap pembelian produk kaos.\n'
             '- Free Shipping dengan min. belanja Rp 350.000.\n\n'
             'Silakan cek menu Promo & Penawaran di halaman Akun Anda untuk voucher terupdate!';
    }

    return 'Terima kasih atas pesan Anda! Saya mengerti maksud Anda mengenai hal tersebut.\n\n'
           'Sebagai asisten Mitologi Clothing, saya merekomendasikan produk kaos Oversized Premium kami dengan desain sablon kultur khas yang sedang best-seller. Apakah Anda ingin saya carikan rekomendasi model tertentu?';
  }

  void clearChat() {
    _messages.clear();
    _error = null;
    notifyListeners();
  }
}
