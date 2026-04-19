/// Shipping rate model for dynamic shipping costs
class ShippingRate {
  final double cost;
  final String method;
  final String? estimatedDays;
  final bool available;

  ShippingRate({
    required this.cost,
    required this.method,
    this.estimatedDays,
    this.available = true,
  });

  factory ShippingRate.fromJson(Map<String, dynamic> json) {
    return ShippingRate(
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      method: json['method'] as String? ?? 'Standard',
      estimatedDays: json['estimated_days'] as String?,
      available: json['available'] as bool? ?? true,
    );
  }

  String get formattedCost {
    final symbol = 'Rp';
    final formattedAmount = cost.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return '$symbol $formattedAmount';
  }
}
