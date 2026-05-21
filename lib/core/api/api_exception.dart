import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errors;

  ApiException({required this.message, this.statusCode, this.errors});

  factory ApiException.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.cancel:
        return ApiException(message: "Permintaan ke server API dibatalkan");
      case DioExceptionType.connectionTimeout:
        return ApiException(message: "Koneksi ke server API habis waktu");
      case DioExceptionType.receiveTimeout:
        return ApiException(message: "Waktu tunggu menerima data dari server API habis");
      case DioExceptionType.sendTimeout:
        return ApiException(message: "Waktu tunggu mengirim data ke server API habis");
      case DioExceptionType.connectionError:
        return ApiException(message: "Kesalahan koneksi dengan server API");
      case DioExceptionType.badResponse:
        return _handleError(
          dioException.response?.statusCode,
          dioException.response?.data,
        );
      case DioExceptionType.unknown:
        if (dioException.message?.contains("SocketException") ?? false) {
          return ApiException(message: 'Tidak ada koneksi internet');
        }
        return ApiException(message: "Terjadi kesalahan yang tidak terduga");
      default:
        return ApiException(message: "Terjadi kesalahan, silakan coba lagi");
    }
  }

  static ApiException _handleError(int? statusCode, dynamic error) {
    String message = "Terjadi kesalahan, silakan coba lagi";
    dynamic errors;

    if (error is Map) {
      if (error['message'] != null) {
        message = error['message'].toString();
      } else if (error['error'] != null) {
        final errorObj = error['error'];
        if (errorObj is Map) {
          message = errorObj['message']?.toString() ?? message;
          errors = errorObj['details'];
        } else {
          message = errorObj.toString();
        }
      }
      errors ??= error['errors'];
    }

    switch (statusCode) {
      case 400:
        return ApiException(message: message, statusCode: 400);
      case 401:
        return ApiException(message: message, statusCode: 401);
      case 403:
        return ApiException(message: message, statusCode: 403);
      case 404:
        return ApiException(message: message, statusCode: 404);
      case 422:
        return ApiException(message: message, statusCode: 422, errors: errors);
      case 429:
        return ApiException(message: "Terlalu banyak permintaan. Silakan coba lagi nanti.", statusCode: 429);
      case 500:
        return ApiException(message: "Terjadi kesalahan pada server", statusCode: 500);
      default:
        return ApiException(message: message, statusCode: statusCode);
    }
  }

  @override
  String toString() {
    if (errors != null) {
      if (errors is Map) {
        final map = errors as Map;
        if (map.isNotEmpty) {
          final firstVal = map.values.first;
          if (firstVal is List && firstVal.isNotEmpty) {
            return firstVal.first.toString();
          }
          return firstVal.toString();
        }
      } else if (errors is List && (errors as List).isNotEmpty) {
        return (errors as List).first.toString();
      }
    }
    return message;
  }
  
  // Custom display helper for clean message display
  String get displayMessage {
    return toString();
  }
}
