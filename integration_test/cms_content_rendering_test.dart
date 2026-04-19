import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:mitologi_clothing_mobile/screens/cms/content_screen.dart';
import 'package:mitologi_clothing_mobile/services/api_service.dart';
import 'package:mitologi_clothing_mobile/services/product_service.dart';

class _FakeProductService extends ProductService {
  _FakeProductService({required this.getPageHandler})
      : super(
          ApiService(
            client: MockClient((request) async => http.Response('{}', 200)),
          ),
        );

  final Future<Map<String, dynamic>> Function(String handle) getPageHandler;
  final List<String> calls = <String>[];

  @override
  Future<Map<String, dynamic>> getPage(String handle) {
    calls.add(handle);
    return getPageHandler(handle);
  }
}

Widget _buildHarness(ProductService service, String handle) {
  return MultiProvider(
    providers: [
      Provider<ProductService>.value(value: service),
    ],
    child: MaterialApp(
      home: ContentScreen(handle: handle),
    ),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('content about renders intro, hero, and sections', (tester) async {
    final service = _FakeProductService(
      getPageHandler: (_) async => <String, dynamic>{
        'title': 'About',
        'bodySummary': 'Ringkasan brand Mitologi',
        'body': '<h2>Nilai Kami</h2><p>Konten inti</p>',
      },
    );

    await tester.pumpWidget(_buildHarness(service, 'about'));
    await tester.pumpAndSettle();

    expect(find.text('About'), findsOneWidget);
    expect(find.text('Ringkasan brand Mitologi'), findsOneWidget);
    expect(find.byKey(const Key('hero-placeholder')), findsOneWidget);
    expect(find.text('Nilai Kami'), findsOneWidget);
    expect(find.text('Konten inti'), findsOneWidget);
  });

  testWidgets('alias handle tentang-kami maps to about', (tester) async {
    final service = _FakeProductService(
      getPageHandler: (_) async => <String, dynamic>{
        'title': 'Tentang Kami',
        'body': '<p>Isi</p>',
      },
    );

    await tester.pumpWidget(_buildHarness(service, 'tentang-kami'));
    await tester.pumpAndSettle();

    expect(service.calls, isNotEmpty);
    expect(service.calls.first, 'about');
  });

  testWidgets('all four cms pages load without parser crash', (tester) async {
    final service = _FakeProductService(
      getPageHandler: (handle) async => <String, dynamic>{
        'title': handle,
        'bodySummary': 'summary $handle',
        'body': '<h2>Section $handle</h2><p>content</p>',
      },
    );

    for (final handle in <String>[
      'tentang-kami',
      'faq',
      'kebijakan-privasi',
      'syarat-ketentuan',
    ]) {
      await tester.pumpWidget(_buildHarness(service, handle));
      await tester.pumpAndSettle();
      expect(find.textContaining('summary'), findsOneWidget);
      expect(find.textContaining('Section'), findsOneWidget);
    }
  });

  testWidgets('error state shown when API fails', (tester) async {
    final service = _FakeProductService(
      getPageHandler: (_) async => throw Exception('api down'),
    );

    await tester.pumpWidget(_buildHarness(service, 'about'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Gagal memuat konten'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);
  });
}
