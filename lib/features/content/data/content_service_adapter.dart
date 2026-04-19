import '../../../services/product_service.dart';
import '../domain/cms_page.dart';
import '../domain/portfolio_item.dart';
import 'content_service.dart';

class ProductContentServiceAdapter extends ContentService {
  final ProductService _productService;

  ProductContentServiceAdapter(this._productService);

  @override
  Future<CmsPage> fetchPage(String handle) async {
    final data = await _productService.getPage(handle);
    return CmsPage(
      handle: data['handle']?.toString() ?? handle,
      title: data['title']?.toString() ?? handle,
      body: (data['content'] ?? data['body'])?.toString() ?? '',
      excerpt: (data['excerpt'] ?? data['bodySummary'])?.toString(),
      imageUrl: (data['image'] ?? data['image_url'] ?? data['featured_image'])
          ?.toString(),
    );
  }

  @override
  Future<PortfolioItem> fetchPortfolio(String slug) async {
    final data = await _productService.getPortfolioDetail(slug);
    final payload = data['data'] is Map<String, dynamic>
        ? data['data'] as Map<String, dynamic>
        : data;
    final portfolio = payload['portfolio'] is Map<String, dynamic>
        ? payload['portfolio'] as Map<String, dynamic>
        : payload;
    return PortfolioItem(
      slug: portfolio['slug']?.toString() ?? slug,
      title: portfolio['title']?.toString() ?? slug,
    );
  }
}
