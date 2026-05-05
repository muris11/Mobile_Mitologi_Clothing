import 'dart:developer';

import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';
import 'package:mitologi_clothing_mobile/features/content/data/content_service.dart';
import 'package:mitologi_clothing_mobile/features/content/domain/models/content_models.dart';

class ContentRepository {
  final ContentService _contentService;

  ContentRepository(this._contentService);

  Future<CmsPage?> getPage(String handle) async {
    try {
      final response = await _contentService.getPage(handle);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return CmsPage.fromJson(data['data'] ?? data);
      }
      return null;
    } catch (e) {
      log('Error getting CMS page ($handle): $e');
      return null;
    }
  }

  Future<List<PortfolioItem>> getPortfolios() async {
    try {
      final response = await _contentService.getPortfolios();
      final data = response.data;

      dynamic items;
      if (data is Map<String, dynamic>) {
        items = data['data'] ?? data['items'];
      } else {
        items = data;
      }

      return ParserUtils.parseList(items, PortfolioItem.fromJson);
    } catch (e) {
      log('Error getting portfolios: $e');
      return [];
    }
  }

  Future<PortfolioItem?> getPortfolioDetail(String slug) async {
    try {
      final response = await _contentService.getPortfolioDetail(slug);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return PortfolioItem.fromJson(data['data'] ?? data);
      }
      return null;
    } catch (e) {
      log('Error getting portfolio detail ($slug): $e');
      return null;
    }
  }

  Future<List<CollectionDetail>> getCollections() async {
    try {
      final response = await _contentService.getCollections();
      final data = response.data;

      dynamic items;
      if (data is Map<String, dynamic>) {
        items = data['data'] ?? data['items'];
      } else {
        items = data;
      }

      return ParserUtils.parseList(items, CollectionDetail.fromJson);
    } catch (e) {
      log('Error getting collections: $e');
      return [];
    }
  }

  Future<CollectionDetail?> getCollectionWithProducts(String handle) async {
    try {
      final response = await _contentService.getCollectionProducts(handle);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return CollectionDetail.fromJson(data['data'] ?? data);
      }
      return null;
    } catch (e) {
      log('Error getting collection products ($handle): $e');
      return null;
    }
  }
}
