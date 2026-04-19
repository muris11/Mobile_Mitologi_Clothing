import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/features/content/data/content_service.dart';
import 'package:mitologi_clothing_mobile/features/content/domain/cms_page.dart';
import 'package:mitologi_clothing_mobile/features/content/domain/portfolio_item.dart';
import 'package:mitologi_clothing_mobile/features/content/presentation/content_provider.dart';

class FakeContentService extends ContentService {
  FakeContentService() : super.forTest();

  CmsPage? page;
  PortfolioItem? portfolio;
  Exception? pageError;

  @override
  Future<CmsPage> fetchPage(String handle) async {
    if (pageError != null) throw pageError!;
    return page!;
  }

  @override
  Future<PortfolioItem> fetchPortfolio(String slug) async => portfolio!;
}

void main() {
  group('ContentProvider', () {
    test('loads page by handle', () async {
      final service = FakeContentService()
        ..page = const CmsPage(handle: 'about', title: 'About', body: '<p>Hi</p>');
      final provider = ContentProvider(service);

      await provider.loadPage('about');

      expect(provider.page?.handle, 'about');
      expect(provider.error, isNull);
    });

    test('loads portfolio by slug', () async {
      final service = FakeContentService()
        ..portfolio = const PortfolioItem(slug: 'bridal', title: 'Bridal');
      final provider = ContentProvider(service);

      await provider.loadPortfolio('bridal');

      expect(provider.portfolio?.slug, 'bridal');
      expect(provider.error, isNull);
    });
  });
}
