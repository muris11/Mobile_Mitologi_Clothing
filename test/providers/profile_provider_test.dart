import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/models/address.dart';
import 'package:mitologi_clothing_mobile/models/user.dart';
import 'package:mitologi_clothing_mobile/providers/profile_provider.dart';
import 'package:mitologi_clothing_mobile/services/api_service.dart';
import 'package:mitologi_clothing_mobile/services/profile_service.dart';

class FakeProfileService extends ProfileService {
  FakeProfileService() : super(ApiService());

  User? user;
  List<Address> addresses = [];
  bool updateProfileCalled = false;
  bool addAddressCalled = false;
  bool updateAddressCalled = false;
  bool deleteAddressCalled = false;
  bool shouldThrow = false;

  @override
  Future<User> getProfile() async {
    if (shouldThrow) throw Exception('Get profile failed');
    return user ?? User.fromJson({
      'id': 1,
      'name': 'Test User',
      'email': 'test@example.com',
      'phone': '08123456789',
    });
  }

  @override
  Future<List<Address>> getAddresses() async {
    if (shouldThrow) throw Exception('Get addresses failed');
    return addresses;
  }

  @override
  Future<User> updateProfile({String? name, String? email, String? phone}) async {
    if (shouldThrow) throw Exception('Update profile failed');
    updateProfileCalled = true;
    return User.fromJson({
      'id': 1,
      'name': name ?? 'Test User',
      'email': email ?? 'test@example.com',
      'phone': phone ?? '08123456789',
    });
  }

  @override
  Future<Address> addAddress({
    required String label,
    required String recipientName,
    required String phone,
    required String address,
    required String city,
    required String postalCode,
    bool isDefault = false,
  }) async {
    if (shouldThrow) throw Exception('Add address failed');
    addAddressCalled = true;
    final newAddress = Address(
      id: addresses.length + 1,
      label: label,
      recipientName: recipientName,
      phone: phone,
      address: address,
      city: city,
      postalCode: postalCode,
      isDefault: isDefault,
    );
    addresses.add(newAddress);
    return newAddress;
  }

  @override
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
    if (shouldThrow) throw Exception('Update address failed');
    updateAddressCalled = true;
    return Address(
      id: addressId,
      label: label ?? 'Updated',
      recipientName: recipientName ?? 'Updated',
      phone: phone ?? '08123',
      address: address ?? 'Updated',
      city: city ?? 'Jakarta',
      postalCode: postalCode ?? '12345',
    );
  }

  @override
  Future<void> deleteAddress(int addressId) async {
    if (shouldThrow) throw Exception('Delete address failed');
    deleteAddressCalled = true;
    addresses.removeWhere((a) => a.id == addressId);
  }
}

