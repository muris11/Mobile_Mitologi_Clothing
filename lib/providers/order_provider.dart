import 'package:flutter/foundation.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider(this._orderService);

  final OrderService _orderService;
  List<Order> _orders = const [];
  Order? _selectedOrder;
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _orders = await _orderService.getOrders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOrderDetail(String orderNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _selectedOrder = await _orderService.getOrderDetail(orderNumber);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PaymentInfo?> payOrder(String orderNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final paymentInfo = await _orderService.payOrder(orderNumber);
      _isLoading = false;
      notifyListeners();
      return paymentInfo;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> confirmPayment({
    required String orderNumber,
    required String paymentProofPath,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _orderService.confirmPayment(
        orderNumber: orderNumber,
        paymentProofPath: paymentProofPath,
      );
      await loadOrderDetail(orderNumber);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> requestRefund({
    required String orderNumber,
    required String reason,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _orderService.requestRefund(
        orderNumber: orderNumber,
        reason: reason,
      );
      await loadOrderDetail(orderNumber);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearSelectedOrder() {
    _selectedOrder = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
