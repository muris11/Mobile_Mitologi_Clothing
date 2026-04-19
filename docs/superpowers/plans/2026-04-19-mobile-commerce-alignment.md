# Mobile Commerce Alignment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Menyamakan perilaku aplikasi mobile dengan referensi nextjs-commerce untuk alur alamat, wishlist, detail produk (ulasan anonim + rekomendasi), cart, checkout Midtrans, dan halaman statis tanpa data dummy.

**Architecture:** Perbaikan dilakukan di service/provider/screen mobile dengan mempertahankan kontrak API Laravel yang sama dengan web. Alur checkout disederhanakan menjadi Midtrans-only dan komponen ringkasan mengikuti sumber data backend nyata. Data presentasi yang bertentangan dengan requirement (nama ulasan asli, biaya dummy, metode pembayaran manual) dihapus atau disesuaikan pada titik pemetaan data dan UI.

**Tech Stack:** Flutter, Dart, Provider, GoRouter, http client, flutter_test.

---

### Task 1: Selaraskan kontrak cart dan tambah guard regresi add-to-cart

**Files:**
- Modify: `lib/services/cart_service.dart`
- Modify: `lib/screens/product/product_detail_screen.dart`
- Modify: `lib/screens/wishlist/wishlist_screen.dart`
- Test: `test/services/cart_service_test.dart`
- Test: `test/screens/cart/add_to_cart_regression_test.dart` (create)

- [ ] **Step 1: Write failing test untuk payload add item yang konsisten**

```dart
// test/services/cart_service_test.dart

test('addItem mengirim merchandise_id dari variant id yang valid', () async {
  late http.Request capturedRequest;
  final recordingClient = MockClient((request) async {
    capturedRequest = request;
    return http.Response(
      jsonEncode({'cart': TestHelpers.sampleCart}),
      200,
      headers: {'content-type': 'application/json'},
    );
  });

  final service = CartService(ApiService(client: recordingClient));
  await service.addItem(merchandiseId: 'gid://shopify/ProductVariant/123', quantity: 1);

  final payload = jsonDecode(capturedRequest.body) as Map<String, dynamic>;
  expect(payload['merchandise_id'], 'gid://shopify/ProductVariant/123');
  expect(payload['quantity'], 1);
});
```

- [ ] **Step 2: Run test to verify it fails (RED)**

Run: `flutter test test/services/cart_service_test.dart`
Expected: FAIL pada assertion payload atau flow ID.

- [ ] **Step 3: Write minimal implementation untuk sumber merchandiseId yang valid**

```dart
// lib/screens/product/product_detail_screen.dart (method _addToCart)
final merchandiseId = _selectedVariant?.id;
if (merchandiseId == null || merchandiseId.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Varian produk tidak valid')),
  );
  return;
}

final success = await cartProvider.addItem(
  merchandiseId: merchandiseId,
  quantity: _quantity,
);
```

```dart
// lib/screens/wishlist/wishlist_screen.dart (method _addToCart)
final merchandiseId = product.firstVariant?.id;
if (merchandiseId == null || merchandiseId.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Varian produk tidak tersedia')),
  );
  return;
}

final success = await cartProvider.addItem(
  merchandiseId: merchandiseId,
  quantity: 1,
);
```

```dart
// lib/services/cart_service.dart (body addItem)
body: {
  'merchandise_id': merchandiseId,
  'quantity': quantity,
},
```

- [ ] **Step 4: Add regression widget test untuk add-to-cart dari product detail**

```dart
// test/screens/cart/add_to_cart_regression_test.dart

testWidgets('tap Keranjang menambah item dan cart tidak kosong', (tester) async {
  // setup provider fake + product variant valid
  // tap tombol Keranjang di ProductDetailScreen
  // assert cartProvider.items bertambah
});
```

- [ ] **Step 5: Run tests to verify they pass (GREEN)**

Run: `flutter test test/services/cart_service_test.dart test/screens/cart/add_to_cart_regression_test.dart`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/services/cart_service.dart lib/screens/product/product_detail_screen.dart lib/screens/wishlist/wishlist_screen.dart test/services/cart_service_test.dart test/screens/cart/add_to_cart_regression_test.dart
git commit -m "fix(mobile): align cart item payload and variant id handling"
```

### Task 2: Perbaiki persistence wishlist agar tersimpan dan tampil konsisten

**Files:**
- Modify: `lib/features/wishlist/presentation/wishlist_provider.dart`
- Modify: `lib/screens/wishlist/wishlist_screen.dart`
- Modify: `lib/features/wishlist/data/wishlist_service_adapter.dart` (jika perlu sinkron return type)
- Test: `test/features/wishlist/wishlist_toggle_regression_test.dart`
- Test: `test/screens/wishlist_screen_test.dart`

- [ ] **Step 1: Write failing test untuk sinkronisasi IDs provider dengan data backend**

```dart
// test/features/wishlist/wishlist_toggle_regression_test.dart

