import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/core/config/shop_config.dart';
import 'package:mitologi_clothing_mobile/features/checkout/data/checkout_repository.dart';
import 'package:mitologi_clothing_mobile/features/checkout/domain/models/address_model.dart';
import 'package:mitologi_clothing_mobile/features/checkout/domain/models/order_model.dart';

enum PlaceOrderResult {
  success,
  mockSuccess,
  paymentRequired,
  error,
}

class CheckoutViewModel extends ChangeNotifier {
  final CheckoutRepository _checkoutRepository;

  CheckoutViewModel(this._checkoutRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<AddressModel> _addresses = [];
  List<AddressModel> get addresses => _addresses;

  AddressModel? _selectedAddress;
  AddressModel? get selectedAddress => _selectedAddress;

  String? _selectedShippingMethod;
  String? get selectedShippingMethod => _selectedShippingMethod;

  String? _lastOrderNumber;
  String? get lastOrderNumber => _lastOrderNumber;

  String? _snapToken;
  String? get snapToken => _snapToken;

  String? _error;
  String? get error => _error;

  void selectAddress(AddressModel address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void selectShippingMethod(String method) {
    _selectedShippingMethod = method;
    notifyListeners();
  }

  Future<void> fetchAddresses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _addresses = await _checkoutRepository.getAddresses();
      if (_addresses.isNotEmpty && _selectedAddress == null) {
        _selectedAddress = _addresses.firstWhere((a) => a.isDefault,
            orElse: () => _addresses.first);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PlaceOrderResult> placeOrder() async {
    if (_selectedAddress == null) {
      _error = 'Pilih alamat pengiriman terlebih dahulu';
      notifyListeners();
      return PlaceOrderResult.error;
    }

    _isLoading = true;
    _error = null;
    _snapToken = null;
    notifyListeners();

    try {
      final shippingData = _selectedAddress!.toCheckoutJson();
      final result = await _checkoutRepository.placeOrder(
        shippingAddress: shippingData,
      );

      _snapToken = result['snapToken'] as String?;
      _lastOrderNumber = result['orderNumber'] as String? ?? '';
      final isMock = result['mock'] == true || _snapToken == 'MOCK_SNAP_TOKEN';

      if (isMock) {
        return PlaceOrderResult.mockSuccess;
      }

      if (_snapToken != null && _snapToken!.isNotEmpty) {
        return PlaceOrderResult.paymentRequired;
      }

      return PlaceOrderResult.success;
    } catch (e) {
      _error = e.toString();
      return PlaceOrderResult.error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PlaceOrderResult> payOrder(String orderNumber) async {
    _isLoading = true;
    _error = null;
    _snapToken = null;
    notifyListeners();

    try {
      final result = await _checkoutRepository.payOrder(orderNumber);

      _snapToken = result['snapToken'] as String?;
      _lastOrderNumber = result['orderNumber'] as String? ?? '';
      final isMock = result['mock'] == true || _snapToken == 'MOCK_SNAP_TOKEN';

      if (isMock) {
        return PlaceOrderResult.mockSuccess;
      }

      if (_snapToken != null && _snapToken!.isNotEmpty) {
        return PlaceOrderResult.paymentRequired;
      }

      return PlaceOrderResult.success;
    } catch (e) {
      _error = e.toString();
      return PlaceOrderResult.error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String get paymentUrl {
    if (_snapToken == null || _snapToken!.isEmpty) return '';
    return ShopConfig.buildMidtransSnapUrl(_snapToken!);
  }

  Future<OrderModel?> getOrderDetail(String orderNumber) async {
    try {
      return await _checkoutRepository.getOrderDetail(orderNumber);
    } catch (e) {
      return null;
    }
  }

  Future<bool> requestRefund(String orderNumber, String reason) async {
    try {
      await _checkoutRepository.requestRefund(orderNumber, reason);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> addAddress(AddressModel address) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _checkoutRepository.addAddress(address);
      await fetchAddresses();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAddress(AddressModel address) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _checkoutRepository.updateAddress(address);
      await fetchAddresses();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
