class CheckoutResult {
  final int orderId;
  final String orderNumber;
  final String snapToken;
  final double total;
  final bool isMock;

  const CheckoutResult({
    required this.orderId,
    required this.orderNumber,
    required this.snapToken,
    required this.total,
    this.isMock = false,
  });

  factory CheckoutResult.fromJson(Map<String, dynamic> json) {
    return CheckoutResult(
      orderId: json['orderId'] as int? ?? 0,
      orderNumber: json['orderNumber'] as String? ?? '',
      snapToken: json['snapToken'] as String? ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      isMock: json['mock'] == true || json['snapToken'] == 'MOCK_SNAP_TOKEN',
    );
  }
}