test('toggle wishlist memperbarui ids sesuai hasil backend terbaru', () async {
  final provider = WishlistProvider(fakeSource);
  await provider.load();
  await provider.toggle(10);
  expect(provider.ids.contains(10), true);

  await provider.load();
  expect(provider.ids.contains(10), true);
});
```

- [ ] **Step 2: Run test to verify it fails (RED)**

Run: `flutter test test/features/wishlist/wishlist_toggle_regression_test.dart`
Expected: FAIL bila state lokal tidak sinkron setelah refresh.

- [ ] **Step 3: Write minimal implementation untuk refresh source-of-truth setelah toggle**

```dart
// lib/features/wishlist/presentation/wishlist_provider.dart
Future<void> toggle(int productId) async {
  if (_ids.contains(productId)) {
    await _source.remove(productId);
  } else {
    await _source.save(productId);
  }
  final latest = await _source.fetchWishlistIds();
  _ids
    ..clear()
    ..addAll(latest);
  notifyListeners();
}
```

```dart
// lib/screens/wishlist/wishlist_screen.dart
await wishlistProvider.load();
final items = await wishlistService.getWishlist();
setState(() {
  _wishlistItems = items.where((p) => wishlistProvider.ids.contains(p.id)).toList();
  _isLoading = false;
  _needsLogin = false;
});
```

- [ ] **Step 4: Tambah widget test screen wishlist memuat item tersimpan**

```dart
// test/screens/wishlist_screen_test.dart

testWidgets('wishlist screen menampilkan item yang sudah disimpan', (tester) async {
  // arrange fake service returns product in wishlist
  // pump WishlistScreen
  // expect product title terlihat
});
```

- [ ] **Step 5: Run tests to verify pass (GREEN)**

Run: `flutter test test/features/wishlist/wishlist_toggle_regression_test.dart test/screens/wishlist_screen_test.dart`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/wishlist/presentation/wishlist_provider.dart lib/screens/wishlist/wishlist_screen.dart lib/features/wishlist/data/wishlist_service_adapter.dart test/features/wishlist/wishlist_toggle_regression_test.dart test/screens/wishlist_screen_test.dart
git commit -m "fix(mobile): persist and render wishlist from backend state"
```

### Task 3: Selaraskan checkout menjadi Midtrans-only dan ringkasan tanpa dummy

**Files:**
- Modify: `lib/screens/checkout/checkout_screen.dart`
- Modify: `lib/providers/checkout_provider.dart`
- Modify: `lib/services/order_service.dart` (hanya jika perlu untuk token/url normalization)
- Test: `test/providers/checkout_provider_test.dart`
- Test: `test/screens/checkout/checkout_screen_test.dart` (create)

- [ ] **Step 1: Write failing test checkout summary tanpa insurance dummy**

```dart
// test/providers/checkout_provider_test.dart

test('total checkout = subtotal + shipping saja', () async {
  final provider = buildCheckoutProvider(subtotal: 389000, shipping: 0);
  await provider.load();
  expect(provider.total, 389000);
});
```

- [ ] **Step 2: Run test to verify fail (RED)**

Run: `flutter test test/providers/checkout_provider_test.dart`
Expected: FAIL jika total masih memasukkan biaya dummy.

- [ ] **Step 3: Write minimal implementation untuk Midtrans-only dan UI text sesuai requirement**

```dart
// lib/screens/checkout/checkout_screen.dart
// hapus _paymentMethods manual, tetapkan:
String _paymentMethod = 'midtrans';

// remove payment section dari sliver list
// ubah summary:
// - Subtotal
// - Pengiriman: Gratis Ongkir (jika shipping 0)
// - Total Bayar
// tanpa Asuransi Pengiriman
```

```dart
// lib/providers/checkout_provider.dart
void setPaymentMethod(String method) {
  _paymentMethod = 'midtrans';
  notifyListeners();
}
```

- [ ] **Step 4: Tambah widget test tampilan checkout**

```dart
// test/screens/checkout/checkout_screen_test.dart

testWidgets('checkout menampilkan Alamat Pengiriman dan Ringkasan Pesanan sesuai flow', (tester) async {
  // pump checkout
  // expect text: Checkout, Alamat Pengiriman, Ringkasan Pesanan, Total Bayar
  // expect tidak ada text: Transfer Bank Manual, COD, Asuransi Pengiriman
});
```

- [ ] **Step 5: Run tests to verify pass (GREEN)**

