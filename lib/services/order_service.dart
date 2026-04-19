import '../config/api_config.dart';
import '../models/checkout_result.dart';
import '../models/order.dart';
import '../models/shipping_rate.dart';
import 'api_service.dart';
import 'secure_storage_service.dart';

/// Service for order operations
class OrderService {
  final ApiService _apiService;
  String? _cachedToken;

  OrderService(this._apiService);

  Map<String, dynamic> _unwrapResponse(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) return data;
      return response;
    }
    return <String, dynamic>{};
  }

  List<dynamic> _listFromResponse(
      Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is List) return value;
      if (value is Map<String, dynamic>) {
        final nested = value['items'] ?? value['data'];
        if (nested is List) return nested;
      }
    }
    return const [];
  }

  /// Get cached token or fetch from secure storage
  Future<String?> _getToken() async {
    if (_cachedToken != null) return _cachedToken;
    _cachedToken = await SecureStorageService.getAuthToken();
    return _cachedToken;
  }

  /// Clear cached token (call on logout)
  void clearTokenCache() {
    _cachedToken = null;
  }

  /// Process checkout and create order
  Future<CheckoutResult> checkout({
    required String cartId,
    required int addressId,
    required double shippingCost,
    required String paymentMethod,
    String? notes,
    String? shippingName,
    String? shippingPhone,
    String? shippingAddress,
    String? shippingCity,
    String? shippingProvince,
    String? shippingPostalCode,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await _apiService.post(
      ApiEndpoints.checkout,
      body: {
        'cart_id': cartId,
        'address_id': addressId,
        'shipping_cost': shippingCost,
        'payment_method': paymentMethod,
        'shipping_name': shippingName ?? '',
        'shipping_phone': shippingPhone ?? '',
        'shipping_address': shippingAddress ?? '',
        'shipping_city': shippingCity ?? '',
        'shipping_province': shippingProvince ?? '',
        'shipping_postal_code': shippingPostalCode ?? '',
        if (notes != null) 'notes': notes,
      },
      requiresAuth: true,
      authToken: token,
    );

    final data = _unwrapResponse(response);
    return CheckoutResult.fromJson(data);
  }

  /// Get user orders
  Future<List<Order>> getOrders() async {
    final token = await _getToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await _apiService.get(
      ApiEndpoints.orders,
      requiresAuth: true,
      authToken: token,
    );

    final data = _unwrapResponse(response);
    final orders = _listFromResponse(data, ['orders', 'data', 'items']);
    return orders
        .whereType<Map<String, dynamic>>()
        .map((json) => Order.fromJson(json))
        .toList();
  }

  /// Get order detail
  Future<Order> getOrderDetail(String orderNumber) async {
    final token = await _getToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await _apiService.get(
      ApiEndpoints.orderDetail(orderNumber),
      requiresAuth: true,
      authToken: token,
    );

    final data = _unwrapResponse(response);
    final orderData = data['order'] is Map<String, dynamic>
        ? data['order'] as Map<String, dynamic>
        : data;
    return Order.fromJson(orderData);
  }

  /// Process payment for order (get snap token for Midtrans)
  Future<PaymentInfo> payOrder(String orderNumber) async {
    final token = await _getToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await _apiService.post(
      ApiEndpoints.orderPay(orderNumber),
      requiresAuth: true,
      authToken: token,
    );

    final data = _unwrapResponse(response);
    return PaymentInfo.fromJson(data);
  }

  /// Confirm payment with proof upload (for bank transfer)
  Future<void> confirmPayment({
    required String orderNumber,
    required String paymentProofPath,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('User not authenticated');

    await _apiService.multipartPost(
      ApiEndpoints.orderConfirmPayment(orderNumber),
      filePath: paymentProofPath,
      fileField: 'payment_proof',
      requiresAuth: true,
      authToken: token,
    );
  }

  /// Request refund
  Future<void> requestRefund({
    required String orderNumber,
    required String reason,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('User not authenticated');

    await _apiService.post(
      ApiEndpoints.orderRequestRefund(orderNumber),
      body: {'reason': reason},
      requiresAuth: true,
      authToken: token,
    );
  }

  /// Track order status
  Future<String?> trackOrder(String orderNumber) async {
    final order = await getOrderDetail(orderNumber);
    return order.status;
  }

  /// Get shipping rates for an address
  /// Returns empty list if endpoint not available (backend doesn't support)
  Future<List<ShippingRate>> getShippingRates(int addressId) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.shippingRates,
        queryParams: {'address_id': addressId.toString()},
      );

      final data = _unwrapResponse(response);
      final rates =
          _listFromResponse(data, ['rates', 'shipping_rates', 'data']);
      return rates
          .whereType<Map<String, dynamic>>()
          .map((json) => ShippingRate.fromJson(json))
          .toList();
    } catch (e) {
      // Backend doesn't support shipping rates endpoint
      return [];
    }
  }

  /// Calculate shipping cost for an address
  /// Returns flat rate if endpoint not available (backend uses flat shipping)
  Future<double> calculateShipping(int addressId) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.shippingCalculate,
        body: {'address_id': addressId},
      );

      final data = _unwrapResponse(response);
      return (data['cost'] as num?)?.toDouble() ??
          (data['shipping_cost'] as num?)?.toDouble() ??
          0.0;
    } catch (e) {
      // Backend doesn't support shipping calculation - use flat rate
      return 0.0;
    }
  }
}

/// Payment info for Midtrans
class PaymentInfo {
  final String? snapToken;
  final String? redirectUrl;
  final String? paymentUrl;

  PaymentInfo({this.snapToken, this.redirectUrl, this.paymentUrl});

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      snapToken: (json['snapToken'] ?? json['snap_token']) as String?,
      redirectUrl: (json['redirectUrl'] ??
          json['redirect_url'] ??
          json['payment_url']) as String?,
      paymentUrl: (json['paymentUrl'] ?? json['payment_url']) as String?,
    );
  }
}

/// Order status enum
enum OrderStatus {
  pending,
  processing,
  paid,
  shipped,
  delivered,
  completed,
  cancelled,
  refunded,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Menunggu Pembayaran';
      case OrderStatus.processing:
        return 'Diproses';
      case OrderStatus.paid:
        return 'Dibayar';
      case OrderStatus.shipped:
        return 'Dikirim';
      case OrderStatus.delivered:
        return 'Sampai Tujuan';
      case OrderStatus.completed:
        return 'Selesai';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
      case OrderStatus.refunded:
        return 'Dikembalikan';
    }
  }

  String get color {
    switch (this) {
      case OrderStatus.pending:
        return '#FFA500';
      case OrderStatus.processing:
        return '#FFD700';
      case OrderStatus.paid:
        return '#4CAF50';
      case OrderStatus.shipped:
        return '#2196F3';
      case OrderStatus.delivered:
        return '#9C27B0';
      case OrderStatus.completed:
        return '#4CAF50';
      case OrderStatus.cancelled:
        return '#F44336';
      case OrderStatus.refunded:
        return '#FF9800';
    }
  }
}
