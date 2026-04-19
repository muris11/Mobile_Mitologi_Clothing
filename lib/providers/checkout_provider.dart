import 'package:flutter/foundation.dart';
import '../../models/address.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../services/profile_service.dart';
import '../../providers/cart_provider.dart';
import '../../config/shop_config.dart';

class CheckoutProvider extends ChangeNotifier {
  CheckoutProvider(
      this._cartProvider, this._profileService, this._orderService);

  final CartProvider _cartProvider;
  final ProfileService _profileService;
  final OrderService _orderService;

  List<Address> _addresses = const [];
  Address? _selectedAddress;
  String _paymentMethod = ShopConfig.defaultPaymentMethod;
  String _notes = '';
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  Order? _createdOrder;
  double _shippingCost = 0.0;
  bool _isLoadingShipping = false;

  List<Address> get addresses => _addresses;
  Address? get selectedAddress => _selectedAddress;
  String get paymentMethod => _paymentMethod;
  String get notes => _notes;
  double get shippingCost => _shippingCost;
  bool get isLoading => _isLoading || _isLoadingShipping;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  Order? get createdOrder => _createdOrder;

  double get subtotal {
    final cart = _cartProvider.cart;
    if (cart == null) return 0;
    final subtotalMoney = cart.subtotal;
    return subtotalMoney?.amount ?? 0;
  }

  double get total => subtotal + shippingCost;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _cartProvider.ensureInitialized();
      _addresses = await _profileService.getAddresses();
      _selectedAddress = _addresses.where((a) => a.isDefault).isNotEmpty
          ? _addresses.firstWhere((a) => a.isDefault)
          : (_addresses.isNotEmpty ? _addresses.first : null);

      if (_selectedAddress != null && _selectedAddress!.id != null) {
        await _loadShippingCost(_selectedAddress!.id!);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadShippingCost(int addressId) async {
    _isLoadingShipping = true;
    notifyListeners();
    try {
      final cost = await _orderService.calculateShipping(addressId);
      // Use flat rate if API returns 0 or fails (backend uses free/flat shipping)
      _shippingCost = cost > 0 ? cost : ShopConfig.flatShippingCost;
    } catch (e) {
      _shippingCost = ShopConfig.flatShippingCost;
    } finally {
      _isLoadingShipping = false;
      notifyListeners();
    }
  }

  Future<void> recalculateShipping() async {
    if (_selectedAddress != null && _selectedAddress!.id != null) {
      await _loadShippingCost(_selectedAddress!.id!);
    }
  }

  void selectAddress(Address address) {
    _selectedAddress = address;
    if (address.id != null) {
      _loadShippingCost(address.id!);
    } else {
      notifyListeners();
    }
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void setNotes(String notes) {
    _notes = notes;
    notifyListeners();
  }

  Future<bool> submitOrder() async {
    if (_selectedAddress == null) {
      _error = 'Pilih alamat pengiriman';
      notifyListeners();
      return false;
    }

    final addressId = _selectedAddress!.id;
    if (addressId == null) {
      _error = 'Alamat tidak valid';
      notifyListeners();
      return false;
    }

    final cart = _cartProvider.cart;
    if (cart == null || cart.id.isEmpty) {
      _error = 'Keranjang kosong';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final address = _selectedAddress!;
      final result = await _orderService.checkout(
        cartId: cart.id,
        addressId: addressId,
        shippingCost: shippingCost,
        paymentMethod: _paymentMethod,
        notes: _notes.isNotEmpty ? _notes : null,
        shippingName: address.recipientName,
        shippingPhone: address.phone,
        shippingAddress: address.formattedAddress,
        shippingCity: address.city,
        shippingProvince: address.province ?? address.city,
        shippingPostalCode: address.postalCode,
      );

      // Store order number for later retrieval
      if (result.orderNumber.isNotEmpty) {
        _createdOrder = await _orderService.getOrderDetail(result.orderNumber);
      }

      await _cartProvider.clearCart();

      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _addresses = [];
    _selectedAddress = null;
    _paymentMethod = ShopConfig.defaultPaymentMethod;
    _notes = '';
    _error = null;
    _createdOrder = null;
    notifyListeners();
  }
}