Run: `flutter test test/providers/checkout_provider_test.dart test/screens/checkout/checkout_screen_test.dart`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/screens/checkout/checkout_screen.dart lib/providers/checkout_provider.dart lib/services/order_service.dart test/providers/checkout_provider_test.dart test/screens/checkout/checkout_screen_test.dart
git commit -m "fix(mobile): align checkout flow to midtrans-only and real summary"
```

### Task 4: Anonimkan nama ulasan pembeli di detail produk

**Files:**
- Modify: `lib/screens/product/product_detail_screen.dart`
- Test: `test/features/product_detail/product_detail_provider_test.dart`
- Test: `test/screens/product/review_anonymization_test.dart` (create)

- [ ] **Step 1: Write failing test untuk anonymized display name**

```dart
// test/screens/product/review_anonymization_test.dart

test('nama reviewer ditampilkan anonim meski API kirim nama asli', () {
  final rawName = 'Aryan Saputra';
  final rendered = anonymizeReviewName(rawName);
  expect(rendered, 'A*** S******');
});
```

- [ ] **Step 2: Run test to verify fail (RED)**

Run: `flutter test test/screens/product/review_anonymization_test.dart`
Expected: FAIL karena helper belum ada.

- [ ] **Step 3: Write minimal implementation anonymizer and apply in review UI**

```dart
// lib/screens/product/product_detail_screen.dart
String _anonymizeReviewerName(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return 'Anonim';
  return trimmed
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .map((part) => part.length <= 1 ? '*' : '${part[0]}${'*' * (part.length - 1)}')
      .join(' ');
}

// saat render reviewerName:
final displayName = _anonymizeReviewerName(reviewerName);
```

- [ ] **Step 4: Run tests to verify pass (GREEN)**

Run: `flutter test test/screens/product/review_anonymization_test.dart test/features/product_detail/product_detail_provider_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/screens/product/product_detail_screen.dart test/screens/product/review_anonymization_test.dart test/features/product_detail/product_detail_provider_test.dart
git commit -m "fix(mobile): anonymize reviewer names on product detail"
```

### Task 5: Pastikan rekomendasi produk tampil di detail produk

**Files:**
- Modify: `lib/services/product_service.dart`
- Modify: `lib/screens/product/product_detail_screen.dart`
- Modify: `lib/features/recommendations/data/recommendation_service.dart`
- Test: `test/services/product_service_test.dart`
- Test: `test/features/recommendations/recommendation_service_test.dart`

- [ ] **Step 1: Write failing test fallback rekomendasi saat endpoint utama kosong**

```dart
// test/services/product_service_test.dart

test('getProductRecommendations fallback ke /recommendations jika endpoint product kosong', () async {
  // mock /products/{id}/recommendations => []
  // mock /recommendations => [product]
  // expect hasil minimal 1
});
```

- [ ] **Step 2: Run test to verify fail (RED)**

Run: `flutter test test/services/product_service_test.dart`
Expected: FAIL karena fallback belum ada.

- [ ] **Step 3: Write minimal implementation fallback recommendation chain**

```dart
// lib/services/product_service.dart
Future<List<Product>> getProductRecommendations(int productId, {int limit = 5}) async {
  final primary = await _apiService.get(
    ApiEndpoints.productRecommendations(productId),
    queryParams: {'limit': limit.toString()},
  );
  final primaryData = _unwrapResponse(primary);
  final primaryProducts = _listFromResponse(primaryData, ['products', 'recommendations', 'items', 'results']);
  final parsedPrimary = primaryProducts.whereType<Map<String, dynamic>>().map(Product.fromJson).toList();
  if (parsedPrimary.isNotEmpty) return parsedPrimary;

  final fallback = await _apiService.get(ApiEndpoints.recommendations, queryParams: {'limit': limit.toString()});
  final fallbackData = _unwrapResponse(fallback);
  final fallbackProducts = _listFromResponse(fallbackData, ['products', 'recommendations', 'items', 'results']);
  return fallbackProducts.whereType<Map<String, dynamic>>().map(Product.fromJson).toList();
}
```

```dart
// lib/features/recommendations/data/recommendation_service.dart
class RecommendationService {
  bool get shouldFailOpenOnRecommendationError => true;
}
```

- [ ] **Step 4: Run tests to verify pass (GREEN)**

Run: `flutter test test/services/product_service_test.dart test/features/recommendations/recommendation_service_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/services/product_service.dart lib/screens/product/product_detail_screen.dart lib/features/recommendations/data/recommendation_service.dart test/services/product_service_test.dart test/features/recommendations/recommendation_service_test.dart
git commit -m "fix(mobile): ensure product recommendations are always shown"
```

### Task 6: Samakan halaman statis (About, Privacy, FAQ, Terms) dengan konten backend CMS

**Files:**
- Modify: `lib/screens/cms/content_screen.dart`
- Modify: `lib/services/product_service.dart`
- Modify: `lib/app.dart` (route mapping bila handle mismatch)
- Test: `test/screens/content_screen_test.dart`
- Test: `test/features/content/content_provider_test.dart`

- [ ] **Step 1: Write failing test slug mapping static pages**

```dart
// test/screens/content_screen_test.dart

