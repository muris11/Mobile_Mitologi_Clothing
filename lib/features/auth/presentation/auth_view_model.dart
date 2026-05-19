import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/core/utils/error_mapper.dart';
import 'package:mitologi_clothing_mobile/features/auth/data/auth_repository.dart';
import 'package:mitologi_clothing_mobile/features/auth/domain/models/user.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  User? get user => _authRepository.currentUser;
  bool get isAuthenticated => user != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authRepository.login(email, password);
      return true;
    } catch (e) {
      _setError(ErrorMapper.mapAuthError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authRepository.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
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
    try {
      await _authRepository.logout();
    } catch (e) {
      _setError(ErrorMapper.mapAuthError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> checkAuthStatus() async {
    _setLoading(true);
    try {
      await _authRepository.getCurrentUser();
    } catch (_) {
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authRepository.forgotPassword(email);
      return true;
    } catch (e) {
      _setError(ErrorMapper.mapAuthError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword({
    required String token,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authRepository.resetPassword(
        token: token,
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      _setError(ErrorMapper.mapAuthError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
