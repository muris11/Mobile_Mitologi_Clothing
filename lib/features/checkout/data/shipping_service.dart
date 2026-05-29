import 'package:mitologi_clothing_mobile/core/api/api_client.dart';
import 'package:mitologi_clothing_mobile/core/constants/api_endpoints.dart';

class ShippingService {
  final ApiClient _apiClient;

  ShippingService(this._apiClient);

  Future<List<ProvinceData>> getProvinces() async {
    final response = await _apiClient.dio.get(ApiEndpoints.shippingProvinces);
    final results = response.data['data']['results'] as List;
    return results.map((e) => ProvinceData.fromJson(e)).toList();
  }

  Future<List<CityData>> getCities(int provinceId) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.shippingCities,
      queryParameters: {'province_id': provinceId},
    );
    final results = response.data['data']['results'] as List;
    return results.map((e) => CityData.fromJson(e)).toList();
  }

  Future<List<SubdistrictData>> getSubdistricts(int cityId) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.shippingSubdistricts,
      queryParameters: {'city_id': cityId},
    );
    final results = response.data['data']['results'] as List;
    return results.map((e) => SubdistrictData.fromJson(e)).toList();
  }

  Future<List<ShippingOptionData>> calculateCost({
    required int destination,
    required int weight,
    String? courier,
  }) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.shippingCost,
      data: {
        'destination': destination,
        'weight': weight,
        'courier': courier,
      },
    );
    final results = response.data['data']['results'] as List;
    return results.map((e) => ShippingOptionData.fromJson(e)).toList();
  }
}

class ProvinceData {
  final String provinceId;
  final String province;

  ProvinceData({required this.provinceId, required this.province});

  factory ProvinceData.fromJson(Map<String, dynamic> json) {
    return ProvinceData(
      provinceId: (json['province_id'] ?? json['id'] ?? json['provinceId'] ?? '').toString(),
      province: json['province'] ?? json['name'] ?? '',
    );
  }
}

class CityData {
  final String cityId;
  final String provinceId;
  final String type;
  final String cityName;
  final String postalCode;

  CityData({
    required this.cityId,
    required this.provinceId,
    required this.type,
    required this.cityName,
    required this.postalCode,
  });

  factory CityData.fromJson(Map<String, dynamic> json) {
    return CityData(
      cityId: (json['city_id'] ?? json['id'] ?? '').toString(),
      provinceId: (json['province_id'] ?? json['provinceId'] ?? '').toString(),
      type: (json['type'] ?? 'Kota').toString(),
      cityName: json['city_name'] ?? json['name'] ?? '',
      postalCode: (json['postal_code'] ?? json['postalCode'] ?? '').toString(),
    );
  }

  String get displayName => '$cityName ($type)';
}

class SubdistrictData {
  final String subdistrictId;
  final String cityId;
  final String subdistrictName;

  SubdistrictData({
    required this.subdistrictId,
    required this.cityId,
    required this.subdistrictName,
  });

  factory SubdistrictData.fromJson(Map<String, dynamic> json) {
    return SubdistrictData(
      subdistrictId: (json['subdistrict_id'] ?? json['id'] ?? '').toString(),
      cityId: (json['city_id'] ?? json['cityId'] ?? '').toString(),
      subdistrictName: json['subdistrict_name'] ?? json['name'] ?? '',
    );
  }
}

class ShippingOptionData {
  final String courier;
  final String courierName;
  final String service;
  final String description;
  final int cost;
  final String etd;
  final String note;

  ShippingOptionData({
    required this.courier,
    required this.courierName,
    required this.service,
    required this.description,
    required this.cost,
    required this.etd,
    required this.note,
  });

  factory ShippingOptionData.fromJson(Map<String, dynamic> json) {
    return ShippingOptionData(
      courier: json['courier'] ?? '',
      courierName: json['courierName'] ?? '',
      service: json['service'] ?? '',
      description: json['description'] ?? '',
      cost: json['cost'] ?? 0,
      etd: json['etd'] ?? '',
      note: json['note'] ?? '',
    );
  }

  String get formattedCost {
    final formatted = cost.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }
}
