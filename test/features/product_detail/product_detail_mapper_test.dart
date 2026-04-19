import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/features/product_detail/data/product_detail_mapper.dart';

void main() {
  group('ProductDetailMapper', () {
    test('maps image and direct price fields', () {
      final product = ProductDetailMapper.map({
        'id': 1,
        'handle': 'hoodie-1',
        'title': 'Hoodie',
        'price': 150000,
        'images': [
          {'url': 'https://example.com/hoodie.jpg'}
        ],
      });

      expect(product.id, 1);
      expect(product.handle, 'hoodie-1');
      expect(product.title, 'Hoodie');
      expect(product.priceAmount, 150000);
      expect(product.primaryImageUrl, 'https://example.com/hoodie.jpg');
    });

    test('falls back to priceRange and alternate image keys', () {
      final product = ProductDetailMapper.map({
        'id': 2,
        'handle': 'jacket-1',
        'name': 'Jacket',
        'priceRange': {
          'minVariantPrice': {'amount': 250000}
        },
        'featuredImage': {'image_url': 'https://example.com/jacket.jpg'},
      });

      expect(product.title, 'Jacket');
      expect(product.priceAmount, 250000);
      expect(product.primaryImageUrl, 'https://example.com/jacket.jpg');
    });
  });
}
