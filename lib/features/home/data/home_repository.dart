import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:mitologi_clothing_mobile/features/home/data/home_service.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/home_data_model.dart';

class HomeRepository {
  final HomeService _homeService;

  HomeRepository(this._homeService);

  Future<HomeDataModel> getHomeData() async {
    log('HomeRepository: calling getLandingPage...', name: 'HOME');
    final response = await _homeService.getLandingPage();
    log('HomeRepository: status=${response.statusCode} dataType=${response.data?.runtimeType}',
        name: 'HOME');
    if (response.statusCode == 200 && response.data != null) {
      try {
        final model =
            HomeDataModel.fromJson(response.data as Map<String, dynamic>);
        log('HomeRepository: parsed OK — banners=${model.banners.length} categories=${model.categories.length}',
            name: 'HOME');
        return model;
      } catch (e, st) {
        log('HomeRepository: fromJson FAILED: $e',
            name: 'HOME', error: e, stackTrace: st);
        rethrow;
      }
    }
    log('HomeRepository: bad response status=${response.statusCode}',
        name: 'HOME');
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
    );
  }
}
