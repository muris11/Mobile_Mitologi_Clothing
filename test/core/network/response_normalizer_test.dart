import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/core/network/response_normalizer.dart';

void main() {
  group('ResponseNormalizer.normalize', () {
    test('unwraps data envelope and camelizes nested keys', () {
      final normalized = ResponseNormalizer.normalize({
        'data': {
          'hero_slides': [
            {
              'image_url': 'https://example.com/hero.jpg',
              'cta_text': 'Belanja',
            },
          ],
        },
      });

      expect(normalized, isA<Map<String, dynamic>>());
      expect(normalized['heroSlides'], isA<List<dynamic>>());
      expect(normalized['heroSlides'][0]['imageUrl'], 'https://example.com/hero.jpg');
      expect(normalized['heroSlides'][0]['ctaText'], 'Belanja');
    });

    test('unwraps data envelope for list payloads', () {
      final normalized = ResponseNormalizer.normalize({
        'data': [
          {'item_id': 1},
          {'item_id': 2},
        ],
      });

      expect(normalized, isA<List<dynamic>>());
      expect(normalized[0]['itemId'], 1);
      expect(normalized[1]['itemId'], 2);
    });

    test('preserves plain object if data field absent', () {
      final normalized = ResponseNormalizer.normalize({
        'message': 'ok',
        'current_page': 2,
      });

      expect(normalized['message'], 'ok');
      expect(normalized['currentPage'], 2);
    });

    test('preserves nested arrays and maps recursively', () {
      final normalized = ResponseNormalizer.normalize({
        'data': {
          'price_range': {
            'min_variant_price': {'amount_value': 150000},
          },
        },
      });

      expect(normalized['priceRange']['minVariantPrice']['amountValue'], 150000);
    });
  });
}
