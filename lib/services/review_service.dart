import 'api_service.dart';
import '../config/api_config.dart';
import 'secure_storage_service.dart';

/// Service for product review operations
class ReviewService {
  final ApiService _apiService;

  ReviewService(this._apiService);

  /// Submit product review
  Future<void> submitReview({
    required String productHandle,
    required int rating,
    required String comment,
  }) async {
    final token = await SecureStorageService.getAuthToken();
    if (token == null) throw Exception('User not authenticated');

    await _apiService.post(
      ApiEndpoints.addReview(productHandle),
      body: {
        'rating': rating,
        'comment': comment,
      },
      requiresAuth: true,
      authToken: token,
    );
  }

  /// Update existing review
  Future<void> updateReview({
    required int reviewId,
    int? rating,
    String? comment,
  }) async {
    final token = await SecureStorageService.getAuthToken();
    if (token == null) throw Exception('User not authenticated');

    final body = <String, dynamic>{};
    if (rating != null) body['rating'] = rating;
    if (comment != null) body['comment'] = comment;

    await _apiService.put(
      ApiEndpoints.updateReview(reviewId),
      body: body,
      requiresAuth: true,
      authToken: token,
    );
  }

  /// Delete review
  Future<void> deleteReview(int reviewId) async {
    final token = await SecureStorageService.getAuthToken();
    if (token == null) throw Exception('User not authenticated');

    await _apiService.delete(
      ApiEndpoints.deleteReview(reviewId),
      requiresAuth: true,
      authToken: token,
    );
  }
}
