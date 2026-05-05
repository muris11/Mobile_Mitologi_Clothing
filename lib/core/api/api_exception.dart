import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errors;

  ApiException({required this.message, this.statusCode, this.errors});

  factory ApiException.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.cancel:
        return ApiException(message: "Request to API server was cancelled");
      case DioExceptionType.connectionTimeout:
        return ApiException(message: "Connection timeout with API server");
      case DioExceptionType.receiveTimeout:
        return ApiException(message: "Receive timeout in connection with API server");
      case DioExceptionType.sendTimeout:
        return ApiException(message: "Send timeout in connection with API server");
      case DioExceptionType.connectionError:
        return ApiException(message: "Connection error with API server");
      case DioExceptionType.badResponse:
        return _handleError(
          dioException.response?.statusCode,
          dioException.response?.data,
        );
      case DioExceptionType.unknown:
        if (dioException.message?.contains("SocketException") ?? false) {
          return ApiException(message: 'No Internet connection');
        }
        return ApiException(message: "Unexpected error occurred");
      default:
        return ApiException(message: "Something went wrong");
    }
  }

  static ApiException _handleError(int? statusCode, dynamic error) {
    String message = "Something went wrong";
    dynamic errors;

    if (error is Map<String, dynamic>) {
      message = error['message'] ?? message;
      errors = error['errors'];
    }

    switch (statusCode) {
      case 400:
        return ApiException(message: message, statusCode: 400);
      case 401:
        return ApiException(message: "Unauthorized access", statusCode: 401);
      case 403:
        return ApiException(message: "Forbidden access", statusCode: 403);
      case 404:
        return ApiException(message: message, statusCode: 404);
      case 422:
        return ApiException(message: message, statusCode: 422, errors: errors);
      case 429:
        return ApiException(message: "Too many requests. Please try again later.", statusCode: 429);
      case 500:
        return ApiException(message: "Internal server error", statusCode: 500);
      default:
        return ApiException(message: message, statusCode: statusCode);
    }
  }

  @override
  String toString() => message;
}
