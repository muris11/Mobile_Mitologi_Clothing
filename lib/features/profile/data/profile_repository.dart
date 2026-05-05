import 'package:mitologi_clothing_mobile/features/auth/domain/models/user.dart';
import 'package:mitologi_clothing_mobile/features/checkout/domain/models/order_model.dart';

import 'profile_service.dart';

class ProfileRepository {
  final ProfileService _profileService;

  ProfileRepository(this._profileService);

  Future<User> getProfile() async {
    final response = await _profileService.getProfile();
    return User.fromJson(response.data['data']);
  }

  Future<List<OrderModel>> getOrders() async {
    final response = await _profileService.getOrders();
    final List data = response.data['data'] ?? [];
    return data.map((e) => OrderModel.fromJson(e)).toList();
  }

  Future<OrderModel> getOrderDetail(String orderNumber) async {
    final response = await _profileService.getOrderDetail(orderNumber);
    final data = response.data['data'] ?? response.data;
    return OrderModel.fromJson(data as Map<String, dynamic>);
  }
}
