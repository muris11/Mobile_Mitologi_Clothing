import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/catalog_query.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/paginated_products.dart';
import 'package:mitologi_clothing_mobile/features/catalog/presentation/catalog_provider.dart';
import 'package:mitologi_clothing_mobile/models/product.dart';
import 'package:mitologi_clothing_mobile/models/money.dart';

class FakeCatalogProviderSource implements CatalogDataSource {
  PaginatedProducts? nextResult;
  Exception? nextError;

  @override
  Future<PaginatedProducts> fetchProducts(CatalogQuery query) async {
    if (nextError != null) throw nextError!;
    return nextResult!;
  }
}

void main() {
  group('CatalogQuery', () {
    test('serializes supported search and filter params', () {
      const query = CatalogQuery(
        search: 'hoodie',
        category: 'outerwear',
        sortKey: 'price',
        reverse: true,
        page: 2,
        limit: 24,
      );

      final params = query.toQueryParameters();

      expect(params['q'], 'hoodie');
      expect(params['category'], 'outerwear');
      expect(params['sortKey'], 'price');
      expect(params['reverse'], 'true');
      expect(params['page'], '2');
      expect(params['limit'], '24');
    });
  });

  group('CatalogProvider', () {
    test('loads initial result successfully', () async {
      final source = FakeCatalogProviderSource()
        ..nextResult = PaginatedProducts(
          products: [
            Product(
              id: 1,
              handle: 'hoodie-1',
              title: 'Hoodie 1',
              price: Money(amount: 150000),
            ),
          ],
          total: 1,
          perPage: 24,
          currentPage: 1,
          lastPage: 1,
        );
      final provider = CatalogProvider(source);

      await provider.load(const CatalogQuery(search: 'hoodie'));

      expect(provider.products.length, 1);
      expect(provider.error, isNull);
      expect(provider.isLoading, isFalse);
      expect(provider.isLoadingMore, isFalse);
    });

    test('distinguishes empty result from error', () async {
      final source = FakeCatalogProviderSource()
        ..nextResult = PaginatedProducts.empty();
      final provider = CatalogProvider(source);

      await provider.load(const CatalogQuery(search: 'missing'));

      expect(provider.products, isEmpty);
      expect(provider.error, isNull);
    });

    test('exposes error on fetch failure', () async {
      final source = FakeCatalogProviderSource()..nextError = Exception('boom');
      final provider = CatalogProvider(source);

      await provider.load(const CatalogQuery(search: 'hoodie'));

      expect(provider.error, contains('boom'));
      expect(provider.isLoading, isFalse);
    });
  });
}
