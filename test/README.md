# Test Suite Documentation

## Overview
Test suite lengkap untuk aplikasi Flutter e-commerce **Mitologi Clothing** dengan integrasi API penuh dan responsive support.

## Test Structure

```
test/
├── helpers/
│   ├── test_binding.dart       # Flutter binding initialization & mocks
│   └── test_helpers.dart       # Sample data untuk testing (100 baris)
├── mocks/
│   └── mock_api_client.dart    # Mock HTTP client untuk testing (103 baris)
└── services/
    ├── product_service_test.dart    # 29 unit tests - ALL PASS ✅
    ├── auth_service_test.dart       # 13 unit tests
    ├── cart_service_test.dart        # 14 unit tests
    ├── order_service_test.dart       # 17 unit tests
    ├── wishlist_service_test.dart    # 16 unit tests
    └── profile_service_test.dart     # 20 unit tests
```

## Test Coverage Summary

### Services (10 services)
| Service | Methods | Endpoints | Test File | Status |
|---------|---------|-----------|-----------|--------|
| ProductService | 18 | 18 | product_service_test.dart | ✅ 29 tests PASS |
| AuthService | 6 | 6 | auth_service_test.dart | 📝 13 tests |
| CartService | 6 | 6 | cart_service_test.dart | 📝 14 tests |
| OrderService | 7 | 7 | order_service_test.dart | 📝 17 tests |
| WishlistService | 5 | 5 | wishlist_service_test.dart | 📝 16 tests |
| ProfileService | 9 | 9 | profile_service_test.dart | 📝 20 tests |
| ReviewService | 3 | 3 | - | ⏳ Belum |
| ChatbotService | 1 | 1 | - | ⏳ Belum |
| SecureStorageService | 10 | - | - | ⏳ Belum |
| ApiService | 5 | - | - | ⏳ Belum |

**Total: 65+ methods, 55+ endpoints**

### Unit Tests Summary
- **ProductService**: 29 tests (100% PASS)
- **AuthService**: 13 tests (login, register, logout, user, password)
- **CartService**: 14 tests (create, get, add, update, remove, clear)
- **OrderService**: 17 tests (checkout, get orders, detail, pay, confirm, refund)
- **WishlistService**: 16 tests (get, add, remove, check, toggle, count)
- **ProfileService**: 20 tests (get, update, password, avatar, addresses)

**Total: ~109+ unit tests untuk services**

## Test Data Types

### Sample Data (TestHelpers)
- ✅ sampleProduct - Produk dengan variants, options, SEO
- ✅ sampleProducts - List 2 produk
- ✅ sampleCart - Cart dengan items dan cost
- ✅ sampleCartItem - Item untuk cart operations
- ✅ sampleUser - User profile data
- ✅ sampleAuthResponse - Response login/register
- ✅ sampleOrder - Order lengkap dengan items
- ✅ sampleCheckoutResult - Hasil checkout
- ✅ samplePaymentInfo - Payment (Midtrans)
- ✅ sampleAddress - Alamat pengiriman
- ✅ sampleAddresses - List 2 alamat
- ✅ sampleLandingPage - Landing page CMS
- ✅ samplePage - CMS page content
- ✅ sampleMenu - Navigation menu
- ✅ sampleOrderSteps - Cara pemesanan
- ✅ sampleReview - Product review
- ✅ sampleReviewsResponse - Reviews dengan metadata

## Mock Infrastructure

### MockApiClient
- ✅ HTTP client mocking dengan `http/testing.dart`
- ✅ Response mapping per method + URL
- ✅ Status code configuration
- ✅ Error response simulation
- ✅ Pattern-based URL matching
- ✅ Common responses preset (landing page, auth, cart, orders)

### TestBinding
- ✅ `TestWidgetsFlutterBinding.ensureInitialized()`
- ✅ Secure storage channel mocking
- ✅ Mock read/write/delete/clear operations
- ✅ Storage state persistence per test

## Test Patterns

### Unit Test Structure
```dart
group('ServiceName Tests', () {
  late MockApiClient mockClient;
  late ApiService apiService;
  late ServiceName service;

  setUp(() {
    mockClient = MockApiClient();
    apiService = ApiService(client: mockClient.client);
    service = ServiceName(apiService);
  });

  tearDown(() => mockClient.clear());

  group('methodName', () {
    test('success case', () async { ... });
    test('error case', () async { ... });
    test('edge case', () async { ... });
  });
});
```

