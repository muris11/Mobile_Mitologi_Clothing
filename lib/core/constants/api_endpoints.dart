class ApiEndpoints {
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String user = '/auth/user';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  static const String profile = '/profile';
  static const String changePassword = '/profile/password';
  static const String updateAvatar = '/profile/avatar';
  static const String addresses = '/profile/addresses';
  static String address(int id) => '/profile/addresses/$id';

  static const String products = '/products';
  static String productDetail(String handle) => '/products/$handle';
  static const String categories = '/categories';
  static String categoryDetail(String handle) => '/categories/$handle';
  static const String materials = '/materials';
  static const String bestSellers = '/products/best-sellers';
  static const String newArrivals = '/products/new-arrivals';
  static String relatedProducts(int id) => '/products/$id/recommendations';

  static const String cart = '/cart';
  static const String cartItems = '/cart/items';
  static String cartItem(int id) => '/cart/items/$id';
  static const String clearCart = '/cart/clear';

  static const String checkout = '/checkout';
  static const String orders = '/orders';
  static String orderDetail(String orderNumber) => '/orders/$orderNumber';
  static String orderPay(String orderNumber) => '/orders/$orderNumber/pay';
  static String confirmPayment(String orderNumber) => '/orders/$orderNumber/confirm-payment';
  static String requestRefund(String orderNumber) => '/orders/$orderNumber/request-refund';

  static const String wishlist = '/wishlist';
  static String toggleWishlist(int productId) => '/wishlist/$productId';
  static String checkWishlist(int productId) => '/wishlist/check/$productId';

  static String productReviews(String handle) => '/products/$handle/reviews';
  static const String reviews = '/reviews';
  static String review(int id) => '/reviews/$id';

  static const String chatbot = '/chatbot';
  static const String aiRecommendations = '/recommendations';
  static const String interactionsBatch = '/interactions/batch';

  static const String pages = '/pages';
  static String pageDetail(String handle) => '/pages/$handle';
  static const String portfolios = '/portfolios';
  static String portfolioDetail(String slug) => '/portfolios/$slug';
  static const String landingPage = '/landing-page';
  static const String siteSettings = '/site-settings';
  static const String orderSteps = '/order-steps';
  static const String collections = '/collections';
  static String collectionDetail(String handle) => '/collections/$handle';
  static String collectionProducts(String handle) => '/collections/$handle/products';
  static const String menus = '/menus';
  static String menuDetail(String handle) => '/menus/$handle';

  static const String searchProducts = '/products';
  static const String teamMembers = '/team-members';
  static String teamMemberPhoto(int id) => '/team-members/$id/photo';
  static const String shippingRates = '/shipping/rates';
  static const String shippingCalculate = '/shipping/calculate';
  static const String mlExportData = '/ml/export-data';
}
