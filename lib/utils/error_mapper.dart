/// Maps technical errors to user-friendly messages
class ErrorMapper {
  static String mapAuthError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Map specific backend errors to friendly messages
    if (errorString.contains('invalid credentials') ||
        errorString.contains('401')) {
      return 'Email atau password salah';
    }
    if (errorString.contains('user not found')) {
      return 'Akun tidak ditemukan';
    }
    if (errorString.contains('email already exists') ||
        errorString.contains('already been taken')) {
      return 'Email sudah terdaftar, silakan login';
    }
    if (errorString.contains('network') || errorString.contains('socket')) {
      return 'Koneksi internet bermasalah, silakan coba lagi';
    }
    if (errorString.contains('timeout')) {
      return 'Waktu tunggu habis, silakan coba lagi';
    }
    if (errorString.contains('apiexception')) {
      // Extract message from ApiException if possible
      final match = RegExp(r'message: (.+)').firstMatch(error.toString());
      if (match != null) {
        return match.group(1) ?? 'Terjadi kesalahan';
      }
    }

    // Generic fallback - don't expose raw technical details
    return 'Terjadi kesalahan, silakan coba lagi';
  }

  static String mapCheckoutError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('out of stock')) {
      return 'Produk sudah habis, silakan hapus dari keranjang';
    }
    if (errorString.contains('invalid cart')) {
      return 'Keranjang tidak valid, silakan refresh';
    }
    if (errorString.contains('address')) {
      return 'Alamat pengiriman tidak valid';
    }
    if (errorString.contains('payment')) {
      return 'Pembayaran gagal, silakan coba metode lain';
    }

    return 'Checkout gagal, silakan coba lagi';
  }

  static String mapCartError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('not found')) {
      return 'Produk tidak ditemukan di keranjang';
    }
    if (errorString.contains('quantity')) {
      return 'Jumlah produk tidak valid';
    }

    return 'Gagal memperbarui keranjang';
  }
}
