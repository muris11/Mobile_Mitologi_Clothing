import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/features/product_detail/domain/product_detail_model.dart';
import 'package:mitologi_clothing_mobile/features/product_detail/presentation/product_detail_provider.dart';

class FakeProductDetailSource implements ProductDetailDataSource {
  ProductDetailModel? detail;
  List<Map<String, dynamic>> reviews = const [];
  List<Map<String, dynamic>> related = const [];
  Exception? error;

  @override
  Future<ProductDetailModel> fetchDetail(String handle) async {
    if (error != null) throw error!;
    return detail!;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchRelated(int productId) async => related;

  @override
  Future<List<Map<String, dynamic>>> fetchReviews(String handle) async => reviews;
}

void main() {
  group('ProductDetailProvider', () {
    test('loads detail reviews and related products', () async {
      final source = FakeProductDetailSource()
        ..detail = const ProductDetailModel(
          id: 1,
          handle: 'hoodie-1',
          title: 'Hoodie',
          priceAmount: 150000,
          primaryImageUrl: 'img',
        )
        ..reviews = const [
          {'id': 1, 'comment': 'Bagus'}
        ]
        ..related = const [
          {'id': 2, 'title': 'Jacket'}
        ];
      final provider = ProductDetailProvider(source);

      await provider.load('hoodie-1');

      expect(provider.detail?.handle, 'hoodie-1');
      expect(provider.reviews.length, 1);
      expect(provider.related.length, 1);
      expect(provider.error, isNull);
    });

    test('exposes error state when detail load fails', () async {
      final source = FakeProductDetailSource()..error = Exception('boom');
      final provider = ProductDetailProvider(source);

      await provider.load('hoodie-1');

      expect(provider.error, contains('boom'));
      expect(provider.detail, isNull);
    });
  });
}
