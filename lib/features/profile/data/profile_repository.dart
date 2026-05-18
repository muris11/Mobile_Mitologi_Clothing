import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';
import 'package:mitologi_clothing_mobile/features/auth/domain/models/user.dart';
import 'package:mitologi_clothing_mobile/features/checkout/domain/models/order_model.dart';

import 'profile_service.dart';

class ProfileRepository {
  final ProfileService _profileService;

  ProfileRepository(this._profileService);

  Future<User> getProfile() async {
    final response = await _profileService.getProfile();
    return User.fromJson(ParserUtils.parseMap(response.data['data']));
  }

  Future<List<OrderModel>> getOrders() async {
    final response = await _profileService.getOrders();
    final List data = response.data['data'] ?? [];
    return data.map((e) => OrderModel.fromJson(ParserUtils.parseMap(e))).toList();
  }

  Future<OrderModel> getOrderDetail(String orderNumber) async {
    final response = await _profileService.getOrderDetail(orderNumber);
    final data = response.data['data'] ?? response.data;
    return OrderModel.fromJson(ParserUtils.parseMap(data));
  }
  Future<void> updateAvatar(String imagePath) async {
    await _profileService.updateAvatar(imagePath);
  }

  Future<void> updateProfile({required String name, required String phone}) async {
    await _profileService.updateProfile({
      'name': name,
      'phone': phone,
    });
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _profileService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
