import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mitologi_clothing_mobile/models/product.dart';
import 'package:mitologi_clothing_mobile/screens/wishlist/wishlist_screen.dart';
import 'package:mitologi_clothing_mobile/services/api_service.dart';
import 'package:mitologi_clothing_mobile/services/secure_storage_service.dart';
import 'package:mitologi_clothing_mobile/services/wishlist_service.dart';
import 'package:provider/provider.dart';

import '../helpers/test_binding.dart';

class _DelayedWishlistService extends WishlistService {
  _DelayedWishlistService(this._wishlistCompleter)
      : super(
          ApiService(
            client: MockClient(
              (request) async => http.Response('{}', 200),
            ),
          ),
        );

  final Completer<List<Product>> _wishlistCompleter;

  @override
  Future<List<Product>> getWishlist() => _wishlistCompleter.future;
}

void main() {
  setUpAll(() {
    initializeTestBinding();
    mockSecureStorageChannel();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() async {
    resetToAuthenticatedState();
    await SecureStorageService.setAuthToken('test_auth_token_12345');
  });

  testWidgets(
    'does not call setState after dispose while wishlist is loading',
    (WidgetTester tester) async {
      final wishlistCompleter = Completer<List<Product>>();
      final service = _DelayedWishlistService(wishlistCompleter);
      final capturedErrors = <FlutterErrorDetails>[];
      final previousOnError = FlutterError.onError;
      FlutterError.onError = capturedErrors.add;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<WishlistService>.value(value: service),
          ],
          child: const MaterialApp(
            home: WishlistScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

      wishlistCompleter.complete(const <Product>[]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      FlutterError.onError = previousOnError;

      expect(capturedErrors, isEmpty);
    },
  );
}