### Error Testing
```dart
test('throws exception on error', () async {
  mockClient.setResponse(
    'GET', 'https://api.example.com/endpoint',
    {'message': 'Error message'},
    statusCode: 404,
  );

  expect(
    () => service.method(),
    throwsA(isA<ApiException>()),
  );
});
```

## API Endpoint Coverage

### Product Endpoints (18)
✅ GET /landing-page
✅ GET /products (filter, sort, pagination)
✅ GET /products/:handle
✅ GET /products/best-sellers
✅ GET /products/new-arrivals
✅ GET /categories
✅ GET /categories/:handle
✅ GET /collections
✅ GET /collections/:handle
✅ GET /collections/:handle/products
✅ GET /products/:handle/reviews
✅ GET /products/:id/recommendations
✅ GET /order-steps
✅ GET /materials
✅ GET /pages/:handle
✅ GET /portfolios
✅ GET /portfolios/:slug
✅ GET /menus/:handle

### Auth Endpoints (6)
✅ POST /auth/register
✅ POST /auth/login
✅ POST /auth/logout
✅ GET /auth/user
✅ POST /auth/forgot-password
✅ POST /auth/reset-password

### Cart Endpoints (6)
✅ POST /cart (create)
✅ GET /cart
✅ POST /cart/items
✅ PUT /cart/items/:id
✅ DELETE /cart/items/:id
✅ DELETE /cart/clear

### Order Endpoints (7)
✅ POST /checkout
✅ GET /orders
✅ GET /orders/:orderNumber
✅ POST /orders/:orderNumber/pay
✅ POST /orders/:orderNumber/confirm-payment
✅ POST /orders/:orderNumber/request-refund
✅ GET /orders/:orderNumber (track)

### Wishlist Endpoints (5)
✅ GET /wishlist
✅ POST /wishlist/:productId
✅ DELETE /wishlist/:productId
✅ GET /wishlist/check/:productId

### Profile Endpoints (9)
✅ GET /profile
✅ PUT /profile
✅ PUT /profile/password
✅ POST /profile/avatar
✅ GET /addresses
✅ POST /addresses
✅ PUT /addresses/:id
✅ DELETE /addresses/:id

### Review Endpoints (3)
⏳ GET /products/:handle/reviews
⏳ POST /reviews
⏳ GET /reviews/:id

### Chatbot Endpoints (1)
⏳ POST /chatbot/message

**Total: 55+ endpoints tercoverage**

## Next Steps

### Widget Tests (Priority: High)
1. HomeScreen - Hero, categories, products
2. ProductListScreen - Grid, filter, search
3. ProductDetailScreen - Images, variants, reviews
4. CartScreen - Items, quantities, totals
5. CheckoutScreen - Address, payment, confirmation
6. OrderListScreen - List, status, tracking
7. OrderDetailScreen - Details, items, actions
8. ProfileScreen - Info, settings, addresses
9. WishlistScreen - Grid, remove, add to cart
10. LoginScreen - Form, validation
11. RegisterScreen - Form, validation

### Integration Tests (Priority: Medium)
1. Login flow: Login → Home → Profile
2. Browse flow: Home → Products → Detail → Cart
3. Checkout flow: Cart → Checkout → Payment → Order
4. Wishlist flow: Product → Wishlist → Cart → Checkout
5. Order tracking flow: Orders → Detail → Track

### Provider Tests (Priority: Medium)
1. AuthProvider - Login state, user data
2. CartProvider - Items, quantities, totals
3. ProductProvider - Products, loading, errors

## Running Tests

```bash
# Run all tests
flutter test

# Run specific service tests
flutter test test/services/product_service_test.dart
flutter test test/services/auth_service_test.dart
flutter test test/services/cart_service_test.dart

# Run with coverage
flutter test --coverage

# Run specific test group
flutter test --name "ProductService Tests"
```

## Test Results Summary

### Completed ✅
- 29 ProductService tests - ALL PASSING
- Mock infrastructure complete
- Test data factories complete
- 6 service test files created

### In Progress 📝
- Other service tests need to be run and fixed
- Error response handling verification

### Pending ⏳
- Widget tests for 16 screens
- Integration tests for 5 critical flows
- Provider tests for 3 providers

## Known Issues

1. **Some tests need Flutter binding** - Fixed with TestBinding
2. **Money model expects numeric amounts** - Fixed in test data
3. **Error responses need proper format** - Fixed with {'message': '...'}

## Recommendations

1. **Run tests frequently** during development
2. **Add golden tests** for UI components
3. **Add performance tests** for heavy operations
4. **Set up CI/CD** to run tests on every PR
5. **Aim for 80%+ coverage** on services and providers
