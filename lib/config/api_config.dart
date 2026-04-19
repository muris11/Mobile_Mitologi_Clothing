class ApiConfig {
  ApiConfig._();

  static const String _apiBaseOverride = String.fromEnvironment(
    'MITOLOGI_API_BASE_URL',
    defaultValue: '',
  );

  static const String _storageBaseOverride = String.fromEnvironment(
    'MITOLOGI_STORAGE_BASE_URL',
    defaultValue: '',
  );

  static const String apiVersion = 'v1';
  static const int timeoutDuration = 30000;

  static String _normalizeBase(String value) =>
      value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  static const String _productionBaseUrl = 'https://adminmitologi.based.my.id';

  static String get _defaultBackendOrigin {
    if (_apiBaseOverride.isNotEmpty) {
      return _apiBaseOverride;
    }
    // Use production URL as default
    return _productionBaseUrl;
  }

  static String get baseUrl {
    final base = _normalizeBase(_defaultBackendOrigin);
    return base.endsWith('/api/$apiVersion') ? base : '$base/api/$apiVersion';
  }

  static String get _rawBaseUrl => _normalizeBase(_defaultBackendOrigin);

  static String get storageUrl {
    final override = _normalizeBase(_storageBaseOverride.trim());
    return override.isNotEmpty ? override : _rawBaseUrl;
  }

  static Uri buildUri(String endpoint, {Map<String, String>? queryParams}) {
    final trimmed = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final endpointUri = Uri.parse(trimmed);
    final merged = <String, String>{
      ...endpointUri.queryParameters,
      ...?queryParams,
    };
    final path = 'api/$apiVersion/${endpointUri.path}';
    final baseUri = Uri.parse(_rawBaseUrl);

    return baseUri.isScheme('https')
        ? Uri.https(baseUri.authority, path, merged.isEmpty ? null : merged)
        : Uri.http(baseUri.authority, path, merged.isEmpty ? null : merged);
  }

  static String buildImageUrl(String path) {
    if (path.startsWith('http')) return path;
    return '$storageUrl/storage/${path.startsWith('/') ? path.substring(1) : path}';
  }

  static void printConfig() {}
}

class ApiEndpoints {
  static const String landingPage = '/landing-page';
  static const String siteSettings = '/site-settings';
  static const String products = '/products';
  static const String productsBestSellers = '/products/best-sellers';
  static const String productsNewArrivals = '/products/new-arrivals';
  static const String categories = '/categories';
  static const String materials = '/materials';
  static const String orderSteps = '/order-steps';
  static const String collections = '/collections';
  static const String pages = '/pages';
  static const String portfolios = '/portfolios';
  static const String menus = '/menus';

  static String productDetail(String handle) => '/products/$handle';
  static String productReviews(String handle) => '/products/$handle/reviews';
  static String productRecommendations(int id) =>
      '/products/$id/recommendations';
  static String categoryDetail(String handle) => '/categories/$handle';
  static String collectionDetail(String handle) => '/collections/$handle';
  static String collectionProducts(String handle) =>
      '/collections/$handle/products';
  static String pageDetail(String handle) => '/pages/$handle';
  static String portfolioDetail(String slug) => '/portfolios/$slug';
  static String menuDetail(String handle) => '/menus/$handle';

  static const String cart = '/cart';
  static const String cartItems = '/cart/items';
  static String cartItem(String id) => '/cart/items/$id';
  static const String cartClear = '/cart/clear';

  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authLogout = '/auth/logout';
  static const String authUser = '/auth/user';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authResetPassword = '/auth/reset-password';

  static const String profile = '/profile';
  static const String profilePassword = '/profile/password';
  static const String profileAvatar = '/profile/avatar';
  // Address resources stay nested under the profile contract.
  static const String addresses = '/profile/addresses';
  static String address(int id) => '/profile/addresses/$id';

  static const String orders = '/orders';
  static String orderDetail(String orderNumber) => '/orders/$orderNumber';
  static String orderPay(String orderNumber) => '/orders/$orderNumber/pay';
  static String orderConfirmPayment(String orderNumber) =>
      '/orders/$orderNumber/confirm-payment';
  static String orderRequestRefund(String orderNumber) =>
      '/orders/$orderNumber/request-refund';

  static const String checkout = '/checkout';
  static const String checkoutNotification = '/checkout/notification';
  static const String shippingRates = '/shipping/rates';
  static const String shippingCalculate = '/shipping/calculate';

  static const String wishlist = '/wishlist';
  static String wishlistItem(int productId) => '/wishlist/$productId';
  static String wishlistCheck(int productId) => '/wishlist/check/$productId';

  static String addReview(String handle) => '/products/$handle/reviews';
  static String updateReview(int id) => '/reviews/$id';
  static String deleteReview(int id) => '/reviews/$id';

  static const String recommendations = '/recommendations';
  static const String interactionsBatch = '/interactions/batch';
  static const String chatbot = '/chatbot';

  static const String mlExportData = '/ml/export-data';
}

class ApiHeaders {
  static const String contentType = 'Content-Type';
  static const String accept = 'Accept';
  static const String authorization = 'Authorization';
  static const String cartId = 'X-Cart-Id';
  static const String sessionId = 'X-Session-Id';
  static const String applicationJson = 'application/json';
  static String bearerToken(String token) => 'Bearer $token';
}
