import 'package:flutter/foundation.dart';
import '../../models/user.dart';
import '../../models/address.dart';
import '../../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._profileService);

  final ProfileService _profileService;
  User? _user;
  List<Address> _addresses = const [];
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  List<Address> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _profileService.getProfile();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAddresses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _addresses = await _profileService.getAddresses();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> load() async {
    await Future.wait([
      loadProfile(),
      loadAddresses(),
    ]);
  }

  Future<bool> updateProfile(
      {String? name, String? email, String? phone}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _profileService.updateProfile(
        name: name,
        email: email,
        phone: phone,
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

  Future<bool> addAddress({
    required String label,
    required String recipientName,
    required String phone,
    required String address,
    required String city,
    required String postalCode,
    bool isDefault = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _profileService.addAddress(
        label: label,
        recipientName: recipientName,
        phone: phone,
        address: address,
        city: city,
        postalCode: postalCode,
        isDefault: isDefault,
      );
      await loadAddresses();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAddress(
    int addressId, {
    String? label,
    String? recipientName,
    String? phone,
    String? address,
    String? city,
    String? postalCode,
    bool? isDefault,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _profileService.updateAddress(
        addressId,
        label: label,
        recipientName: recipientName,
        phone: phone,
        address: address,
        city: city,
        postalCode: postalCode,
        isDefault: isDefault,
      );
      await loadAddresses();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAddress(int addressId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _profileService.deleteAddress(addressId);
      await loadAddresses();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
