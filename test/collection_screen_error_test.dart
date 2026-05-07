import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/core/api/api_client.dart';
import 'package:mitologi_clothing_mobile/core/storage/cart_storage.dart';
import 'package:mitologi_clothing_mobile/core/storage/token_storage.dart';
import 'package:mitologi_clothing_mobile/features/content/data/content_repository.dart';
import 'package:mitologi_clothing_mobile/features/content/data/content_service.dart';
import 'package:mitologi_clothing_mobile/features/content/domain/models/content_models.dart';
import 'package:mitologi_clothing_mobile/features/content/presentation/collection_screen.dart';
import 'package:mitologi_clothing_mobile/features/content/presentation/content_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('CollectionScreen shows error state on failure',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<ContentProvider>(
          create: (_) => _ThrowingContentProvider(),
          child: const CollectionScreen(handle: 'kaos-premium'),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Gagal Memuat Koleksi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _ThrowingContentProvider extends ContentProvider {
  _ThrowingContentProvider()
      : super(
          ContentRepository(
            ContentService(ApiClient(TokenStorage(), CartStorage())),
          ),
        );

  @override
  Future<CollectionDetail?> getCollectionWithProducts(String handle) async {
    throw Exception('Gagal memuat produk koleksi.');
  }
}
