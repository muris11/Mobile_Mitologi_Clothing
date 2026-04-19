import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/models/address.dart';

void main() {
  group('Address Tests', () {
    test('creates Address with required fields', () {
      final address = Address(
        recipientName: 'John Doe',
        phone: '08123456789',
        address: 'Jl. Test No. 123',
        city: 'Jakarta',
        postalCode: '12345',
      );

      expect(address.recipientName, 'John Doe');
      expect(address.phone, '08123456789');
      expect(address.address, 'Jl. Test No. 123');
      expect(address.city, 'Jakarta');
      expect(address.postalCode, '12345');
      expect(address.country, 'Indonesia'); // default
      expect(address.isDefault, false); // default
    });

    test('creates Address with all fields', () {
      final address = Address(
        id: 1,
        label: 'Home',
        recipientName: 'John Doe',
        phone: '08123456789',
        address: 'Jl. Test No. 123',
        address2: 'Apt 456',
        city: 'Jakarta',
        province: 'DKI Jakarta',
        postalCode: '12345',
        country: 'Indonesia',
        isDefault: true,
      );

      expect(address.id, 1);
      expect(address.label, 'Home');
      expect(address.address2, 'Apt 456');
      expect(address.province, 'DKI Jakarta');
      expect(address.isDefault, true);
    });

    group('fromJson Tests', () {
      test('parses complete JSON with snake_case keys', () {
        final json = {
          'id': 1,
          'label': 'Home',
          'recipient_name': 'John Doe',
          'phone': '08123456789',
          'address': 'Jl. Test No. 123',
          'address2': 'Apt 456',
          'city': 'Jakarta',
          'province': 'DKI Jakarta',
          'postal_code': '12345',
          'country': 'Indonesia',
          'is_primary':
              true, // Note: Address model checks for is_primary, not is_default
        };

        final address = Address.fromJson(json);

        expect(address.id, 1);
        expect(address.label, 'Home');
        expect(address.recipientName, 'John Doe');
        expect(address.phone, '08123456789');
        expect(address.address, 'Jl. Test No. 123');
        expect(address.address2, 'Apt 456');
        expect(address.city, 'Jakarta');
        expect(address.province, 'DKI Jakarta');
        expect(address.postalCode, '12345');
        expect(address.country, 'Indonesia');
        expect(address.isDefault, true);
      });

      test('parses JSON with camelCase keys', () {
        final json = {
          'id': 2,
          'recipientName': 'Jane Doe',
          'addressLine1': 'Jl. Sudirman No. 1',
          'addressLine2': 'Floor 10',
          'city': 'Jakarta',
          'postalCode': '54321',
          'isPrimary': true,
        };

        final address = Address.fromJson(json);

        expect(address.recipientName, 'Jane Doe');
        expect(address.address, 'Jl. Sudirman No. 1');
        expect(address.address2, 'Floor 10');
        expect(address.isDefault, true);
      });

      test('parses JSON with various address key formats', () {
        // Test 'address_line_1' key
        final json1 = {
          'recipient_name': 'Test',
          'phone': '08123456789',
          'address_line_1': 'Jl. Thamrin No. 1',
          'city': 'Jakarta',
          'postal_code': '12345',
        };
        final address1 = Address.fromJson(json1);
        expect(address1.address, 'Jl. Thamrin No. 1');

        // Test 'street' key
        final json2 = {
          'recipient_name': 'Test',
          'phone': '08123456789',
          'street': 'Jl. Gatot Subroto',
          'city': 'Jakarta',
          'postal_code': '12345',
        };
        final address2 = Address.fromJson(json2);
        expect(address2.address, 'Jl. Gatot Subroto');

        // Test 'address1' key
        final json3 = {
          'recipient_name': 'Test',
          'phone': '08123456789',
          'address1': 'Jl. Rasuna Said',
          'city': 'Jakarta',
          'postal_code': '12345',
        };
        final address3 = Address.fromJson(json3);
        expect(address3.address, 'Jl. Rasuna Said');
      });

      test('parses JSON with various province key formats', () {
        // Test 'state' key
        final json1 = {
          'recipient_name': 'Test',
          'phone': '08123456789',
          'address': 'Jl. Test',
          'city': 'Jakarta',
          'state': 'DKI Jakarta',
          'postal_code': '12345',
        };
        final address1 = Address.fromJson(json1);
        expect(address1.province, 'DKI Jakarta');

        // Test 'region' key
        final json2 = {
          'recipient_name': 'Test',
          'phone': '08123456789',
          'address': 'Jl. Test',
          'city': 'Bandung',
          'region': 'Jawa Barat',
          'postal_code': '12345',
        };
        final address2 = Address.fromJson(json2);
        expect(address2.province, 'Jawa Barat');
      });

      test('parses JSON with various postal code key formats', () {
        // Test 'zip' key
        final json1 = {
          'recipient_name': 'Test',
          'phone': '08123456789',
          'address': 'Jl. Test',
          'city': 'Jakarta',
          'zip': '54321',
        };
        final address1 = Address.fromJson(json1);
        expect(address1.postalCode, '54321');

        // Test 'postal' key
        final json2 = {
          'recipient_name': 'Test',
          'phone': '08123456789',
          'address': 'Jl. Test',
          'city': 'Jakarta',
          'postal': '98765',
        };
        final address2 = Address.fromJson(json2);
        expect(address2.postalCode, '98765');
      });

      test('parses JSON with various isDefault key formats', () {
        // Test 'isPrimary' key
        final json1 = {
          'recipient_name': 'Test',
          'phone': '08123456789',
          'address': 'Jl. Test',
          'city': 'Jakarta',
          'postal_code': '12345',
          'isPrimary': true,
        };
        final address1 = Address.fromJson(json1);
        expect(address1.isDefault, true);

        // Test 'is_primary' key
        final json2 = {
          'recipient_name': 'Test',
          'phone': '08123456789',
          'address': 'Jl. Test',
          'city': 'Jakarta',
          'postal_code': '12345',
          'is_primary': true,
        };
        final address2 = Address.fromJson(json2);
        expect(address2.isDefault, true);
      });

      test('handles empty JSON with defaults', () {
        final json = <String, dynamic>{};

        final address = Address.fromJson(json);

        expect(address.recipientName, '');
        expect(address.phone, '');
        expect(address.address, '');
        expect(address.city, '');
        expect(address.postalCode, '');
        expect(address.country, 'Indonesia');
        expect(address.isDefault, false);
      });

      test('handles null values in JSON', () {
        final json = {
          'id': null,
          'label': null,
          'recipient_name': null,
          'phone': null,
          'address': null,
          'address2': null,
          'city': null,
          'province': null,
          'postal_code': null,
          'country': null,
          'is_default': null,
        };

        final address = Address.fromJson(json);

        expect(address.id, null);
        expect(address.label, null);
        expect(address.recipientName, '');
        expect(address.phone, '');
        expect(address.address, '');
        expect(address.address2, null);
        expect(address.city, '');
        expect(address.province, null);
        expect(address.postalCode, '');
        expect(address.country, 'Indonesia');
        expect(address.isDefault, false);
      });
    });

    group('toJson Tests', () {
      test('converts to JSON correctly', () {
        final address = Address(
          id: 1,
          label: 'Home',
          recipientName: 'John Doe',
          phone: '08123456789',
          address: 'Jl. Test No. 123',
          address2: 'Apt 456',
          city: 'Jakarta',
          province: 'DKI Jakarta',
          postalCode: '12345',
          country: 'Indonesia',
          isDefault: true,
        );

        final json = address.toJson();

        expect(json['id'], 1);
        expect(json['label'], 'Home');
        expect(json['recipient_name'], 'John Doe');
        expect(json['phone'], '08123456789');
        expect(json['address'], 'Jl. Test No. 123');
        expect(json['address2'], 'Apt 456');
        expect(json['city'], 'Jakarta');
        expect(json['province'], 'DKI Jakarta');
        expect(json['postal_code'], '12345');
        expect(json['country'], 'Indonesia');
        expect(json['is_default'], true);
      });

      test('converts Address with null values to JSON', () {
        final address = Address(
          recipientName: 'Test',
          phone: '08123456789',
          address: 'Jl. Test',
          city: 'Jakarta',
          postalCode: '12345',
        );

        final json = address.toJson();

        expect(json['id'], null);
        expect(json['label'], null);
        expect(json['address2'], null);
        expect(json['province'], null);
      });
    });

    group('formattedAddress Tests', () {
      test('formats complete address', () {
        final address = Address(
          recipientName: 'John Doe',
          phone: '08123456789',
          address: 'Jl. Test No. 123',
          address2: 'Apt 456',
          city: 'Jakarta',
          province: 'DKI Jakarta',
          postalCode: '12345',
          country: 'Indonesia',
        );

        expect(
          address.formattedAddress,
          'Jl. Test No. 123, Apt 456, Jakarta, DKI Jakarta, 12345, Indonesia',
        );
      });

      test('formats address without optional fields', () {
        final address = Address(
          recipientName: 'John Doe',
          phone: '08123456789',
          address: 'Jl. Test No. 123',
          city: 'Jakarta',
          postalCode: '12345',
        );

        expect(
          address.formattedAddress,
          'Jl. Test No. 123, Jakarta, 12345, Indonesia',
        );
      });

      test('formats address with empty address2 correctly', () {
        final address = Address(
          recipientName: 'John Doe',
          phone: '08123456789',
          address: 'Jl. Test No. 123',
          address2: '',
          city: 'Jakarta',
          postalCode: '12345',
        );

        expect(
          address.formattedAddress,
          'Jl. Test No. 123, Jakarta, 12345, Indonesia',
        );
      });

      test('handles null optional fields in formattedAddress', () {
        final address = Address(
          recipientName: 'John Doe',
          phone: '08123456789',
          address: 'Jl. Test',
          city: 'Jakarta',
          province: null,
          postalCode: '12345',
          country: null,
        );

        expect(
          address.formattedAddress,
          'Jl. Test, Jakarta, 12345',
        );
      });
    });

    group('shortAddress Tests', () {
      test('returns city and postal code', () {
        final address = Address(
          recipientName: 'John Doe',
          phone: '08123456789',
          address: 'Jl. Test',
          city: 'Jakarta',
          postalCode: '12345',
        );

        expect(address.shortAddress, 'Jakarta, 12345');
      });
    });

    group('copyWith Tests', () {
      test('copies with updated values', () {
        final original = Address(
          id: 1,
          label: 'Home',
          recipientName: 'John Doe',
          phone: '08123456789',
          address: 'Jl. Test No. 123',
          city: 'Jakarta',
          postalCode: '12345',
        );

        final updated = original.copyWith(
          recipientName: 'Jane Doe',
          phone: '08987654321',
          isDefault: true,
        );

        expect(updated.id, 1); // unchanged
        expect(updated.label, 'Home'); // unchanged
        expect(updated.recipientName, 'Jane Doe'); // updated
        expect(updated.phone, '08987654321'); // updated
        expect(updated.address, 'Jl. Test No. 123'); // unchanged
        expect(updated.city, 'Jakarta'); // unchanged
        expect(updated.postalCode, '12345'); // unchanged
        expect(updated.isDefault, true); // updated
      });

      test('copies without changes when no arguments', () {
        final original = Address(
          id: 1,
          recipientName: 'John Doe',
          phone: '08123456789',
          address: 'Jl. Test',
          city: 'Jakarta',
          postalCode: '12345',
        );

        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.recipientName, original.recipientName);
        expect(copy.phone, original.phone);
        expect(copy.address, original.address);
        expect(copy.city, original.city);
        expect(copy.postalCode, original.postalCode);
        expect(copy.isDefault, original.isDefault);
      });

      // Note: copyWith uses ?? operator which means null values fall back to original
      // This is standard Dart pattern - to set a field to null, you'd need a sentinel value
    });
  });
}
