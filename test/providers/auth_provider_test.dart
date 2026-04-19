import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/models/user.dart';
import 'package:mitologi_clothing_mobile/providers/auth_provider.dart';
import 'package:mitologi_clothing_mobile/services/api_service.dart';
import 'package:mitologi_clothing_mobile/services/auth_service.dart';
import 'package:mitologi_clothing_mobile/services/cart_service.dart';

class FakeAuthService extends AuthService {
  FakeAuthService() : super(ApiService());

  bool loggedIn = false;
  User? currentUser;
  bool throwOnGetCurrentUser = false;
  bool logoutCalled = false;

  @override
  Future<User?> getCurrentUser() async {
    if (throwOnGetCurrentUser) {
      throw Exception('temporary failure');
    }
    return currentUser;
  }

  @override
  Future<bool> isLoggedIn() async => loggedIn;

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }
}

class FakeCartService extends CartService {
  FakeCartService() : super(ApiService());

  bool mergeCalled = false;

  @override
  Future<void> mergeGuestCart(String authToken) async {
    mergeCalled = true;
  }
}

void main() {
  group('AuthProvider', () {
    test('initialize keeps user null when not logged in', () async {
      final authService = FakeAuthService()..loggedIn = false;
      final provider = AuthProvider(authService, FakeCartService());

      await provider.initialize();

      expect(provider.user, isNull);
      expect(provider.isAuthenticated, isFalse);
      expect(provider.isLoading, isFalse);
    });

    test('initialize restores user when token exists and fetch succeeds', () async {
      final authService = FakeAuthService()
        ..loggedIn = true
        ..currentUser = User(id: 1, name: 'Rifqy', email: 'rifqy@example.com');
      final provider = AuthProvider(authService, FakeCartService());

      await provider.initialize();

      expect(provider.user?.id, 1);
      expect(provider.isAuthenticated, isTrue);
      expect(provider.isLoading, isFalse);
    });

    test('logout clears user and invokes callback', () async {
      final authService = FakeAuthService()
        ..loggedIn = true
        ..currentUser = User(id: 1, name: 'Rifqy', email: 'rifqy@example.com');
      final provider = AuthProvider(authService, FakeCartService());
      var logoutCallbackCalled = false;
      provider.setOnLogoutCallback(() {
        logoutCallbackCalled = true;
      });

      await provider.initialize();
      await provider.logout();

      expect(authService.logoutCalled, isTrue);
      expect(provider.user, isNull);
      expect(provider.isAuthenticated, isFalse);
      expect(logoutCallbackCalled, isTrue);
      expect(provider.isLoading, isFalse);
    });
  });
}
