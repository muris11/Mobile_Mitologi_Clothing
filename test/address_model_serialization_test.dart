import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/features/checkout/domain/models/address_model.dart';

void main() {
  test('AddressModel serializes saved address payload for backend', () {
    const address = AddressModel(
      id: 0,
      label: 'Rumah',
      recipientName: 'Budi Santoso',
      phone: '08123456789',
      address: 'Jl. Mitologi No. 1',
      city: 'Indramayu',
      province: 'Jawa Barat',
      postalCode: '45271',
      isDefault: true,
    );

    final json = address.toJson();

    expect(json['address_line_1'], 'Jl. Mitologi No. 1');
    expect(json.containsKey('address'), isFalse);
    expect(json['recipient_name'], 'Budi Santoso');
    expect(json['postal_code'], '45271');
    expect(json['is_default'], isTrue);
  });
}
