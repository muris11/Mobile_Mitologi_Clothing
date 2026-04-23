import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../models/image_model.dart';
import '../models/money.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService;


  // Products
  List<Product> _products = [];
  List<Product> _bestSellers = [];
  List<Product> _newArrivals = [];

  // Landing Page Data
  List<Map<String, dynamic>> _heroSlides = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _testimonials = [];
  List<Map<String, dynamic>> _materials = [];
  List<Map<String, dynamic>> _portfolioItems = [];
  final List<Map<String, dynamic>> _promos = [];
  List<Map<String, dynamic>> _guarantees = []; // Garansi & Bonus
  Map<String, dynamic>? _siteSettings;

  // Additional Landing Page Data (from API docs)
  List<Map<String, dynamic>> _features = []; // Mengapa Memilih Kami
  List<Map<String, dynamic>> _orderSteps = [];
  List<Map<String, dynamic>> _partners = [];
  List<Map<String, dynamic>> _printingMethods = [];
  List<Map<String, dynamic>> _productPricings = [];
  List<Map<String, dynamic>> _facilities = [];
  Map<String, dynamic>? _cta;
  List<Map<String, dynamic>> _teamMembers = [];

  // State
  bool _isLoading = false;
  String? _error;
  String? _currentQuery;
  String? _currentCategory;
  String? _currentSortKey;
  bool? _currentReverse;

  ProductProvider(this._productService);

  Map<String, dynamic> _unwrapResponse(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) return data;
      return response;
    }
    return <String, dynamic>{};
  }

  List<dynamic> _listFromResponse(
      Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is List) return value;
      if (value is Map<String, dynamic>) {
        final nested = value['items'] ?? value['data'] ?? value['products'];
        if (nested is List) return nested;
      }
    }
    return const [];
  }

  Map<String, dynamic>? _mapFromResponse(
      Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is Map<String, dynamic>) return value;
    }
    return null;
  }

  // Getters
  List<Product> get products => _products;
  List<Product> get bestSellers => _bestSellers;
  List<Product> get newArrivals => _newArrivals;
  List<Map<String, dynamic>> get heroSlides => _heroSlides;
  List<Map<String, dynamic>> get categories => _categories;
  List<Map<String, dynamic>> get testimonials => _testimonials;
  List<Map<String, dynamic>> get materials => _materials;
  List<Map<String, dynamic>> get portfolioItems => _portfolioItems;
  List<Map<String, dynamic>> get promos => _promos;
  List<Map<String, dynamic>> get guarantees => _guarantees; // Garansi & Bonus
  Map<String, dynamic>? get siteSettings => _siteSettings;

  // Additional Landing Page Getters
  List<Map<String, dynamic>> get features => _features;
  List<Map<String, dynamic>> get orderSteps => _orderSteps;
  List<Map<String, dynamic>> get partners => _partners;
  List<Map<String, dynamic>> get printingMethods => _printingMethods;
  List<Map<String, dynamic>> get productPricings => _productPricings;
  List<Map<String, dynamic>> get facilities => _facilities;
  Map<String, dynamic>? get cta => _cta;
  List<Map<String, dynamic>> get teamMembers => _teamMembers;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentQuery => _currentQuery;
  String? get currentCategory => _currentCategory;
  String? get currentSortKey => _currentSortKey;
  bool? get currentReverse => _currentReverse;

  /// Load all home data from API (landing page includes everything)
  Future<void> loadHomeData() async {
    _setLoading(true);
    _clearError();

    try {
      // Fetch landing page data - it includes heroSlides, categories, bestSellers, newArrivals
      final landingPage = await _productService.getLandingPage();

      // Debug logging - ALWAYS print for debugging
      _debugLog('=== LANDING PAGE RAW DATA ===');
      _debugLog('Type: ${landingPage.runtimeType}');
      _debugLog('Keys: ${landingPage.keys.toList()}');

      // Check for common response structures
      final data = _unwrapResponse(landingPage);
      _debugLog('Data type: ${data.runtimeType}');
      _debugLog('Data keys: ${data.keys.toList()}');
      _debugLog(
          'portfolio_items in data: ${data['portfolio_items'] ?? data['portfolioItems']}');
      _debugLog('materials in data: ${data['materials']}');
      _debugLog('testimonials in data: ${data['testimonials']}');

      _debugLog(
          'Direct hero_slides: ${landingPage['hero_slides'] ?? landingPage['heroSlides']}');
      _debugLog('Direct Categories: ${landingPage['categories']}');
      _debugLog('Direct products: ${landingPage['products']}');
      _debugLog(
          'Direct best_sellers: ${landingPage['best_sellers'] ?? landingPage['bestSellers']}');
      _debugLog(
          'Direct new_arrivals: ${landingPage['new_arrivals'] ?? landingPage['newArrivals']}');

      final responseData = data;

      // Parse hero slides - support camelCase and snake_case.
      final heroSlidesData = _listFromResponse(
        responseData,
        ['heroSlides', 'hero_slides'],
      );
      _heroSlides = heroSlidesData.map((slide) {
        final s = slide as Map<String, dynamic>;
        return <String, dynamic>{
          'id': _parseInt(s['id']),
          'title': s['title']?.toString() ?? '',
          'subtitle': s['subtitle']?.toString() ?? '',
          'imageUrl': s['imageUrl']?.toString() ??
              s['image_url']?.toString() ??
              s['image']?.toString() ??
              '',
          'ctaText': s['ctaText']?.toString() ??
              s['cta_text']?.toString() ??
              'Lihat Produk',
          'ctaLink': s['ctaLink']?.toString() ??
              s['cta_link']?.toString() ??
              '/products',
          'isActive': s['isActive'] ?? s['is_active'] ?? true,
        };
      }).toList();

      // Parse categories from landing page
      final categoriesData = _listFromResponse(responseData, ['categories']);
      _categories = categoriesData.map((category) {
        final c = category as Map<String, dynamic>;
        return <String, dynamic>{
          'id': _parseInt(c['id']),
          'name': c['name']?.toString() ?? '',
          'slug': c['slug']?.toString() ?? '',
          'handle': c['handle']?.toString() ?? c['slug']?.toString() ?? '',
          'description': c['description']?.toString() ?? '',
          'image': c['image']?.toString() ?? c['image_url']?.toString() ?? '',
          'productsCount': _parseInt(c['productsCount'] ?? c['products_count']),
        };
      }).toList();

      // Parse best sellers from landing page
      final bestSellersData =
          _listFromResponse(responseData, ['bestSellers', 'best_sellers']);
      _bestSellers = bestSellersData
          .map((item) => _convertLandingPageProduct(item))
          .toList();

      // Parse new arrivals from landing page
      final newArrivalsData =
          _listFromResponse(responseData, ['newArrivals', 'new_arrivals']);
      _newArrivals = newArrivalsData
          .map((item) => _convertLandingPageProduct(item))
          .toList();

      if (_bestSellers.isEmpty && _newArrivals.isEmpty) {
        final featuredProducts = _listFromResponse(responseData, ['products']);
        _bestSellers = featuredProducts
            .whereType<Map<String, dynamic>>()
            .map(_convertLandingPageProduct)
            .toList();
      }

      // Parse other data
      _testimonials = _parseList(responseData, ['testimonials']);
      _materials = _parseList(responseData, ['materials']);
      _portfolioItems = _listFromResponse(
        responseData,
        ['portfolioItems', 'portfolio_items', 'portfolio'],
      ).whereType<Map<String, dynamic>>().toList();
      _siteSettings =
          _mapFromResponse(responseData, ['siteSettings', 'site_settings']);

      // Parse garansi & bonus data from API
      _guarantees = _parseGuarantees(responseData);

      // Parse additional landing page data
      _features = _parseList(responseData, ['features']);
      _orderSteps = _parseList(responseData, ['orderSteps', 'order_steps']);
      _partners = _parseList(responseData, ['partners']);
      _printingMethods = _parseList(responseData, ['printingMethods', 'printing_methods']);
      _productPricings = _parseList(responseData, ['productPricings', 'product_pricings']);
      _facilities = _parseList(responseData, ['facilities']);
      _cta = _mapFromResponse(responseData, ['cta']);
      _teamMembers = _parseList(responseData, ['teamMembers', 'team_members']);

      // Debug logging - ALWAYS print
      _debugLog('=== PARSED DATA ===');
      _debugLog('Hero Slides: ${_heroSlides.length}');
      _debugLog('Categories: ${_categories.length}');
      _debugLog('Best Sellers: ${_bestSellers.length}');
      _debugLog('New Arrivals: ${_newArrivals.length}');
      _debugLog('Guarantees: ${_guarantees.length}');
      _debugLog('SiteSettings keys: ${_siteSettings?.keys.toList() ?? []}');
      if (_heroSlides.isNotEmpty) {
        _debugLog('First hero slide: ${_heroSlides.first}');
      }
      if (_categories.isNotEmpty) {
        _debugLog('First category: ${_categories.first}');
      }
      if (_guarantees.isNotEmpty) {
        _debugLog('First guarantee: ${_guarantees.first}');
      }

      notifyListeners();
    } catch (e) {
      _setError('Gagal memuat data halaman: $e');
      if (kDebugMode) _debugLog('ERROR loadHomeData: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Convert landing page product data to Product model
  Product _convertLandingPageProduct(dynamic item) {
    final data = item as Map<String, dynamic>;


    // Parse price from various possible formats
    Money? priceMoney;

    // 1. Try direct price field
    final priceData = data['price'];
    if (priceData is num) {
      priceMoney = Money(amount: priceData.toDouble());
    } else if (priceData is String) {
      final parsed = double.tryParse(priceData);
      if (parsed != null) {
        priceMoney = Money(amount: parsed);
      }
    } else if (priceData is Map<String, dynamic>) {
      try {
        priceMoney = Money.fromJson(priceData);
      } catch (e) {
        final amount = priceData['amount'] ?? priceData['value'];
        if (amount is num) {
          priceMoney = Money(amount: amount.toDouble());
        } else if (amount is String) {
          final parsed = double.tryParse(amount);
          if (parsed != null) {
            priceMoney = Money(amount: parsed);
          }
        }
      }
    }

    // 2. Try priceRange if no direct price
    if (priceMoney == null) {
      final priceRange = data['priceRange'];
      if (priceRange is Map<String, dynamic>) {
        // Use minVariantPrice from priceRange
        final minPrice =
            priceRange['minVariantPrice'] ?? priceRange['minPrice'];
        if (minPrice is Map<String, dynamic>) {
          try {
            priceMoney = Money.fromJson(minPrice);
          } catch (e) {
            final amount = minPrice['amount'];
            if (amount is num) {
              priceMoney = Money(amount: amount.toDouble());
            } else if (amount is String) {
              final parsed = double.tryParse(amount);
              if (parsed != null) {
                priceMoney = Money(amount: parsed);
              }
            }
          }
        } else if (minPrice is num) {
          priceMoney = Money(amount: minPrice.toDouble());
        }
      }
    }

    // 3. Try first variant price if still no price
    if (priceMoney == null) {
      final variants = data['variants'] as List<dynamic>?;
      if (variants != null && variants.isNotEmpty) {
        final firstVariant = variants.first as Map<String, dynamic>;
        final variantPrice = firstVariant['price'];
        if (variantPrice is Map<String, dynamic>) {
          try {
            priceMoney = Money.fromJson(variantPrice);
          } catch (e) {
            final amount = variantPrice['amount'];
            if (amount is String) {
              final parsed = double.tryParse(amount);
              if (parsed != null) {
                priceMoney = Money(amount: parsed);
              }
            }
          }
        }
      }
    }

    if (kDebugMode) {
      _debugLog('Parsed price: ${priceMoney?.formatted}');
    }

    // Parse featured image
    ImageModel? featuredImage;
    final images = data['images'] as List<dynamic>?;
    if (images != null && images.isNotEmpty) {
      final firstImage = images.first;
      if (firstImage is Map<String, dynamic>) {
        featuredImage = ImageModel(
          url: firstImage['url']?.toString() ??
              firstImage['src']?.toString() ??
              firstImage['imageUrl']?.toString() ??
              firstImage['image_url']?.toString() ??
              '',
          altText:
              firstImage['altText']?.toString() ?? data['title']?.toString(),
        );
      } else if (firstImage is String && firstImage.isNotEmpty) {
        featuredImage = ImageModel(
          url: firstImage,
          altText: data['title']?.toString(),
        );
      }
    }

    ImageModel? parseImage(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isNotEmpty) {
        return ImageModel(url: value, altText: data['title']?.toString());
      }
      if (value is Map<String, dynamic>) {
        final url = value['url']?.toString() ??
            value['src']?.toString() ??
            value['imageUrl']?.toString() ??
            value['image_url']?.toString() ??
            '';
        if (url.isEmpty) return null;
        return ImageModel(
          url: url,
          altText: value['altText']?.toString() ?? data['title']?.toString(),
        );
      }
      return null;
    }

    featuredImage ??= parseImage(data['featured_image']) ??
        parseImage(data['featuredImage']) ??
        parseImage(data['image']) ??
        parseImage(data['imageUrl']) ??
        parseImage(data['image_url']);

    return Product(
      id: _parseInt(data['id']),
      handle: data['handle']?.toString() ?? data['id']?.toString() ?? 'unknown',
      title: data['title']?.toString() ?? 'Untitled',
      description: data['description']?.toString(),
      price: priceMoney,
      featuredImage: featuredImage,
      productType: data['productType']?.toString() ??
          data['product_type']?.toString() ??
          data['category']?.toString(),
      availableForSale: data['availableForSale'] ?? data['inStock'] ?? true,
      vendor: data['vendor']?.toString(),
    );
  }

  /// Load best sellers from API (fallback if landing page fails)
  Future<void> loadBestSellers() async {
    try {
      _bestSellers = await _productService.getBestSellers(limit: 10);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) _debugLog('ERROR loadBestSellers: $e');
    }
  }

  /// Load new arrivals from API (fallback if landing page fails)
  Future<void> loadNewArrivals() async {
    try {
      _newArrivals = await _productService.getNewArrivals(limit: 10);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) _debugLog('ERROR loadNewArrivals: $e');
    }
  }

  /// Load categories from API (fallback if landing page fails)
  Future<void> loadCategories() async {
    _setLoading(true);
    try {
      final categoriesData = await _productService.getCategories();
      // Convert to proper format with full image URLs
      _categories = categoriesData.map((c) {
        final imageRaw = c['image'] ?? c['image_url'] ?? c['featured_image'];
        String imageUrl = '';
        if (imageRaw is String) {
          imageUrl = imageRaw;
        } else if (imageRaw is Map<String, dynamic>) {
          imageUrl = imageRaw['url']?.toString() ??
              imageRaw['src']?.toString() ??
              imageRaw['image_url']?.toString() ??
              '';
        }

        return <String, dynamic>{
          'id': c['id'],
          'name': c['name'] ?? '',
          'slug': c['slug'] ?? '',
          'handle': c['handle'] ?? c['slug'] ?? '',
          'description': c['description'] ?? '',
          'image': imageUrl.isEmpty ? '' : ApiConfig.buildImageUrl(imageUrl),
          'productsCount': c['productsCount'] ?? c['products_count'] ?? 0,
        };
      }).toList();
      notifyListeners();
    } catch (e) {
      _setError('Gagal memuat kategori: $e');
      if (kDebugMode) _debugLog('ERROR loadCategories: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Search products
  Future<void> searchProducts(
    String query, {
    String? category,
    String? sortKey,
    bool? reverse,
  }) async {
    await loadProducts(
      query: query,
      category: category,
      sortKey: sortKey,
      reverse: reverse,
    );
  }

  /// Load all products
  Future<void> loadProducts({
    String? query,
    String? category,
    String? sortKey,
    bool? reverse,
    double? minPrice,
    double? maxPrice,
  }) async {
    _setLoading(true);
    _clearError();
    _currentQuery = _normalizeFilterValue(query);
    _currentCategory = _normalizeFilterValue(category);
    _currentSortKey = _normalizeFilterValue(sortKey);
    _currentReverse = reverse;

    try {
      _products = await _productService.getProducts(
        query: _currentQuery,
        category: _currentCategory,
        sortKey: _currentSortKey,
        reverse: _currentReverse,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
      notifyListeners();
    } catch (e) {
      _setError('Gagal memuat produk: $e');
      if (kDebugMode) _debugLog('ERROR loadProducts: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load products by category
  Future<void> loadProductsByCategory(
    String category, {
    String? query,
    String? sortKey,
    bool? reverse,
  }) async {
    await loadProducts(
      query: query,
      category: category,
      sortKey: sortKey,
      reverse: reverse,
    );
  }

  Future<void> reloadProducts() async {
    await loadProducts(
      query: _currentQuery,
      category: _currentCategory,
      sortKey: _currentSortKey,
      reverse: _currentReverse,
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  String? _normalizeFilterValue(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  List<Map<String, dynamic>> _parseList(
      Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is List) {
        return value.cast<Map<String, dynamic>>();
      }
    }
    return [];
  }

  /// Parse value to int safely
  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  /// Parse guarantees/bonus data from API response
  /// Section "Si & Bonus" AMBIL DARI siteSettings.garansiBonusData atau siteSettings.guaranteesData
  /// JANGAN ambil dari features (itu untuk section "Mengapa Memilih Kami")
  List<Map<String, dynamic>> _parseGuarantees(
      Map<String, dynamic> responseData) {
    _debugLog('=== PARSING GUARANTEES ===');
    _debugLog('ResponseData keys: ${responseData.keys.toList()}');

    // IMPORTANT: Section "Si & Bonus" HANYA ambil dari siteSettings
    // features di root level itu untuk section BERBEDA ("Mengapa Memilih Kami")

    final siteSettings = responseData['siteSettings'];
    _debugLog('siteSettings type: ${siteSettings?.runtimeType}');

    if (siteSettings is Map<String, dynamic>) {
      _debugLog('siteSettings keys: ${siteSettings.keys.toList()}');

      // 1. PRIORITAS 1: garansiBonusData (camelCase) - di root siteSettings
      final garansiBonusData = siteSettings['garansiBonusData'];
      if (garansiBonusData is List && garansiBonusData.isNotEmpty) {
        _debugLog(
            '✓ Found garansiBonusData in siteSettings: ${garansiBonusData.length} items');
        _debugLog('First item: ${garansiBonusData.first}');
        return garansiBonusData.cast<Map<String, dynamic>>();
      }

      // 2. PRIORITAS 2: garansi_bonus_data (snake_case) - di root siteSettings
      final garansiBonusDataSnake = siteSettings['garansi_bonus_data'];
      if (garansiBonusDataSnake is List && garansiBonusDataSnake.isNotEmpty) {
        _debugLog(
            '✓ Found garansi_bonus_data in siteSettings: ${garansiBonusDataSnake.length} items');
        return garansiBonusDataSnake.cast<Map<String, dynamic>>();
      }
      // Kalau masih string JSON, decode dulu
      if (garansiBonusDataSnake is String && garansiBonusDataSnake.isNotEmpty) {
        try {
          final decoded = jsonDecode(garansiBonusDataSnake);
          if (decoded is List && decoded.isNotEmpty) {
            _debugLog(
                '✓ Found garansi_bonus_data (JSON decoded): ${decoded.length} items');
            return decoded.cast<Map<String, dynamic>>();
          }
        } catch (e) {
          _debugLog('Failed to decode garansi_bonus_data: $e');
        }
      }

      // 3. PRIORITAS 3: guaranteesData (camelCase) - alternatif
      final guaranteesData = siteSettings['guaranteesData'];
      if (guaranteesData is List && guaranteesData.isNotEmpty) {
        _debugLog(
            '✓ Found guaranteesData in siteSettings: ${guaranteesData.length} items');
        return guaranteesData.cast<Map<String, dynamic>>();
      }

      // 4. PRIORITAS 4: guarantees_data (snake_case)
      final guaranteesDataSnake = siteSettings['guarantees_data'];
      if (guaranteesDataSnake is List && guaranteesDataSnake.isNotEmpty) {
        _debugLog(
            '✓ Found guarantees_data in siteSettings: ${guaranteesDataSnake.length} items');
        return guaranteesDataSnake.cast<Map<String, dynamic>>();
      }
      if (guaranteesDataSnake is String && guaranteesDataSnake.isNotEmpty) {
        try {
          final decoded = jsonDecode(guaranteesDataSnake);
          if (decoded is List && decoded.isNotEmpty) {
            _debugLog(
                '✓ Found guarantees_data (JSON decoded): ${decoded.length} items');
            return decoded.cast<Map<String, dynamic>>();
          }
        } catch (e) {
          _debugLog('Failed to decode guarantees_data: $e');
        }
      }

      // 5. Check inside group 'beranda' (where garansi_bonus_data is stored)
      final beranda = siteSettings['beranda'];
      if (beranda is Map<String, dynamic>) {
        _debugLog('beranda keys: ${beranda.keys.toList()}');

        final berandaGaransi = beranda['garansi_bonus_data'];
        if (berandaGaransi is List && berandaGaransi.isNotEmpty) {
          _debugLog(
              '✓ Found garansi_bonus_data in beranda: ${berandaGaransi.length} items');
          return berandaGaransi.cast<Map<String, dynamic>>();
        }
        if (berandaGaransi is String && berandaGaransi.isNotEmpty) {
          try {
            final decoded = jsonDecode(berandaGaransi);
            if (decoded is List && decoded.isNotEmpty) {
              _debugLog(
                  '✓ Found garansi_bonus_data in beranda (JSON decoded): ${decoded.length} items');
              return decoded.cast<Map<String, dynamic>>();
            }
          } catch (e) {
            _debugLog('Failed to decode beranda.garansi_bonus_data: $e');
          }
        }
      }
    }

    // TIDAK ADA FALLBACK KE features - karena itu untuk section BERBEDA
    _debugLog('✗ No garansiBonusData or guaranteesData found in siteSettings');
    _debugLog('Section Si & Bonus will be HIDDEN');
    return [];
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
}
