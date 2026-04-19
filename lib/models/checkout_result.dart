/// Checkout result model
class CheckoutResult {
  final String orderNumber;
  final String? snapToken;
  final String? redirectUrl;
  final String? orderId;
  final double? total;
  final String? status;

  CheckoutResult({
    required this.orderNumber,
    this.snapToken,
    this.redirectUrl,
    this.orderId,
    this.total,
    this.status,
  });

  factory CheckoutResult.fromJson(Map<String, dynamic> json) {
    final orderData = json['order'] ?? json;

    double? parseTotal(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is Map<String, dynamic>) {
        if (value['amount'] is num) return (value['amount'] as num).toDouble();
      }
      return null;
    }

    return CheckoutResult(
      orderNumber: orderData['order_number'] ??
          orderData['orderNumber'] as String? ??
          json['order_number'] ??
          '',
      snapToken: orderData['snapToken'] ??
          orderData['snap_token'] as String? ??
          json['snapToken'] ??
          json['snap_token'] as String?,
      redirectUrl: orderData['redirectUrl'] ??
          orderData['redirect_url'] ??
          orderData['payment_url'] as String? ??
          json['redirectUrl'] ??
          json['redirect_url'] ??
          json['payment_url'] as String?,
      orderId: orderData['order_id']?.toString() ?? orderData['id']?.toString(),
      total: parseTotal(orderData['total']) ?? parseTotal(json['total']),
      status: orderData['status'] as String? ??
          json['status'] as String? ??
          'pending',
    );
  }

  bool get useMidtrans => snapToken != null && snapToken!.isNotEmpty;

  bool get useRedirect => redirectUrl != null && redirectUrl!.isNotEmpty;
}
