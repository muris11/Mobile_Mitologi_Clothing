import 'package:mitologi_clothing_mobile/core/storage/token_storage.dart';
import 'package:mitologi_clothing_mobile/features/auth/domain/models/user.dart';
import 'auth_service.dart';

class AuthRepository {
  final AuthService _authService;
  final TokenStorage _tokenStorage;
  User? _currentUser;

  AuthRepository(this._authService, this._tokenStorage);

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<User> login(String email, String password) async {
    final response = await _authService.login(email, password);
    final data = response.data['data'];
    final token = data['token'];
    final userData = data['user'];

    await _tokenStorage.saveToken(token);
    _currentUser = User.fromJson(userData);
    return _currentUser!;
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final response = await _authService.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
    );
    final data = response.data['data'];
    final token = data['token'];
    final userData = data['user'];

    await _tokenStorage.saveToken(token);
    _currentUser = User.fromJson(userData);
    return _currentUser!;
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } finally {
      await _tokenStorage.deleteToken();
      _currentUser = null;
    }
  }

  Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    
    final hasToken = await _tokenStorage.hasToken();
    if (!hasToken) return null;

    try {
      final response = await _authService.getUser();
      _currentUser = User.fromJson(response.data['data']);
      return _currentUser;
    } catch (e) {
      await _tokenStorage.deleteToken();
      return null;
    }
  }

  Future<String> forgotPassword(String email) async {
    final response = await _authService.forgotPassword(email);
    return response.data['message'] ?? 'Check your email for reset instructions';
  }

  Future<String> resetPassword({
    required String token,
    required String email,
    required String password,
  }) async {
    final response = await _authService.resetPassword(
      token: token,
      email: email,
      password: password,
    );
    return response.data['message'] ?? 'Password has been reset successfully';
  }
}
