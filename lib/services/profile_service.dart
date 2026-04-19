import '../config/api_config.dart';
import '../models/address.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'secure_storage_service.dart';

/// Service for profile operations
class ProfileService {
  final ApiService _apiService;

  ProfileService(this._apiService);

  Map<String, dynamic> _unwrapResponse(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) return data;
      return response;
    }
    return <String, dynamic>{};
  }

  List<dynamic> _listFromResponse(
      Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is List) return value;
      if (value is Map<String, dynamic>) {
        final nested = value['items'] ?? value['data'];
        if (nested is List) return nested;
      }
    }
    return const [];
  }

  /// Get user profile
  Future<User> getProfile() async {
    final token = await SecureStorageService.getAuthToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await _apiService.get(
      ApiEndpoints.profile,
      requiresAuth: true,
      authToken: token,
    );

    final data = _unwrapResponse(response);
    final userData = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : data;
    final user = User.fromJson(userData);
    await SecureStorageService.setUserData(user.toJsonString());
    return user;
  }

  /// Update user profile
  Future<User> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    final token = await SecureStorageService.getAuthToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await _apiService.put(
      ApiEndpoints.profile,
      body: {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      },
      requiresAuth: true,
      authToken: token,
    );

    final data = _unwrapResponse(response);
    final userData = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : data;
    final user = User.fromJson(userData);
    await SecureStorageService.setUserData(user.toJsonString());
    return user;
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final token = await SecureStorageService.getAuthToken();
    if (token == null) throw Exception('User not authenticated');

    await _apiService.put(
      ApiEndpoints.profilePassword,
      body: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': confirmPassword,
      },
      requiresAuth: true,
      authToken: token,
    );
  }

  /// Update avatar
  Future<void> updateAvatar(String imagePath) async {
    final token = await SecureStorageService.getAuthToken();
    if (token == null) throw Exception('User not authenticated');

    await _apiService.multipartPost(
      ApiEndpoints.profileAvatar,
      filePath: imagePath,
      fileField: 'avatar',
      requiresAuth: true,
      authToken: token,
    );
  }

  /// Get all addresses
  Future<List<Address>> getAddresses() async {
    final token = await SecureStorageService.getAuthToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await _apiService.get(
      ApiEndpoints.addresses,
      requiresAuth: true,
      authToken: token,
    );

    final data = _unwrapResponse(response);
    final addresses = _listFromResponse(data, ['addresses', 'items']);
    return addresses
        .whereType<Map<String, dynamic>>()
        .map(Address.fromJson)
        .toList();
  }

  /// Add new address
  Future<Address> addAddress({
    required String label,
    required String recipientName,
    required String phone,
    required String address,
    required String city,
    required String postalCode,
    bool isDefault = false,
  }) async {
    final token = await SecureStorageService.getAuthToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await _apiService.post(
      ApiEndpoints.addresses,
      body: {
        'label': label,
        'recipient_name': recipientName,
        'phone': phone,
        'address_line_1': address,
        'city': city,
        'province': city,
        'postal_code': postalCode,
        'is_primary': isDefault,
      },
      requiresAuth: true,
      authToken: token,
    );

    final data = _unwrapResponse(response);
    final addressData = data['address'] is Map<String, dynamic>
        ? data['address'] as Map<String, dynamic>
        : data;
    return Address.fromJson(addressData);
  }

  /// Update address
  Future<Address> updateAddress(
    int addressId, {
    String? label,
    String? recipientName,
    String? phone,
    String? address,
    String? city,
    String? postalCode,
    bool? isDefault,
  }) async {
    final token = await SecureStorageService.getAuthToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await _apiService.put(
      ApiEndpoints.address(addressId),
      body: {
        if (label != null) 'label': label,
        if (recipientName != null) 'recipient_name': recipientName,
        if (phone != null) 'phone': phone,
        if (address != null) 'address_line_1': address,
        if (city != null) 'city': city,
        if (postalCode != null) 'postal_code': postalCode,
        if (isDefault != null) 'is_primary': isDefault,
      },
      requiresAuth: true,
      authToken: token,
    );

    final data = _unwrapResponse(response);
    final addressData = data['address'] is Map<String, dynamic>
        ? data['address'] as Map<String, dynamic>
        : data;
    return Address.fromJson(addressData);
  }

  /// Delete address
  Future<void> deleteAddress(int addressId) async {
    final token = await SecureStorageService.getAuthToken();
    if (token == null) throw Exception('User not authenticated');

    await _apiService.delete(
      ApiEndpoints.address(addressId),
      requiresAuth: true,
      authToken: token,
    );
  }

  /// Get default address
  Future<Address?> getDefaultAddress() async {
    final addresses = await getAddresses();
    try {
      return addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }
}
