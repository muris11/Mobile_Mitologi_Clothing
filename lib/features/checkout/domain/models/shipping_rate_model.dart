class ShippingRateModel {
  final String courier;
  final String service;
  final String description;
  final double cost;
  final String? etd;

  const ShippingRateModel({
    required this.courier,
    required this.service,
    required this.description,
    required this.cost,
    this.etd,
  });

  factory ShippingRateModel.fromJson(Map<String, dynamic> json) {
    return ShippingRateModel(
      courier: json['courier']?.toString() ?? '',
      service: json['service']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      cost: (json['cost'] is num) ? (json['cost'] as num).toDouble() : 0.0,
      etd: json['etd']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courier': courier,
      'service': service,
      'description': description,
      'cost': cost,
      'etd': etd,
    };
  }

  String get displayName => '$courier - $service';
}