void main() {
  group('ProfileProvider', () {
    test('loadProfile loads user data', () async {
      final service = FakeProfileService()
        ..user = User.fromJson({
          'id': 1,
          'name': 'John Doe',
          'email': 'john@example.com',
          'phone': '08123456789',
        });
      final provider = ProfileProvider(service);

      await provider.loadProfile();

      expect(provider.user, isNotNull);
      expect(provider.user!.name, 'John Doe');
      expect(provider.user!.email, 'john@example.com');
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('loadProfile handles error', () async {
      final service = FakeProfileService()..shouldThrow = true;
      final provider = ProfileProvider(service);

      await provider.loadProfile();

      expect(provider.user, isNull);
      expect(provider.error, isNotNull);
      expect(provider.isLoading, isFalse);
    });

    test('loadAddresses loads address list', () async {
      final service = FakeProfileService()
        ..addresses = [
          Address(
            id: 1,
            label: 'Rumah',
            recipientName: 'John',
            phone: '08123456789',
            address: 'Jl. Test 123',
            city: 'Jakarta',
            postalCode: '12345',
            isDefault: true,
          ),
        ];
      final provider = ProfileProvider(service);

      await provider.loadAddresses();

      expect(provider.addresses.length, 1);
      expect(provider.addresses.first.label, 'Rumah');
      expect(provider.addresses.first.isDefault, isTrue);
      expect(provider.isLoading, isFalse);
    });

    test('loadAddresses handles error', () async {
      final service = FakeProfileService()..shouldThrow = true;
      final provider = ProfileProvider(service);

      await provider.loadAddresses();

      expect(provider.addresses, isEmpty);
      expect(provider.error, isNotNull);
    });

    test('load loads both profile and addresses', () async {
      final service = FakeProfileService()
        ..user = User.fromJson({
          'id': 1,
          'name': 'Jane Doe',
          'email': 'jane@example.com',
        })
        ..addresses = [
          Address(
            id: 1,
            label: 'Kantor',
            recipientName: 'Jane',
            phone: '08987654321',
            address: 'Jl. Kantor 456',
            city: 'Bandung',
            postalCode: '54321',
          ),
        ];
      final provider = ProfileProvider(service);

      await provider.load();

      expect(provider.user, isNotNull);
      expect(provider.user!.name, 'Jane Doe');
      expect(provider.addresses.length, 1);
      expect(provider.addresses.first.label, 'Kantor');
    });

    test('updateProfile updates user data', () async {
      final service = FakeProfileService()
        ..user = User.fromJson({
          'id': 1,
          'name': 'Old Name',
          'email': 'old@example.com',
        });
      final provider = ProfileProvider(service);

      final result = await provider.updateProfile(
        name: 'New Name',
        email: 'new@example.com',
      );

      expect(result, isTrue);
      expect(service.updateProfileCalled, isTrue);
      expect(provider.user!.name, 'New Name');
      expect(provider.user!.email, 'new@example.com');
    });

    test('updateProfile handles error', () async {
      final service = FakeProfileService()..shouldThrow = true;
      final provider = ProfileProvider(service);

      final result = await provider.updateProfile(name: 'Test');

      expect(result, isFalse);
      expect(provider.error, isNotNull);
    });

    test('addAddress adds new address', () async {
      final service = FakeProfileService();
      final provider = ProfileProvider(service);

      final result = await provider.addAddress(
        label: 'Rumah',
        recipientName: 'John',
        phone: '08123456789',
        address: 'Jl. Baru 789',
        city: 'Surabaya',
        postalCode: '67890',
        isDefault: true,
      );

      expect(result, isTrue);
      expect(service.addAddressCalled, isTrue);
      expect(provider.addresses.length, 1);
      expect(provider.addresses.first.label, 'Rumah');
    });

    test('addAddress handles error', () async {
      final service = FakeProfileService()..shouldThrow = true;
      final provider = ProfileProvider(service);

      final result = await provider.addAddress(
        label: 'Rumah',
        recipientName: 'John',
        phone: '08123456789',
        address: 'Jl. Baru',
        city: 'Surabaya',
        postalCode: '12345',
      );

      expect(result, isFalse);
      expect(provider.error, isNotNull);
    });

    test('updateAddress updates existing address', () async {
      final service = FakeProfileService();
      final provider = ProfileProvider(service);

      final result = await provider.updateAddress(
        1,
        label: 'Updated Label',
        recipientName: 'Updated Name',
      );

      expect(result, isTrue);
      expect(service.updateAddressCalled, isTrue);
    });

    test('updateAddress handles error', () async {
      final service = FakeProfileService()..shouldThrow = true;
      final provider = ProfileProvider(service);

      final result = await provider.updateAddress(1, label: 'Test');

      expect(result, isFalse);
      expect(provider.error, isNotNull);
    });

    test('deleteAddress removes address', () async {
      final service = FakeProfileService()
        ..addresses = [
          Address(
            id: 1,
            label: 'Rumah',
            recipientName: 'John',
            phone: '08123',
            address: 'Jl. Test',
            city: 'Jakarta',
            postalCode: '12345',
          ),
        ];
      final provider = ProfileProvider(service);
      await provider.loadAddresses();

      expect(provider.addresses.length, 1);

      final result = await provider.deleteAddress(1);

      expect(result, isTrue);
      expect(service.deleteAddressCalled, isTrue);
      expect(provider.addresses.length, 0);
    });

    test('deleteAddress handles error', () async {
      final service = FakeProfileService()..shouldThrow = true;
      final provider = ProfileProvider(service);

      final result = await provider.deleteAddress(1);

      expect(result, isFalse);
      expect(provider.error, isNotNull);
    });

    test('clearError clears error state', () {
      final service = FakeProfileService();
      final provider = ProfileProvider(service);

      expect(provider.error, isNull);
      provider.clearError();
      expect(provider.error, isNull);
    });

    test('initial state is correct', () {
      final service = FakeProfileService();
      final provider = ProfileProvider(service);

      expect(provider.user, isNull);
      expect(provider.addresses, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });
  });
}
