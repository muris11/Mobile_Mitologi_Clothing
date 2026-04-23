import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../core/network/api_error.dart';
import '../core/network/response_normalizer.dart';
import '../utils/retry_policy.dart';

typedef ApiException = ApiError;

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<T> _withRetry<T>(
    Future<T> Function() operation, {
    RetryPolicy? retryPolicy,
  }) async {
    final policy = retryPolicy ?? const RetryPolicy();
    int attempt = 0;

    while (true) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        if (e is! Exception || !policy.shouldRetry(attempt, e)) {
          rethrow;
        }

        if (attempt >= policy.maxRetries) {
          rethrow;
        }

        final delay = policy.getDelayForAttempt(attempt);
        await Future.delayed(delay);
      }
    }
  }

  Future<Map<String, String>> _getHeaders(
      {bool requiresAuth = false,
      String? authToken,
      String? cartSessionId}) async {
    final headers = {
      ApiHeaders.contentType: ApiHeaders.applicationJson,
      ApiHeaders.accept: ApiHeaders.applicationJson,
    };
    if (requiresAuth && authToken != null) {
      headers[ApiHeaders.authorization] = ApiHeaders.bearerToken(authToken);
    }
    if (cartSessionId != null) {
      headers[ApiHeaders.cartId] = cartSessionId;
      headers[ApiHeaders.sessionId] = cartSessionId;
    }
    return headers;
  }

  Future<dynamic> get(String endpoint,
      {Map<String, dynamic>? queryParams,
      bool requiresAuth = false,
      String? authToken,
      String? cartSessionId}) async {
    return _withRetry(() async {
      final queryParameters =
          queryParams?.map((key, value) => MapEntry(key, value.toString()));
      final url = ApiConfig.buildUri(endpoint, queryParams: queryParameters);
      final headers = await _getHeaders(
          requiresAuth: requiresAuth,
          authToken: authToken,
          cartSessionId: cartSessionId);
      try {
        final response = await _client
            .get(url, headers: headers)
            .timeout(const Duration(milliseconds: ApiConfig.timeoutDuration));
        return _processResponse(response);
      } on SocketException {
        throw ApiException.network('No internet connection');
      } on ApiException {
        rethrow;
      } catch (e) {
        throw ApiException.network('Network error: $e');
      }
    });
  }

  Future<dynamic> post(String endpoint,
      {Map<String, dynamic>? body,
      bool requiresAuth = false,
      String? authToken,
      String? cartSessionId}) async {
    return _withRetry(() async {
      final url = ApiConfig.buildUri(endpoint);
      final headers = await _getHeaders(
          requiresAuth: requiresAuth,
          authToken: authToken,
          cartSessionId: cartSessionId);
      try {
        final response = await _client
            .post(url,
                headers: headers, body: body != null ? json.encode(body) : null)
            .timeout(const Duration(milliseconds: ApiConfig.timeoutDuration));
        return _processResponse(response);
      } on SocketException {
        throw ApiException.network('No internet connection');
      } on ApiException {
        rethrow;
      } catch (e) {
        throw ApiException.network('Network error: $e');
      }
    });
  }

  Future<dynamic> put(String endpoint,
      {Map<String, dynamic>? body,
      bool requiresAuth = false,
      String? authToken,
      String? cartSessionId}) async {
    return _withRetry(() async {
      final url = ApiConfig.buildUri(endpoint);
      final headers = await _getHeaders(
          requiresAuth: requiresAuth,
          authToken: authToken,
          cartSessionId: cartSessionId);
      try {
        final response = await _client
            .put(url,
                headers: headers, body: body != null ? json.encode(body) : null)
            .timeout(const Duration(milliseconds: ApiConfig.timeoutDuration));
        return _processResponse(response);
      } on SocketException {
        throw ApiException.network('No internet connection');
      } on ApiException {
        rethrow;
      } catch (e) {
        throw ApiException.network('Network error: $e');
      }
    });
  }

  Future<dynamic> delete(String endpoint,
      {bool requiresAuth = false,
      String? authToken,
      String? cartSessionId}) async {
    return _withRetry(() async {
      final url = ApiConfig.buildUri(endpoint);
      final headers = await _getHeaders(
          requiresAuth: requiresAuth,
          authToken: authToken,
          cartSessionId: cartSessionId);
      try {
        final response = await _client
            .delete(url, headers: headers)
            .timeout(const Duration(milliseconds: ApiConfig.timeoutDuration));
        return _processResponse(response);
      } on SocketException {
        throw ApiException.network('No internet connection');
      } on ApiException {
        rethrow;
      } catch (e) {
        throw ApiException.network('Network error: $e');
      }
    });
  }

  Future<dynamic> multipartPost(String endpoint,
      {Map<String, String>? fields,
      List<http.MultipartFile>? files,
      String? filePath,
      String? fileField,
      bool requiresAuth = false,
      String? authToken,
      String? cartSessionId}) async {
    return _withRetry(() async {
      final url = ApiConfig.buildUri(endpoint);
      final request = http.MultipartRequest('POST', url);

      // Add headers
      if (requiresAuth && authToken != null) {
        request.headers[ApiHeaders.authorization] =
            ApiHeaders.bearerToken(authToken);
      }
      if (cartSessionId != null) {
        request.headers[ApiHeaders.cartId] = cartSessionId;
        request.headers[ApiHeaders.sessionId] = cartSessionId;
      }

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add files
      if (files != null) {
        request.files.addAll(files);
      }

      // Add single file if filePath provided
      if (filePath != null && fileField != null) {
        final file = await http.MultipartFile.fromPath(fileField, filePath);
        request.files.add(file);
      }

      try {
        final streamedResponse = await request
            .send()
            .timeout(const Duration(milliseconds: ApiConfig.timeoutDuration));
        final response = await http.Response.fromStream(streamedResponse);
        return _processResponse(response);
      } on SocketException {
        throw ApiException.network('No internet connection');
      } on ApiException {
        rethrow;
      } catch (e) {
        throw ApiException.network('Network error: $e');
      }
    });
  }

  dynamic _processResponse(http.Response response) {
    if (response.body.isEmpty) return null;

    dynamic jsonResponse;
    try {
      jsonResponse = json.decode(response.body);
    } catch (e) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body;
      }
      throw ApiException(
        message: 'Invalid JSON response',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ResponseNormalizer.normalize(jsonResponse);
    }

    String message = 'Something went wrong';
    String? code;
    Map<String, List<String>>? fieldErrors;

    if (jsonResponse is Map<String, dynamic>) {
      message = jsonResponse['message'] ??
          (jsonResponse['error'] is Map
              ? jsonResponse['error']['message']
              : null) ??
          message;

      final error = jsonResponse['error'];
      if (error is Map<String, dynamic>) {
        code = error['code']?.toString();
        final details = error['details'];
        if (details is Map<String, dynamic>) {
          fieldErrors = details.map(
            (key, value) => MapEntry(
              key,
              (value as List?)?.map((item) => item.toString()).toList() ?? const [],
            ),
          );
        }
      }

      final errors = jsonResponse['errors'];
      if (fieldErrors == null && errors is Map<String, dynamic>) {
        fieldErrors = errors.map(
          (key, value) => MapEntry(
            key,
            (value as List?)?.map((item) => item.toString()).toList() ?? const [],
          ),
        );
      }
    }

    throw ApiException(
      message: message,
      statusCode: response.statusCode,
      code: code,
      fieldErrors: fieldErrors,
    );
  }
}
