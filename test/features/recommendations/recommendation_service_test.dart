import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/features/recommendations/data/recommendation_service.dart';
import 'package:mitologi_clothing_mobile/features/recommendations/domain/interaction_event.dart';

void main() {
  group('InteractionEvent', () {
    test('serializes batch payload', () {
      const event = InteractionEvent(
        type: 'product_view',
        productId: 10,
        source: 'pdp',
      );

      expect(event.toJson(), {
        'type': 'product_view',
        'product_id': 10,
        'source': 'pdp',
      });
    });
  });

  group('RecommendationService', () {
    test('exposes non blocking fallback helper', () {
      final service = RecommendationService();

      expect(service.shouldFailOpenOnRecommendationError, isTrue);
    });
  });
}
