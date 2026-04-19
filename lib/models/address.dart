/// Address model
class Address {
  final int? id;
  final String? label;
  final String recipientName;
  final String phone;
  final String address;
  final String? address2;
  final String city;
  final String? province;
  final String postalCode;
  final String? country;
  final bool isDefault;

  Address({
    this.id,
    this.label,
    required this.recipientName,
    required this.phone,
    required this.address,
    this.address2,
    required this.city,
    this.province,
    required this.postalCode,
    this.country = 'Indonesia',
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as int?,
      label: json['label'] as String?,
      recipientName:
          json['recipientName'] ?? json['recipient_name'] ?? json['name'] ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['addressLine1'] ??
          json['address_line_1'] ??
          json['address'] ??
          json['address1'] ??
          json['street'] ??
          '',
      address2:
          json['addressLine2'] ?? json['address_line_2'] ?? json['address2'],
      city: json['city'] as String? ?? '',
      province: json['province'] ?? json['state'] ?? json['region'] as String?,
      postalCode: json['postalCode'] ??
          json['postal_code'] ??
          json['zip'] ??
          json['postal'] ??
          '',
      country: json['country'] as String? ?? 'Indonesia',
      isDefault:
          json['isPrimary'] ?? json['is_primary'] ?? json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'recipient_name': recipientName,
      'phone': phone,
      'address': address,
      'address2': address2,
      'city': city,
      'province': province,
      'postal_code': postalCode,
      'country': country,
      'is_default': isDefault,
    };
  }

  /// Get formatted address string
  String get formattedAddress {
    final parts = [
      address,
      if (address2 != null && address2!.isNotEmpty) address2,
      city,
      if (province != null && province!.isNotEmpty) province,
      postalCode,
      if (country != null && country!.isNotEmpty) country,
    ];
    return parts.where((p) => p != null && p.isNotEmpty).join(', ');
  }

  /// Get short address for display
  String get shortAddress => '$city, $postalCode';

  Address copyWith({
    int? id,
    String? label,
    String? recipientName,
    String? phone,
    String? address,
    String? address2,
    String? city,
    String? province,
    String? postalCode,
    String? country,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      recipientName: recipientName ?? this.recipientName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      address2: address2 ?? this.address2,
      city: city ?? this.city,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
