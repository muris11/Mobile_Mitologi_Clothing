import '../core/network/api_error.dart';

/// Maps technical errors to user-friendly messages
class ErrorMapper {
  static String mapAuthError(dynamic error) {
    // Prioritas 1: Jika error adalah ApiError, ambil pesan langsung dari object
    if (error is ApiError) {
      // Jika ada field errors (validation), tampilkan yang pertama
      if (error.isValidationError && error.fieldErrors != null) {
        final firstError = error.fieldErrors!.values
            .expand((e) => e)
            .firstWhere((e) => e.isNotEmpty, orElse: () => '');
        if (firstError.isNotEmpty) {
          return _mapBackendMessage(firstError);
        }
      }
      // Map pesan utama backend
      return _mapBackendMessage(error.message);
    }

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
    if (errorString.contains('apierror') || errorString.contains('apiexception')) {
      // Extract message dari toString format: "ApiError: message (Status: X)"
      final match = RegExp(r'ApiError: (.+) \(Status:').firstMatch(error.toString());
      if (match != null) {
        return _mapBackendMessage(match.group(1)?.trim() ?? '');
      }
    }

    // Handle plain Exception messages (e.g., from client-side validation in AuthService)
    if (error is Exception) {
      final match = RegExp(r'^Exception: (.+)$').firstMatch(error.toString());
      if (match != null) {
        return _mapBackendMessage(match.group(1)!.trim());
      }
    }

    // Generic fallback - don't expose raw technical details
    return 'Terjadi kesalahan, silakan coba lagi';
  }

  /// Map pesan dari backend ke Bahasa Indonesia yang lebih user-friendly
  static String _mapBackendMessage(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('email already exists') ||
        lower.contains('already been taken') ||
        lower.contains('email telah terdaftar') ||
        lower.contains('sudah digunakan')) {
      return 'Email sudah terdaftar, silakan login';
    }
    if (lower.contains('invalid credentials') ||
        lower.contains('password salah') ||
        lower.contains('tidak cocok')) {
      return 'Email atau password salah';
    }
    if (lower.contains('user not found') ||
        lower.contains('pengguna tidak ditemukan') ||
        lower.contains('akun tidak ditemukan')) {
      return 'Akun tidak ditemukan';
    }
    if (lower.contains('nama wajib diisi') ||
        lower.contains('name is required') ||
        lower.contains('the name field is required')) {
      return 'Nama lengkap wajib diisi';
    }
    if (lower.contains('email wajib diisi') ||
        lower.contains('email is required') ||
        lower.contains('the email field is required')) {
      return 'Email wajib diisi';
    }
    if (lower.contains('surel yang valid') ||
        lower.contains('valid email') ||
        lower.contains('email harus berupa')) {
      return 'Format email tidak valid';
    }
    if (lower.contains('password minimal') ||
        lower.contains('password must be at least') ||
        lower.contains('password is required')) {
      return 'Password minimal 8 karakter';
    }
    if (lower.contains('huruf besar')) {
      return 'Password harus mengandung huruf besar';
    }
    if (lower.contains('huruf kecil')) {
      return 'Password harus mengandung huruf kecil';
    }
    if (lower.contains('angka') || lower.contains('digit')) {
      return 'Password harus mengandung angka';
    }
    if (lower.contains('password wajib diisi')) {
      return 'Password wajib diisi';
    }
    if (lower.contains('konfirmasi password wajib diisi')) {
      return 'Konfirmasi password wajib diisi';
    }
    if (lower.contains('konfirmasi password') ||
        lower.contains('password confirmation') ||
        lower.contains('password tidak cocok') ||
        lower.contains('tidak cocok')) {
      return 'Konfirmasi password tidak cocok';
    }
    if (lower.contains('registrasi berhasil') ||
        lower.contains('registration successful') ||
        lower.contains('berhasil mendaftar')) {
      return 'Registrasi berhasil! Selamat datang';
    }
    if (lower.contains('too many attempts') ||
        lower.contains('terlalu banyak percobaan')) {
      return 'Terlalu banyak percobaan, silakan tunggu beberapa saat';
    }

    // Jika pesan dari backend sudah dalam bahasa Indonesia dan cukup jelas
    if (lower.contains('wajib diisi') ||
        lower.contains('tidak valid') ||
        lower.contains('tidak ditemukan') ||
        lower.contains('sudah terdaftar')) {
      return message;
    }

    return message.isNotEmpty ? message : 'Terjadi kesalahan, silakan coba lagi';
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
