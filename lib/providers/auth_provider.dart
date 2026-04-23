import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../utils/error_mapper.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final CartService _cartService;
  User? _user;
  bool _isLoading = false;
  String? _error;
  VoidCallback? _onLogout;

  AuthProvider(this._authService, this._cartService, {VoidCallback? onLogout})
      : _onLogout = onLogout;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<void> initialize() async {
    _setLoading(true);
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      final currentUser = _user;
      if (isLoggedIn) {
        final fetchedUser = await _authService.getCurrentUser();
        // Keep existing in-memory user if fetch fails during concurrent auth flows.
        _user = fetchedUser ?? currentUser;
      } else if (currentUser == null) {
        _user = null;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _clearError();

    try {
      final response =
          await _authService.login(email: email, password: password);

      final hasValidAuth =
          response.user != null && (response.token?.isNotEmpty ?? false);
      if (!hasValidAuth) {
        final message =
            response.message ?? 'Login gagal: data autentikasi tidak lengkap.';
        _setError(message);
        return false;
      }

      _user = response.user;

      // Merge guest cart with authenticated cart (run in background)
      // Don't await to prevent blocking navigation - secure storage is slow
      if (response.token != null) {
        unawaited(_cartService.mergeGuestCart(response.token!));
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError(ErrorMapper.mapAuthError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(
      {required String name,
      required String email,
      required String password,
      required String passwordConfirmation,
      String? phone}) async {
    _setLoading(true);
    _clearError();
    try {
      final response = await _authService.register(
          name: name,
          email: email,
          password: password,
          passwordConfirmation: passwordConfirmation,
          phone: phone);

      final hasValidAuth =
          response.user != null && (response.token?.isNotEmpty ?? false);
      if (!hasValidAuth) {
        final message =
            response.message ?? 'Registrasi gagal: data autentikasi tidak lengkap.';
        _setError(message);
        return false;
      }

      _user = response.user;

      // Merge guest cart with authenticated cart (run in background)
      if (response.token != null) {
        unawaited(_cartService.mergeGuestCart(response.token!));
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError(ErrorMapper.mapAuthError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    await _authService.logout();
    _user = null;
    _onLogout?.call(); // Clear token caches
    _setLoading(false);
  }

  /// Set callback for clearing service token caches on logout
  void setOnLogoutCallback(VoidCallback callback) {
    _onLogout = callback;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
