import 'package:equatable/equatable.dart';
import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';

class AddressModel extends Equatable {
  final int id;
  final String label;
  final String recipientName;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String cityId;
  final String province;
  final String provinceId;
  final String? subdistrict;
  final String? subdistrictId;
  final String postalCode;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    this.cityId = '',
    required this.province,
    this.provinceId = '',
    this.subdistrict,
    this.subdistrictId,
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
      addressLine1: json['addressLine1'] as String? ??
          json['address_line_1'] as String? ??
          json['address'] as String? ??
          '',
      addressLine2: json['addressLine2'] as String? ??
          json['address_line_2'] as String?,
      city: json['city'] as String? ?? '',
      cityId: json['cityId'] as String? ??
          json['city_id'] as String? ??
          '',
      province: json['province'] as String? ?? '',
      provinceId: json['provinceId'] as String? ??
          json['province_id'] as String? ??
          '',
      subdistrict: json['subdistrict'] as String? ??
          json['subdistrict_name'] as String?,
      subdistrictId: json['subdistrictId'] as String? ??
          json['subdistrict_id'] as String?,
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
        'recipientName': recipientName,
        'phone': phone,
        'addressLine1': addressLine1,
        if (addressLine2 != null && addressLine2!.isNotEmpty) 'addressLine2': addressLine2,
        'cityId': cityId,
        'provinceId': provinceId,
        if (subdistrictId != null && subdistrictId!.isNotEmpty) 'subdistrictId': subdistrictId,
        'city': city,
        'province': province,
        if (subdistrict != null && subdistrict!.isNotEmpty) 'subdistrict': subdistrict,
        'postalCode': postalCode,
        'isPrimary': isDefault,
        'country': 'Indonesia',
      };

  Map<String, dynamic> toCheckoutJson() => {
        'label': label,
        'recipientName': recipientName,
        'phone': phone,
        'addressLine1': addressLine1,
        if (addressLine2 != null && addressLine2!.isNotEmpty) 'addressLine2': addressLine2,
        'city': city,
        'cityId': cityId,
        'province': province,
        'provinceId': provinceId,
        if (subdistrict != null && subdistrict!.isNotEmpty) 'subdistrict': subdistrict,
        if (subdistrictId != null && subdistrictId!.isNotEmpty) 'subdistrictId': subdistrictId,
        'postalCode': postalCode,
        'isPrimary': isDefault,
        'country': 'Indonesia',
      };

  String get fullAddress {
    final parts = [addressLine1];
    if (addressLine2 != null && addressLine2!.isNotEmpty) {
      parts.add(addressLine2!);
    }
    if (subdistrict != null && subdistrict!.isNotEmpty) {
      parts.add(subdistrict!);
    }
    parts.add(city);
    parts.add(province);
    parts.add(postalCode);
    return parts.where((p) => p.isNotEmpty).join(', ');
  }

  @override
  List<Object?> get props => [
        id,
        label,
        recipientName,
        phone,
        addressLine1,
        addressLine2,
        city,
        cityId,
        province,
        provinceId,
        subdistrict,
        subdistrictId,
        postalCode,
        isDefault,
      ];
}
