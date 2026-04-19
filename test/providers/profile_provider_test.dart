import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/models/address.dart';
import 'package:mitologi_clothing_mobile/models/user.dart';
import 'package:mitologi_clothing_mobile/providers/profile_provider.dart';
import 'package:mitologi_clothing_mobile/services/api_service.dart';
import 'package:mitologi_clothing_mobile/services/profile_service.dart';

class FakeProfileService extends ProfileService {
  FakeProfileService() : super(ApiService());

  User? profile;
  List<Address> addresses = [];
  bool addCalled = false;
  bool updateCalled = false;
  bool deleteCalled = false;

  @override
  Future<List<Address>> getAddresses() async => addresses;

  @override
  Future<User> getProfile() async => profile!;

  @override
  Future<Address> addAddress({required String label, required String recipientName, required String phone, required String address, required String city, required String postalCode, bool isDefault = false}) async {
    addCalled = true;
    return Address.fromJson({
      'id': 2,
      'label': label,
      'recipient_name': recipientName,
      'phone': phone,
      'address': address,
      'city': city,
      'postal_code': postalCode,
      'is_default': isDefault,
    });
  }

  @override
  Future<Address> updateAddress(int addressId, {String? label, String? recipientName, String? phone, String? address, String? city, String? postalCode, bool? isDefault}) async {
    updateCalled = true;
    return Address.fromJson({
      'id': addressId,
      'label': label ?? 'Rumah',
      'recipient_name': recipientName ?? 'Rifqy',
      'phone': phone ?? '08123',
      'address': address ?? 'Jl. Mitologi',
      'city': city ?? 'Bandung',
      'postal_code': postalCode ?? '40123',
      'is_default': isDefault ?? false,
    });
  }

  @override
  Future<void> deleteAddress(int addressId) async {
    deleteCalled = true;
  }
}

void main() {
  group('ProfileProvider', () {
    test('loads profile and addresses', () async {
      final service = FakeProfileService()
        ..profile = User(id: 1, name: 'Rifqy', email: 'rifqy@example.com')
        ..addresses = [
          Address.fromJson({
            'id': 1,
            'label': 'Rumah',
            'recipient_name': 'Rifqy',
            'phone': '08123',
            'address': 'Jl. Mitologi',
            'city': 'Bandung',
            'postal_code': '40123',
            'is_default': true,
          })
        ];
      final provider = ProfileProvider(service);

      await provider.load();

      expect(provider.user?.id, 1);
      expect(provider.addresses.length, 1);
      expect(provider.error, isNull);
    });
  });
}
