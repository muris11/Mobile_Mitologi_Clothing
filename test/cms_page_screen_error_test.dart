import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/core/api/api_client.dart';
import 'package:mitologi_clothing_mobile/core/storage/cart_storage.dart';
import 'package:mitologi_clothing_mobile/core/storage/token_storage.dart';
import 'package:mitologi_clothing_mobile/features/content/data/content_repository.dart';
import 'package:mitologi_clothing_mobile/features/content/data/content_service.dart';
import 'package:mitologi_clothing_mobile/features/content/domain/models/content_models.dart';
import 'package:mitologi_clothing_mobile/features/content/presentation/cms_page_screen.dart';
import 'package:mitologi_clothing_mobile/features/content/presentation/content_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('CmsPageScreen shows error state on failure', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<ContentProvider>(
          create: (_) => _ThrowingContentProvider(),
          child: const CmsPageScreen(handle: 'privacy-policy'),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Gagal memuat halaman.'), findsOneWidget);
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
  Future<CmsPage?> getPage(String handle) async {
    throw Exception('Gagal memuat halaman.');
  }
}
