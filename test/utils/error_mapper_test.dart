import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/core/network/api_error.dart';
import 'package:mitologi_clothing_mobile/utils/error_mapper.dart';

void main() {
  group('ErrorMapper.mapAuthError', () {
    test('maps ApiError with validation fieldErrors', () {
      final error = ApiError(
        message: 'Validation failed',
        statusCode: 422,
        fieldErrors: {
          'email': ['Email telah terdaftar'],
        },
      );

      expect(
        ErrorMapper.mapAuthError(error),
        'Email sudah terdaftar, silakan login',
      );
    });

    test('maps ApiError message directly when no fieldErrors', () {
      final error = ApiError(
        message: 'Invalid credentials',
        statusCode: 401,
      );

      expect(
        ErrorMapper.mapAuthError(error),
        'Email atau password salah',
      );
    });

    test('maps invalid credentials string', () {
      expect(
        ErrorMapper.mapAuthError('invalid credentials'),
        'Email atau password salah',
      );
    });

    test('maps 401 error', () {
      expect(
        ErrorMapper.mapAuthError('Error 401 Unauthorized'),
        'Email atau password salah',
      );
    });

    test('maps user not found', () {
      expect(
        ErrorMapper.mapAuthError('user not found'),
        'Akun tidak ditemukan',
      );
    });

    test('maps email already exists', () {
      expect(
        ErrorMapper.mapAuthError('email already exists'),
        'Email sudah terdaftar, silakan login',
      );
    });

    test('maps already been taken', () {
      expect(
        ErrorMapper.mapAuthError('has already been taken'),
        'Email sudah terdaftar, silakan login',
      );
    });

    test('maps network error', () {
      expect(
        ErrorMapper.mapAuthError('network unreachable'),
        'Koneksi internet bermasalah, silakan coba lagi',
      );
    });

    test('maps socket error', () {
      expect(
        ErrorMapper.mapAuthError('socket exception'),
        'Koneksi internet bermasalah, silakan coba lagi',
      );
    });

    test('maps timeout error', () {
      expect(
        ErrorMapper.mapAuthError('connection timeout'),
        'Waktu tunggu habis, silakan coba lagi',
      );
    });

    test('maps ApiError from toString format', () {
      expect(
        ErrorMapper.mapAuthError('ApiError: Invalid credentials (Status: 401)'),
        'Email atau password salah',
      );
    });

    test('maps Exception with message', () {
      expect(
        ErrorMapper.mapAuthError(Exception('Email wajib diisi')),
        'Email wajib diisi',
      );
    });

    test('returns generic fallback for unknown error', () {
      expect(
        ErrorMapper.mapAuthError('some random error'),
        'Terjadi kesalahan, silakan coba lagi',
      );
    });

    test('returns generic fallback for empty string', () {
      expect(
        ErrorMapper.mapAuthError(''),
        'Terjadi kesalahan, silakan coba lagi',
      );
    });

    test('maps name required', () {
      expect(
        ErrorMapper.mapAuthError(Exception('the name field is required')),
        'Nama lengkap wajib diisi',
      );
    });

    test('maps email required', () {
      expect(
        ErrorMapper.mapAuthError(Exception('email is required')),
        'Email wajib diisi',
      );
    });

    test('maps valid email error', () {
      expect(
        ErrorMapper.mapAuthError(Exception('please enter a valid email')),
        'Format email tidak valid',
      );
    });

    test('maps password min length', () {
      expect(
        ErrorMapper.mapAuthError(Exception('password must be at least 8 characters')),
        'Password minimal 8 karakter',
      );
    });

    test('maps password uppercase required', () {
      expect(
        ErrorMapper.mapAuthError(Exception('must contain huruf besar')),
        'Password harus mengandung huruf besar',
      );
    });

    test('maps password lowercase required', () {
      expect(
        ErrorMapper.mapAuthError(Exception('must contain huruf kecil')),
        'Password harus mengandung huruf kecil',
      );
    });

    test('maps password digit required', () {
      expect(
        ErrorMapper.mapAuthError(Exception('must contain angka')),
        'Password harus mengandung angka',
      );
    });

    test('maps password confirmation mismatch', () {
      expect(
        ErrorMapper.mapAuthError(Exception('password confirmation mismatch')),
        'Konfirmasi password tidak cocok',
      );
    });

    test('maps registration successful', () {
      expect(
        ErrorMapper.mapAuthError(Exception('registration successful')),
        'Registrasi berhasil! Selamat datang',
      );
    });

    test('maps too many attempts', () {
      expect(
        ErrorMapper.mapAuthError(Exception('too many attempts')),
        'Terlalu banyak percobaan, silakan tunggu beberapa saat',
      );
    });

    test('passes through clear Indonesian messages', () {
      expect(
        ErrorMapper.mapAuthError(Exception('Field wajib diisi')),
        'Field wajib diisi',
      );
    });
  });

  group('ErrorMapper.mapCheckoutError', () {
    test('maps out of stock', () {
      expect(
        ErrorMapper.mapCheckoutError('product out of stock'),
        'Produk sudah habis, silakan hapus dari keranjang',
      );
    });

    test('maps invalid cart', () {
      expect(
        ErrorMapper.mapCheckoutError('invalid cart'),
        'Keranjang tidak valid, silakan refresh',
      );
    });

    test('maps address error', () {
      expect(
        ErrorMapper.mapCheckoutError('missing address'),
        'Alamat pengiriman tidak valid',
      );
    });

    test('maps payment error', () {
      expect(
        ErrorMapper.mapCheckoutError('payment declined'),
        'Pembayaran gagal, silakan coba metode lain',
      );
    });

    test('returns generic fallback', () {
      expect(
        ErrorMapper.mapCheckoutError('unknown'),
        'Checkout gagal, silakan coba lagi',
      );
    });
  });

  group('ErrorMapper.mapCartError', () {
    test('maps not found', () {
      expect(
        ErrorMapper.mapCartError('item not found'),
        'Produk tidak ditemukan di keranjang',
      );
    });

    test('maps quantity error', () {
      expect(
        ErrorMapper.mapCartError('invalid quantity'),
        'Jumlah produk tidak valid',
      );
    });

    test('returns generic fallback', () {
      expect(
        ErrorMapper.mapCartError('unknown'),
        'Gagal memperbarui keranjang',
      );
    });
  });
}
