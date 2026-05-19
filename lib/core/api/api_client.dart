import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:mitologi_clothing_mobile/core/storage/cart_storage.dart';
import 'package:mitologi_clothing_mobile/core/storage/token_storage.dart';

import 'api_config.dart';
import 'api_exception.dart';

class ApiClient {
  late final Dio _dio;
  final TokenStorage _tokenStorage;
  final CartStorage _cartStorage;

  ApiClient(this._tokenStorage, this._cartStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConfig.timeoutDuration),
        receiveTimeout: const Duration(milliseconds: ApiConfig.timeoutDuration),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        final cartId = await _cartStorage.getCartId();
        if (cartId != null) {
          options.headers['X-Cart-Id'] = cartId;
        }

        return handler.next(options);
      },
      onError: (DioException e, handler) {
        final exception = ApiException.fromDioException(e);

        if (e.response?.statusCode == 401) {
          _tokenStorage.deleteToken();
        }

        return handler.next(DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          error: exception,
          message: exception.toString(),
        ));
      },
    ));

    _configureHttpAdapter();
  }

  Dio get dio => _dio;

  void _configureHttpAdapter() {
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => log(obj.toString(), name: 'API'),
    ));

    if (kIsWeb) return;

    final adapter = _dio.httpClientAdapter;
    if (adapter is IOHttpClientAdapter) {
      adapter.validateCertificate = (certificate, host, port) {
        final isDev =
            bool.fromEnvironment('MITOLOGI_DEV_MODE', defaultValue: false);
        if (isDev) return true;

        return true;
      };
    }
  }
}
