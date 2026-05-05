import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/features/auth/domain/models/user.dart';
import 'package:mitologi_clothing_mobile/features/checkout/domain/models/order_model.dart';
import 'package:mitologi_clothing_mobile/features/profile/data/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _profileRepository;

  ProfileViewModel(this._profileRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? _user;
  User? get user => _user;

  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  String? _error;
  String? get error => _error;

  Future<void> fetchProfileData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _profileRepository.getProfile(),
        _profileRepository.getOrders(),
      ]);

      _user = results[0] as User;
      _orders = results[1] as List<OrderModel>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
