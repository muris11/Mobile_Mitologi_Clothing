import '../domain/cms_page.dart';
import '../domain/portfolio_item.dart';

class ContentService {
  ContentService();

  ContentService.forTest();

  Future<CmsPage> fetchPage(String handle) async {
    throw UnimplementedError('fetchPage must be implemented');
  }

  Future<PortfolioItem> fetchPortfolio(String slug) async {
    throw UnimplementedError('fetchPortfolio must be implemented');
  }
}
