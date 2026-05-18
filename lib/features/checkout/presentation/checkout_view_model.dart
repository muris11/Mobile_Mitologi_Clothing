import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/features/checkout/data/checkout_repository.dart';
import 'package:mitologi_clothing_mobile/features/checkout/domain/models/address_model.dart';
import 'package:mitologi_clothing_mobile/features/checkout/domain/models/order_model.dart';

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

  OrderModel? _lastOrder;
  OrderModel? get lastOrder => _lastOrder;
  String? get lastOrderNumber => _lastOrder?.orderNumber;

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

  Future<bool> placeOrder() async {
    if (_selectedAddress == null || _selectedShippingMethod == null) {
      _error = 'Please select address and shipping method';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _lastOrder = await _checkoutRepository.placeOrder(
        addressId: _selectedAddress!.id,
        shippingMethod: _selectedShippingMethod!,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
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
