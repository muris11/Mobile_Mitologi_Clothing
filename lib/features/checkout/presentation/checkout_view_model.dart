import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/core/api/api_client.dart';
import 'package:mitologi_clothing_mobile/core/config/shop_config.dart';
import 'package:mitologi_clothing_mobile/core/utils/error_mapper.dart';
import 'package:mitologi_clothing_mobile/features/checkout/data/checkout_repository.dart';
import 'package:mitologi_clothing_mobile/features/checkout/data/shipping_service.dart';
import 'package:mitologi_clothing_mobile/features/checkout/domain/models/address_model.dart';
import 'package:mitologi_clothing_mobile/features/checkout/domain/models/order_model.dart';

enum PlaceOrderResult {
  success,
  mockSuccess,
  paymentRequired,
  error,
}

enum ShippingMethod { pickup, delivery }

class CheckoutViewModel extends ChangeNotifier {
  final CheckoutRepository _checkoutRepository;
  late final ShippingService _shippingService;
  ShippingService get shippingService => _shippingService;

  CheckoutViewModel(this._checkoutRepository, ApiClient apiClient) {
    _shippingService = ShippingService(apiClient);
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<AddressModel> _addresses = [];
  List<AddressModel> get addresses => _addresses;

  AddressModel? _selectedAddress;
  AddressModel? get selectedAddress => _selectedAddress;

  ShippingMethod _shippingMethod = ShippingMethod.delivery;
  ShippingMethod get shippingMethod => _shippingMethod;

  ShippingOptionData? _selectedShippingOption;
  ShippingOptionData? get selectedShippingOption => _selectedShippingOption;

  List<ShippingOptionData> _shippingOptions = [];
  List<ShippingOptionData> get shippingOptions => _shippingOptions;

  String? _lastOrderNumber;
  String? get lastOrderNumber => _lastOrderNumber;

  String? _snapToken;
  String? get snapToken => _snapToken;

  String? _error;
  String? get error => _error;

  int get shippingCost => _selectedShippingOption?.cost ?? 0;

  void selectAddress(AddressModel address) {
    _selectedAddress = address;
    if (_shippingMethod == ShippingMethod.delivery) {
      calculateShipping();
    }
    notifyListeners();
  }

  void setShippingMethod(ShippingMethod method) {
    _shippingMethod = method;
    if (method == ShippingMethod.delivery && _selectedAddress != null) {
      calculateShipping();
    } else {
      _selectedShippingOption = null;
      _shippingOptions = [];
    }
    notifyListeners();
  }

  void selectShippingOption(ShippingOptionData option) {
    _selectedShippingOption = option;
    notifyListeners();
  }

  Future<void> calculateShipping() async {
    if (_selectedAddress == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final resolvedCityId = await _resolveCityId();
      if (resolvedCityId == null) {
        _error = 'ID kota tidak valid';
        return;
      }

      const totalWeight = 1000;
      final options = await _shippingService.calculateCost(
        destination: resolvedCityId,
        weight: totalWeight,
      );

      _shippingOptions = options;
      if (options.isNotEmpty) {
        _selectedShippingOption = options.first;
      }
    } catch (e) {
      _error = 'Gagal menghitung ongkir: ${e.toString()}';
      _shippingOptions = [];
      _selectedShippingOption = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int?> _resolveCityId() async {
    final address = _selectedAddress!;

    final directId = int.tryParse(address.cityId);
    if (directId != null) return directId;

    final provinces = await _shippingService.getProvinces();
    final addressProvinceNorm = address.province.toLowerCase();
    final matchedProvince = provinces.firstWhere(
      (p) {
        final nameNorm = p.province.toLowerCase();
        return nameNorm == addressProvinceNorm ||
            nameNorm.contains(addressProvinceNorm) ||
            addressProvinceNorm.contains(nameNorm);
      },
      orElse: () => ProvinceData(provinceId: '', province: ''),
    );
    if (matchedProvince.provinceId.isEmpty) return null;

    final provId = int.tryParse(matchedProvince.provinceId);
    if (provId == null) return null;

    final cities = await _shippingService.getCities(provId);
    final addressCityNorm = address.city
        .toLowerCase()
        .replaceAll(RegExp(r'^(kabupaten|kab\.|kota)\s+'), '')
        .trim();
    final matchedCity = cities.firstWhere(
      (c) {
        final cleanName = c.cityName
            .toLowerCase()
            .replaceAll(RegExp(r'^(kabupaten|kab\.|kota)\s+'), '')
            .trim();
        return cleanName == addressCityNorm ||
            cleanName.contains(addressCityNorm) ||
            addressCityNorm.contains(cleanName);
      },
      orElse: () => CityData(
        cityId: '', provinceId: '', type: '', cityName: '', postalCode: '',
      ),
    );
    if (matchedCity.cityId.isEmpty) return null;

    return int.tryParse(matchedCity.cityId);
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
        if (_shippingMethod == ShippingMethod.delivery) {
          await calculateShipping();
        }
      }
    } catch (e) {
      _error = ErrorMapper.mapCheckoutError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PlaceOrderResult> placeOrder() async {
    if (_shippingMethod == ShippingMethod.delivery && _selectedAddress == null) {
      _error = 'Pilih alamat pengiriman terlebih dahulu';
      notifyListeners();
      return PlaceOrderResult.error;
    }

    if (_shippingMethod == ShippingMethod.delivery && _selectedShippingOption == null) {
      _error = 'Pilih metode pengiriman';
      notifyListeners();
      return PlaceOrderResult.error;
    }

    _isLoading = true;
    _error = null;
    _snapToken = null;
    notifyListeners();

    try {
      final Map<String, dynamic> payload = {
        'shippingMethod': _shippingMethod == ShippingMethod.pickup ? 'pickup' : 'delivery',
        'shippingCost': shippingCost,
      };

      if (_shippingMethod == ShippingMethod.delivery && _selectedAddress != null) {
        payload.addAll(_selectedAddress!.toCheckoutJson());
        if (_selectedShippingOption != null) {
          payload['shippingCourier'] = _selectedShippingOption!.courier;
          payload['shippingService'] = _selectedShippingOption!.service;
        }
      }

      final result = await _checkoutRepository.placeOrder(
        shippingAddress: payload,
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
      _error = ErrorMapper.mapCheckoutError(e);
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
      _error = ErrorMapper.mapCheckoutError(e);
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
      _error = ErrorMapper.mapCheckoutError(e);
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
      _error = ErrorMapper.mapCheckoutError(e);
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
      _error = ErrorMapper.mapCheckoutError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
