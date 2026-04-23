import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/services/wishlist_service.dart';
import 'package:mitologi_clothing_mobile/services/api_service.dart';
import '../mocks/mock_api_client.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_binding.dart';

void main() {
  setUpAll(() {
    initializeTestBinding();
    mockSecureStorageChannel();
  });

  group('WishlistService Tests', () {
    late MockApiClient mockClient;
    late ApiService apiService;
    late WishlistService wishlistService;

    setUp(() {
      // Reset storage to authenticated state
      resetToAuthenticatedState();
      mockClient = MockApiClient();
      apiService = ApiService(client: mockClient.client);
      wishlistService = WishlistService(apiService);
    });

    tearDown(() {
      mockClient.clear();
    });

    group('getWishlist', () {
      test('returns wishlist products', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/wishlist',
          {'wishlist': TestHelpers.sampleProducts},
        );

        // Act
        final result = await wishlistService.getWishlist();

        // Assert
        expect(result, isA<List>());
        expect(result.length, 2);
        expect(result.first.handle, 'test-product');
      });

      test('returns empty list when wishlist is empty', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/wishlist',
          {'wishlist': []},
        );

        // Act
        final result = await wishlistService.getWishlist();

        // Assert
        expect(result, isEmpty);
      });

      test('returns empty list when not authenticated', () async {
        // Arrange
        resetToUnauthenticatedState();

        // Act
        final result = await wishlistService.getWishlist();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('addToWishlist', () {
      test('adds product to wishlist successfully', () async {
        // Arrange
        mockClient.setResponse(
          'POST',
          'https://adminmitologiclothing.center.biz.id/api/v1/wishlist/1',
          {'message': 'Added to wishlist'},
        );

        // Act & Assert - should not throw
        await expectLater(
          wishlistService.addToWishlist(1),
          completes,
        );
      });

      test('returns false when not authenticated', () async {
        // Arrange
        resetToUnauthenticatedState();

        // Act
        final result = await wishlistService.addToWishlist(1);

        // Assert
        expect(result, false);
      });

      test('returns false for non-existent product', () async {
        // Arrange
        mockClient.setResponse(
          'POST',
          'https://adminmitologiclothing.center.biz.id/api/v1/wishlist/999',
          {'message': 'Product not found'},
          statusCode: 404,
        );

        // Act
        final result = await wishlistService.addToWishlist(999);

        // Assert - service returns false instead of throwing on API errors
        expect(result, false);
      });
    });

    group('removeFromWishlist', () {
      test('removes product from wishlist', () async {
        // Arrange
        mockClient.setResponse(
          'DELETE',
          'https://adminmitologiclothing.center.biz.id/api/v1/wishlist/1',
          {'message': 'Removed from wishlist'},
        );

        // Act & Assert - should not throw
        await expectLater(
          wishlistService.removeFromWishlist(1),
          completes,
        );
      });

      test('returns false for non-existent wishlist item', () async {
        // Arrange
        mockClient.setResponse(
          'DELETE',
          'https://adminmitologiclothing.center.biz.id/api/v1/wishlist/999',
          {'message': 'Item not found in wishlist'},
          statusCode: 404,
        );

        // Act
        final result = await wishlistService.removeFromWishlist(999);

        // Assert
        expect(result, false);
      });
    });

    group('isInWishlist', () {
      test('returns true when product is in wishlist', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/wishlist/check/1',
          {'inWishlist': true},
        );

        // Act
        final result = await wishlistService.isInWishlist(1);

        // Assert
        expect(result, true);
      });

      test('returns false when product is not in wishlist', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/wishlist/check/2',
          {'inWishlist': false},
        );

        // Act
        final result = await wishlistService.isInWishlist(2);

        // Assert
        expect(result, false);
      });

      test('returns false when not authenticated', () async {
        // Arrange
        resetToUnauthenticatedState();

        // Act
        final result = await wishlistService.isInWishlist(1);

        // Assert
        expect(result, false);
      });

      test('returns false on API error', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/wishlist/check/1',
          {'message': 'Server error'},
          statusCode: 500,
        );

        // Act
        final result = await wishlistService.isInWishlist(1);

        // Assert
        expect(result, false);
      });
    });

    group('toggleWishlist', () {
      test('adds product when not in wishlist', () async {
        // Arrange - first check returns false, then add succeeds
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/wishlist/check/1',
          {'inWishlist': false},
        );
        mockClient.setResponse(
          'POST',
          'https://adminmitologiclothing.center.biz.id/api/v1/wishlist/1',
          {'message': 'Added'},
        );

        // Act
        final result = await wishlistService.toggleWishlist(1);

        // Assert
        expect(result, true);
      });

      test('removes product when in wishlist', () async {
        // Arrange - first check returns true, then remove succeeds
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/wishlist/check/1',
          {'inWishlist': true},
        );
        mockClient.setResponse(
          'DELETE',
          'https://adminmitologiclothing.center.biz.id/api/v1/wishlist/1',
          {'message': 'Removed'},
        );

        // Act
        final result = await wishlistService.toggleWishlist(1);

        // Assert
        expect(result, false);
      });
    });

    group('getWishlistCount', () {
      test('returns correct count', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/wishlist',
          {'wishlist': TestHelpers.sampleProducts},
        );

        // Act
        final result = await wishlistService.getWishlistCount();

        // Assert
        expect(result, 2);
      });

      test('returns 0 for empty wishlist', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/wishlist',
          {'wishlist': []},
        );

        // Act
        final result = await wishlistService.getWishlistCount();

        // Assert
        expect(result, 0);
      });
    });
  });
}
