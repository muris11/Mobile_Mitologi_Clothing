import 'dart:async';

import 'package:mitologi_clothing_mobile/models/user.dart';
import 'package:mitologi_clothing_mobile/services/api_service.dart';
import 'package:mitologi_clothing_mobile/services/auth_service.dart';
import 'package:mitologi_clothing_mobile/services/cart_service.dart';

/// Fake auth service for testing
class FakeAuthService extends AuthService {
  FakeAuthService() : super(ApiService());

  bool loggedIn = false;
  User? currentUser;
  bool throwOnGetCurrentUser = false;
  bool logoutCalled = false;
  bool forgotPasswordCalled = false;
  bool resetPasswordCalled = false;

  Completer<AuthResponse>? _loginCompleter;
  Completer<AuthResponse>? _registerCompleter;

  void startLogin() {
    _loginCompleter = Completer<AuthResponse>();
  }

  void completeLogin({User? user, String? token}) {
    _loginCompleter?.complete(AuthResponse(user: user, token: token));
  }

  void startRegister() {
    _registerCompleter = Completer<AuthResponse>();
  }

  void completeRegister({User? user, String? token}) {
    _registerCompleter?.complete(AuthResponse(user: user, token: token));
  }

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
    String? cartSessionId,
  }) async {
    if (_loginCompleter != null) {
      return _loginCompleter!.future;
    }
    return AuthResponse(user: currentUser, token: 'test_token');
  }

  @override
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    if (_registerCompleter != null) {
      return _registerCompleter!.future;
    }
    return AuthResponse(user: currentUser, token: 'test_token');
  }

  @override
  Future<User?> getCurrentUser() async {
    if (throwOnGetCurrentUser) throw Exception('temporary failure');
    return currentUser;
  }

  @override
  Future<bool> isLoggedIn() async => loggedIn;

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }

  @override
  Future<void> forgotPassword(String email) async {
    forgotPasswordCalled = true;
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    resetPasswordCalled = true;
  }
}

/// Fake cart service for testing
class FakeCartService extends CartService {
  FakeCartService() : super(ApiService());

  bool mergeCalled = false;

  @override
  Future<void> mergeGuestCart(String authToken) async {
    mergeCalled = true;
  }
}
