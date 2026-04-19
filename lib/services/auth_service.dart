import 'dart:async';

import '../config/api_config.dart';
import '../core/session/auth_session_manager.dart';
import '../models/user.dart';
import '../utils/input_validator.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  final AuthSessionManager _sessionManager;

  AuthService(this._apiService, {AuthSessionManager? sessionManager})
      : _sessionManager = sessionManager ?? AuthSessionManager();

  Map<String, dynamic> _unwrapResponse(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) return data;
      return response;
    }
    return <String, dynamic>{};
  }

  Future<AuthResponse> register(
      {required String name,
      required String email,
      required String password,
      required String passwordConfirmation,
      String? phone}) async {
    // Client-side validation before API call
    final passwordError = InputValidator.validatePassword(password);
    if (passwordError != null) {
      throw Exception(passwordError);
    }

    final confirmationError = InputValidator.validatePasswordConfirmation(
        password, passwordConfirmation);
    if (confirmationError != null) {
      throw Exception(confirmationError);
    }

    final response = await _apiService.post(ApiEndpoints.authRegister, body: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      if (phone != null) 'phone': phone,
    });
    final data = _unwrapResponse(response);
    return AuthResponse.fromJson(data);
  }

  Future<AuthResponse> login(
      {required String email,
      required String password,
      String? cartSessionId}) async {
    final response = await _apiService.post(ApiEndpoints.authLogin,
        body: {'email': email, 'password': password},
        cartSessionId: cartSessionId);

    final data = _unwrapResponse(response);
    final authResponse = AuthResponse.fromJson(data);

    // Persist auth data before returning to avoid race conditions on navigation.
    if (authResponse.token != null) {
      await _sessionManager.saveToken(authResponse.token!);
    }
    if (authResponse.user != null) {
      await _sessionManager.saveUserData(authResponse.user!.toJsonString());
    }
    return authResponse;
  }

  Future<void> logout() async {
    final token = await _sessionManager.loadToken();
    if (token != null) {
      try {
        await _apiService.post(ApiEndpoints.authLogout,
            requiresAuth: true, authToken: token);
      } catch (e) {
        // Logout failed but we still clear local auth data below
      }
    }
    await _sessionManager.clear();
  }

  Future<User?> getCurrentUser() async {
    final token = await _sessionManager.loadToken();
    if (token == null) return null;
    try {
      final response = await _apiService.get(ApiEndpoints.authUser,
          requiresAuth: true, authToken: token);
      final data = _unwrapResponse(response);
      final userData = data['user'] is Map<String, dynamic>
          ? data['user'] as Map<String, dynamic>
          : data;
      return User.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  Future<void> forgotPassword(String email) async => await _apiService
      .post(ApiEndpoints.authForgotPassword, body: {'email': email});

  Future<void> resetPassword(
      {required String token,
      required String email,
      required String password,
      required String passwordConfirmation}) async {
    await _apiService.post(ApiEndpoints.authResetPassword, body: {
      'token': token,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation
    });
  }

  Future<bool> isLoggedIn() async => (await _sessionManager.loadToken()) != null;
}

class AuthResponse {
  final User? user;
  final String? token;
  final String? message;
  AuthResponse({this.user, this.token, this.message});
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final dynamic dataNode = json['data'];
    final Map<String, dynamic> payload =
        dataNode is Map<String, dynamic> ? dataNode : json;

    final dynamic rawUser = payload['user'] ?? json['user'];
    final dynamic rawToken = payload['token'] ?? json['token'];
    final dynamic rawMessage = json['message'] ?? payload['message'];

    return AuthResponse(
      user: rawUser is Map<String, dynamic> ? User.fromJson(rawUser) : null,
      token: rawToken?.toString(),
      message: rawMessage?.toString(),
    );
  }
}
