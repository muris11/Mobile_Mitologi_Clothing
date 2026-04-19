import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/core/session/auth_session_manager.dart';

class InMemoryTokenStore implements AuthTokenStore {
  String? token;
  String? userData;

  @override
  Future<void> clear() async {
    token = null;
    userData = null;
  }

  @override
  Future<String?> readToken() async => token;

  @override
  Future<String?> readUserData() async => userData;

  @override
  Future<void> writeToken(String value) async {
    token = value;
  }

  @override
  Future<void> writeUserData(String value) async {
    userData = value;
  }
}

void main() {
  group('AuthSessionManager', () {
    test('saves and loads auth token', () async {
      final store = InMemoryTokenStore();
      final manager = AuthSessionManager(store);

      await manager.saveToken('abc123');

      expect(await manager.loadToken(), 'abc123');
    });

    test('saves and loads user data', () async {
      final store = InMemoryTokenStore();
      final manager = AuthSessionManager(store);

      await manager.saveUserData('{"id":1}');

      expect(await manager.loadUserData(), '{"id":1}');
    });

    test('clears auth session', () async {
      final store = InMemoryTokenStore()
        ..token = 'abc123'
        ..userData = '{"id":1}';
      final manager = AuthSessionManager(store);

      await manager.clear();

      expect(await manager.loadToken(), isNull);
      expect(await manager.loadUserData(), isNull);
    });
  });
}