testWidgets('content screen memuat handle tentang-kami dari endpoint pages', (tester) async {
  // pump route /tentang-kami
  // mock getPage('tentang-kami')
  // expect judul dan isi dari API muncul
});
```

- [ ] **Step 2: Run test to verify fail (RED)**

Run: `flutter test test/screens/content_screen_test.dart`
Expected: FAIL jika masih fallback dummy/local.

- [ ] **Step 3: Write minimal implementation remove dummy fallback and enforce CMS-only**

```dart
// lib/screens/cms/content_screen.dart
// jika API page kosong/error -> tampilkan state error + retry
// jangan inject konten hardcoded dummy.
```

```dart
// lib/app.dart
// pastikan route handle:
// /tentang-kami -> ContentScreen(handle: 'tentang-kami')
// /kebijakan-privasi -> ContentScreen(handle: 'kebijakan-privasi')
// /faq -> ContentScreen(handle: 'faq')
// /syarat-ketentuan -> ContentScreen(handle: 'syarat-ketentuan')
```

- [ ] **Step 4: Run tests to verify pass (GREEN)**

Run: `flutter test test/screens/content_screen_test.dart test/features/content/content_provider_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/screens/cms/content_screen.dart lib/services/product_service.dart lib/app.dart test/screens/content_screen_test.dart test/features/content/content_provider_test.dart
git commit -m "fix(mobile): load static legal pages from cms without dummy content"
```

### Task 7: Verifikasi akhir end-to-end mobile parity

**Files:**
- Modify: `integration_test/checkout_flow_test.dart` (create/update)
- Modify: `integration_test/wishlist_cart_flow_test.dart` (create/update)

- [ ] **Step 1: Write failing integration test wishlist -> cart -> checkout**

```dart
// integration_test/wishlist_cart_flow_test.dart

testWidgets('wishlist item bisa dipindah ke cart dan muncul di checkout summary', (tester) async {
  // login mock
  // add wishlist
  // add to cart
  // open checkout
  // assert item + subtotal + total bayar
});
```

- [ ] **Step 2: Run integration test to verify fail (RED)**

Run: `flutter test integration_test/wishlist_cart_flow_test.dart`
Expected: FAIL sebelum semua fix terpenuhi.

- [ ] **Step 3: Write/adjust checkout integration test for Midtrans-only**

```dart
// integration_test/checkout_flow_test.dart

testWidgets('checkout lanjut ke midtrans tanpa memilih metode pembayaran manual', (tester) async {
  // assert tidak ada opsi transfer manual/cod
  // assert submit menghasilkan snap token/url handler
});
```

- [ ] **Step 4: Run full targeted verification (GREEN)**

Run: `flutter test test/providers/cart_provider_test.dart test/providers/checkout_provider_test.dart test/services/cart_service_test.dart test/services/wishlist_service_test.dart test/services/product_service_test.dart test/screens/wishlist_screen_test.dart test/screens/content_screen_test.dart integration_test/wishlist_cart_flow_test.dart integration_test/checkout_flow_test.dart`
Expected: PASS semua.

- [ ] **Step 5: Run static checks**

Run: `flutter analyze`
Expected: No issues found.

- [ ] **Step 6: Commit verification updates**

```bash
git add integration_test/checkout_flow_test.dart integration_test/wishlist_cart_flow_test.dart
git commit -m "test(mobile): add parity regression coverage for commerce flows"
```

## Spec Coverage Check

- Alamat tersimpan dan tampil di checkout: dicakup Task 3 + Task 7.
- Wishlist tersimpan dan muncul di halaman wishlist: dicakup Task 2.
- Ulasan pembeli anonim: dicakup Task 4.
- Rekomendasi produk di detail: dicakup Task 5.
- Tambah ke keranjang tersimpan: dicakup Task 1.
- Checkout sesuai flow (alamat, ringkasan, gratis ongkir, total bayar) dan Midtrans tanpa metode manual: dicakup Task 3.
- Hapus data dummy dan samakan halaman tentang-kami/kebijakan privasi/faq/syarat-ketentuan: dicakup Task 6.

## Placeholder Scan & Consistency

- Tidak ada TBD/TODO implementasi di plan.
- Nama file, method, dan test target konsisten dengan struktur proyek mobile saat ini.
- Scope tetap fokus fitur yang diminta, tanpa refactor non-esensial.
