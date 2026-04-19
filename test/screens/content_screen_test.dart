import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mitologi_clothing_mobile/screens/cms/content_screen.dart';
import 'package:mitologi_clothing_mobile/services/api_service.dart';
import 'package:mitologi_clothing_mobile/services/product_service.dart';
import 'package:provider/provider.dart';

import '../helpers/test_binding.dart';

class _FakeProductService extends ProductService {
  _FakeProductService({required this.getPageHandler})
      : super(
          ApiService(
            client: MockClient(
              (request) async => http.Response('{}', 200),
            ),
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

void main() {
  setUpAll(() {
    initializeTestBinding();
    mockSecureStorageChannel();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('renders cms content when request succeeds', (
    WidgetTester tester,
  ) async {
    final service = _FakeProductService(
      getPageHandler: (_) async => <String, dynamic>{
        'title': 'About',
        'bodySummary': 'Ringkasan konten',
        'body': 'Isi konten lengkap',
      },
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ProductService>.value(value: service),
        ],
        child: const MaterialApp(
          home: ContentScreen(handle: 'about'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('About'), findsOneWidget);
    expect(find.text('Ringkasan konten'), findsOneWidget);
    expect(find.text('Isi konten lengkap'), findsOneWidget);
  });

  testWidgets('shows hero placeholder when image is missing', (
    WidgetTester tester,
  ) async {
    final service = _FakeProductService(
      getPageHandler: (_) async => <String, dynamic>{
        'title': 'About',
        'bodySummary': 'Ringkasan konten',
        'body': '<p>Isi konten lengkap</p>',
      },
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ProductService>.value(value: service),
        ],
        child: const MaterialApp(
          home: ContentScreen(handle: 'about'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('hero-placeholder')), findsOneWidget);
  });

  testWidgets('shows hero loading skeleton when image exists', (
    WidgetTester tester,
  ) async {
    final service = _FakeProductService(
      getPageHandler: (_) async => <String, dynamic>{
        'title': 'About',
        'bodySummary': 'Ringkasan konten',
        'body': '<p>Isi konten lengkap</p>',
        'image_url': 'https://example.com/banner.jpg',
      },
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ProductService>.value(value: service),
        ],
        child: const MaterialApp(
          home: ContentScreen(handle: 'about'),
        ),
      ),
    );

    await tester.pump();

    expect(find.byKey(const Key('hero-loading-skeleton')), findsOneWidget);
  });

  testWidgets('maps legacy handle to valid api handle', (
    WidgetTester tester,
  ) async {
    final service = _FakeProductService(
      getPageHandler: (_) async => <String, dynamic>{
        'title': 'Tentang Kami',
        'body': 'Konten tentang kami',
      },
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ProductService>.value(value: service),
        ],
        child: const MaterialApp(
          home: ContentScreen(handle: 'tentang-kami'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(service.calls, isNotEmpty);
    expect(service.calls.first, 'about');
  });

  testWidgets('shows error state when request fails',
      (WidgetTester tester) async {
    final service = _FakeProductService(
      getPageHandler: (_) async => throw Exception('boom'),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ProductService>.value(value: service),
        ],
        child: const MaterialApp(
          home: ContentScreen(handle: 'about'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Gagal memuat konten'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);
  });

  testWidgets('shows parser error message for malformed html content',
      (WidgetTester tester) async {
    final service = _FakeProductService(
      getPageHandler: (_) async => <String, dynamic>{
        'title': 'About',
        'bodySummary': null,
        'body': '<p>ok</p>THROW_PARSER_ERROR',
        'image_url': null,
      },
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ProductService>.value(value: service),
        ],
        child: const MaterialApp(
          home: ContentScreen(handle: 'about'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Konten tidak dapat ditampilkan'), findsOneWidget);
  });

  testWidgets('does not call setState after dispose while loading', (
    WidgetTester tester,
  ) async {
    final completer = Completer<Map<String, dynamic>>();
    final service = _FakeProductService(
      getPageHandler: (_) => completer.future,
    );

    final capturedErrors = <FlutterErrorDetails>[];
    final previousOnError = FlutterError.onError;
    FlutterError.onError = capturedErrors.add;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ProductService>.value(value: service),
        ],
        child: const MaterialApp(
          home: ContentScreen(handle: 'about'),
        ),
      ),
    );

    await tester.pump();
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

    completer.complete(<String, dynamic>{
      'title': 'About',
      'body': 'Done',
    });

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    FlutterError.onError = previousOnError;

    expect(capturedErrors, isEmpty);
  });
}
