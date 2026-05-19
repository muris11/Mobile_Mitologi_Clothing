import 'package:equatable/equatable.dart';
import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';

class AddressModel extends Equatable {
  final int id;
  final String label;
  final String recipientName;
  final String phone;
  final String address;
  final String city;
  final String province;
  final String postalCode;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.address,
    required this.city,
    required this.province,
    required this.postalCode,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: ParserUtils.parseInt(json['id']),
      label: json['label'] as String? ?? '',
      recipientName: json['recipientName'] as String? ??
          json['recipient_name'] as String? ??
          '',
      phone: json['phone'] as String? ?? '',
      address: json['addressLine1'] as String? ??
          json['address_line_1'] as String? ??
          json['address'] as String? ??
          '',
      city: json['city'] as String? ?? '',
      province: json['province'] as String? ?? '',
      postalCode: json['postalCode'] as String? ??
          json['postal_code'] as String? ??
          '',
      isDefault: ParserUtils.parseBool(
        json['isPrimary'] ?? json['is_default'] ?? false,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'recipient_name': recipientName,
        'phone': phone,
        'address_line_1': address,
        'address_line_2': null,
        'city': city,
        'province': province,
        'postal_code': postalCode,
        'is_default': isDefault,
        'country': 'Indonesia',
      };

  Map<String, dynamic> toCheckoutJson() => {
        'label': label,
        'recipientName': recipientName,
        'phone': phone,
        'addressLine1': address,
        'city': city,
        'province': province,
        'postalCode': postalCode,
        'isPrimary': isDefault,
      };

  String get fullAddress => '$address, $city, $province $postalCode';

  @override
  List<Object?> get props => [
        id,
        label,
        recipientName,
        phone,
        address,
        city,
        province,
        postalCode,
        isDefault,
      ];
}
