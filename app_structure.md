# Mitologi Clothing Mobile - Struktur Aplikasi

## Arsitektur Umum

Flutter app dengan **Clean Architecture** per fitur:
- `lib/core/` — foundation: theme, API, router, storage, utils, shared widgets
- `lib/features/<nama>/` — setiap fitur punya `data/`, `domain/models/`, `presentation/`
- `lib/widgets/` — shared/cross-feature UI components
- `lib/utils/` — utility functions

State management: **Provider** (ChangeNotifier pattern)
Routing: **GoRouter** (shell route + standalone routes)
Networking: **Dio** dengan interceptor
Font: **Google Fonts** (Plus Jakarta Sans)
Icons: **Phosphor Flutter** + **Material Symbols**

---

## Struktur File Lengkap

```
lib/
├── main.dart                                    # Entry point. Init semua repository + providers, lalu MaterialApp.router
│
├── core/
│   ├── api/
│   │   ├── api_client.dart                      # Dio instance + interceptor (auth token, error handling, logging)
│   │   ├── api_config.dart                      # Base URL dari env
│   │   ├── api_exception.dart                   # Structured exception class
│   │   └── api_response.dart                    # Generic wrapper: status, message, data, meta
│   │
│   ├── config/
│   │   └── shop_config.dart                     # Konstanta: shipping cost, Midtrans URL, payment defaults
│   │
│   ├── constants/
│   │   └── api_endpoints.dart                   # Semua endpoint path constant
│   │
│   ├── network/
│   │   ├── api_error.dart                       # ApiError exception class
│   │   └── response_normalizer.dart             # Normalisasi response API
│   │
│   ├── router/
│   │   └── app_router.dart                      # GoRouter: semua route definition + shell route + redirects
│   │
│   ├── storage/
│   │   ├── token_storage.dart                   # FlutterSecureStorage untuk auth token
│   │   └── cart_storage.dart                    # SharedPreferences untuk cart ID
│   │
│   ├── theme/
│   │   ├── app_colors.dart                      # Warna: primary (#0C1A2E), secondary/gold (#CA8A04), neutral, shadow, gradient, border radius
│   │   ├── app_theme.dart                       # ThemeData lengkap: color scheme, text theme, button themes, card, chip, input, snackbar, bottom sheet
│   │   ├── app_text_styles.dart                 # Typography system dengan Plus Jakarta Sans
│   │   └── app_spacing.dart                     # Spacing tokens (2,4,8,12,16,24,32...)
│   │
│   ├── utils/
│   │   ├── animations.dart                      # Durasi animasi + curve presets
│   │   ├── currency_formatter.dart              # Format IDR (Rp 1.000.000)
│   │   ├── debouncer.dart                       # Debounce utility
│   │   ├── error_mapper.dart                    # Dio exception → user-friendly message
│   │   ├── haptic_feedback.dart                 # Haptic feedback wrapper
│   │   ├── html_parser.dart                     # Parse HTML ke structured sections
│   │   ├── input_validator.dart                 # Validasi email, password, phone
│   │   ├── parser_utils.dart                    # Generic parsing: int, double, bool, date dari dynamic
│   │   └── responsive_utils.dart                # Breakpoints, device types, spacing calc
│   │
│   └── widgets/                                 # Base reusable widgets
│       ├── app_button.dart                      # Button variants + loading state
│       ├── app_image.dart                       # CachedNetworkImage + shimmer + error fallback
│       ├── glass_container.dart                 # Glassmorphism container
│       ├── luxury_button.dart                   # Premium button gold/white/ghost + shimmer
│       ├── premium_section_header.dart          # Eyebrow + title + subtitle + optional CTA
│       ├── section_header.dart                  # Title + see-all link
│       ├── skeleton_loading.dart                # Shimmer skeleton — berbagai preset layout
│       ├── empty_state.dart                     # Empty state dengan icon, message, action
│       ├── loading_indicator.dart               # Full-page loading + message
│       ├── loading_overlay.dart                 # Overlay loading di atas child
│       ├── custom_pull_to_refresh.dart          # RefreshIndicator wrapper
│       ├── animated_snackbar.dart               # Snackbar info/success/error
│       └── animated_button.dart                 # Animated loading button
│
├── utils/                                       # Cross-cutting utilities
│   ├── animations.dart
│   ├── debouncer.dart
│   ├── error_mapper.dart
│   ├── haptic_feedback.dart
│   ├── html_parser.dart
│   ├── input_validator.dart
│   └── responsive_utils.dart
│
├── widgets/                                     # Shared UI components (banyak duplikasi dari core/widgets/)
│   ├── common/
│   │   ├── skeleton_loading.dart                # Shimmer loader — 1.454 baris, banyak preset
│   │   ├── shimmer_image.dart                   # CachedNetworkImage + shimmer
│   │   ├── section_header.dart                  # Title + see-all
│   │   ├── empty_state.dart                     # Animated empty state
│   │   ├── loading_overlay.dart
│   │   ├── loading_indicator.dart
│   │   ├── animated_snackbar.dart
│   │   ├── animated_button.dart
│   │   ├── custom_pull_to_refresh.dart
│   │   ├── cached_image_widget.dart
│   │   ├── cart_icon_button.dart                # AppBar cart icon + badge
│   │   ├── cart_fly_to_animation.dart           # [stub] fly-to-cart animation
│   │   ├── add_to_cart_sheet.dart               # Bottom sheet setelah add-to-cart
│   │   ├── mitologi_sliver_app_bar.dart         # Re-export
│   │   ├── success_animations.dart              # [stub]
│   │   ├── staggered_entrance.dart              # Staggered list animation
│   │   ├── share_sheet.dart                     # Native share
│   │   ├── scroll_reveal.dart                   # Scroll fade/scale animation
│   │   ├── quick_view_sheet.dart                # Product quick preview bottom sheet
│   │   ├── interactive_widgets.dart             # InteractiveScale press animation
│   │   ├── confetti_celebration.dart            # [stub] confetti overlay
│   │   └── animated_stepper.dart                # Quantity stepper animated
│   │
│   ├── shared/
│   │   ├── product_card.dart                    # Product card: image 3:4, name, price, wishlist, badge
│   │   ├── mitologi_sliver_app_bar.dart         # Sliver app bar: gradient, title, back, cart, search
│   │   ├── success_animations.dart              # [stub]
│   │   ├── staggered_entrance.dart
│   │   ├── share_sheet.dart
│   │   ├── scroll_reveal.dart
│   │   ├── quick_view_sheet.dart
│   │   ├── mitologi_alert.dart                  # Custom alert dialog
│   │   ├── interactive_widgets.dart
│   │   ├── confetti_celebration.dart            # [stub]
│   │   └── animated_stepper.dart
│   │
│   ├── product/
│   │   └── product_card.dart                    # Product card alternatif (layout berbeda)
│   │
│   └── cms/
│       └── html_section_widget.dart             # Render HTML content ke widget
│
├── features/
│   │
│   ├── splash/
│   │   └── presentation/
│   │       └── splash_screen.dart               # Splash dengan logo animation + init callback
│   │
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_service.dart                # HTTP: login/register/logout/forgot/reset
│   │   │   └── auth_repository.dart             # Auth logic + token storage + session
│   │   ├── domain/models/
│   │   │   └── user.dart                        # User: id, name, email, phone, avatar
│   │   └── presentation/
│   │       ├── auth_view_model.dart             # ChangeNotifier: loading, error, current user
│   │       └── views/
│   │           ├── auth_scaffold.dart           # Shared layout: background, header, decor
│   │           ├── login_view.dart              # Login: email + password form
│   │           ├── register_view.dart           # Register: name, email, password, phone
│   │           ├── forgot_password_view.dart    # Forgot: email input + reset trigger
│   │           └── reset_password_view.dart     # Reset: token + password baru
│   │
│   ├── home/
│   │   ├── data/
│   │   │   ├── home_service.dart                # HTTP: landing page data, banners, categories, products
│   │   │   └── home_repository.dart             # Parse & aggregate semua data home
│   │   ├── domain/models/
│   │   │   ├── home_data_model.dart             # Aggregator semua section data
│   │   │   ├── banner_model.dart
│   │   │   ├── category_model.dart
│   │   │   ├── feature_model.dart
│   │   │   ├── facility_model.dart
│   │   │   ├── material_model.dart
│   │   │   ├── order_step_model.dart
│   │   │   ├── partner_model.dart
│   │   │   ├── portfolio_item_model.dart
│   │   │   ├── printing_method_model.dart
│   │   │   ├── product_pricing_model.dart
│   │   │   ├── site_settings_model.dart         # 327 baris — konfigurasi site lengkap
│   │   │   ├── team_member_model.dart
│   │   │   └── testimonial_model.dart
│   │   └── presentation/
│   │       ├── home_view_model.dart             # ChangeNotifier: semua data landing page
│   │       ├── main_shell.dart                  # Bottom navigation shell (Beranda, Katalog, Wishlist, Portfolio, Akun)
│   │       └── views/
│   │           ├── home_view.dart               # [2001 baris] MAIN SCREEN — hero + semua section
│   │           └── widgets/                     # Widget per-section (dipisah tapi banyak yg inline di home_view.dart)
│   │               ├── home_hero_section.dart
│   │               ├── home_hero_carousel.dart
│   │               ├── home_intro_section.dart
│   │               ├── home_features_section.dart
│   │               ├── home_categories_section.dart
│   │               ├── home_category_pricelist_section.dart
│   │               ├── home_product_grid.dart
│   │               ├── home_about_section.dart
│   │               ├── home_printing_methods_section.dart
│   │               ├── home_why_choose_us_section.dart
│   │               ├── home_facilities_section.dart
│   │               ├── home_guarantee_bonus_section.dart
│   │               ├── home_testimonials_section.dart
│   │               ├── home_pricing_section.dart
│   │               ├── home_portfolio_section.dart
│   │               ├── home_partners_section.dart
│   │               ├── home_order_flow_section.dart
│   │               ├── home_quick_links.dart
│   │               └── home_sections.dart        # [1471 baris] Central section composer
│   │
│   ├── catalog/
│   │   ├── data/
│   │   │   ├── catalog_service.dart             # HTTP: products, detail, search
│   │   │   └── catalog_repository.dart           # Map API → model + pagination
│   │   ├── domain/
│   │   │   ├── paginated_products.dart          # Value class: list, total, page, lastPage
│   │   │   └── catalog_query.dart               # Value class: search, category, sort, price range, page
│   │   ├── domain/models/
│   │   │   ├── product_model.dart               # Base: id, name, price, images, category, status
│   │   │   └── product_detail_model.dart        # Extends product: variants, reviews, options
│   │   └── presentation/
│   │       ├── catalog_view_model.dart          # ChangeNotifier: catalog state + filters
│   │       └── views/
│   │           ├── catalog_view.dart            # [659 baris] Grid + filter + search + pagination
│   │           └── product_detail_view.dart     # [1964 baris] PDP: gallery, variants, desc, reviews, CTA
│   │
│   ├── cart/
│   │   ├── data/
│   │   │   ├── cart_service.dart                # HTTP: cart CRUD
│   │   │   └── cart_repository.dart             # Cart service + local storage
│   │   ├── domain/models/
│   │   │   └── cart_model.dart                  # CartModel, CartItemModel
│   │   └── presentation/
│   │       ├── cart_view_model.dart             # ChangeNotifier: items, total, loading
│   │       ├── views/
│   │       │   └── cart_view.dart               # Cart screen: items, qty, total, checkout
│   │       └── widgets/
│   │           ├── cart_icon_button.dart         # AppBar cart icon + badge
│   │           ├── cart_fly_to_animation.dart    # [stub]
│   │           └── add_to_cart_sheet.dart        # Bottom sheet after add
│   │
│   ├── checkout/
│   │   ├── data/
│   │   │   ├── checkout_service.dart            # HTTP: addresses, shipping, checkout, orders
│   │   │   ├── checkout_repository.dart         # Checkout flow + order creation
│   │   │   └── shipping_service.dart            # [151 baris] RajaOngkir API
│   │   ├── domain/
│   │   │   ├── checkout_payload.dart            # Value class: cartId, addressId, shippingCost, paymentMethod
│   │   │   └── checkout_result.dart             # orderId, orderNumber, snapToken, total
│   │   ├── domain/models/
│   │   │   ├── address_model.dart               # Address: label, recipient, phone, prov/kota
│   │   │   ├── shipping_rate_model.dart         # Courier, service, cost, ETA
│   │   │   └── order_model.dart                 # [243 baris] Order + status + payment + tracking
│   │   └── presentation/
│   │       ├── checkout_view_model.dart         # ChangeNotifier: checkout flow
│   │       └── views/
│   │           ├── checkout_view.dart           # Main checkout: address, shipping, payment, summary
│   │           ├── checkout_success_screen.dart  # Success: confetti, order number, navigation
│   │           ├── addresses_screen.dart        # [760 baris] Address list + prov/kota/distrik selector
│   │           ├── manage_address_screen.dart   # [429 baris] Add/edit address form
│   │           └── midtrans_payment_screen.dart  # WebView Midtrans Snap + status handling
│   │
│   ├── wishlist/
│   │   ├── data/
│   │   │   ├── wishlist_service.dart            # HTTP: wishlist CRUD
│   │   │   └── wishlist_repository.dart         # Wishlist data fetching
│   │   ├── domain/models/
│   │   │   └── wishlist_item.dart               # WishlistItem: product id, name, price, image, slug
│   │   └── presentation/
│   │       ├── wishlist_screen.dart             # Wishlist grid + remove + navigate to detail
│   │       └── wishlist_provider.dart           # ChangeNotifier: items, add/remove/toggle
│   │
│   ├── profile/
│   │   ├── data/
│   │   │   ├── profile_service.dart             # HTTP: profile, orders, password
│   │   │   └── profile_repository.dart          # Profile + order history
│   │   └── presentation/
│   │       ├── profile_view_model.dart          # ChangeNotifier: profile, orders
│   │       └── views/
│   │           ├── profile_view.dart            # [782 baris] Profile + orders + settings + logout
│   │           ├── edit_profile_screen.dart     # Edit: name, phone, avatar
│   │           ├── change_password_screen.dart  # Change password form
│   │           ├── orders_list_screen.dart      # [357 baris] Orders list + status tabs
│   │           └── order_detail_screen.dart     # [904 baris] Order items, timeline, payment
│   │
│   ├── content/                                 # CMS Pages — konten statis dari API
│   │   ├── data/
│   │   │   ├── content_service.dart             # HTTP: CMS pages, portfolios, collections
│   │   │   └── content_repository.dart          # Fetch + parse CMS content
│   │   ├── domain/models/
│   │   │   └── content_models.dart              # CmsPage, PortfolioItem, Collection
│   │   └── presentation/
│   │       ├── content_provider.dart            # ChangeNotifier: CMS state
│   │       └── *.dart (14 screens):
│   │           ├── about_screen.dart            # [1019 baris] About Us: company, team, stats
│   │           ├── faq_screen.dart              # [289 baris] FAQ accordion
│   │           ├── promo_screen.dart            # [337 baris] Promo cards
│   │           ├── portfolio_screen.dart        # [237 baris] Portfolio gallery + category filter
│   │           ├── portfolio_detail_screen.dart # [282 baris] Portfolio item detail
│   │           ├── collection_screen.dart       # [157 baris] Collection listing
│   │           ├── cms_page_screen.dart         # [108 baris] Generic HTML CMS renderer
│   │           ├── kategori_screen.dart         # [141 baris] Category list
│   │           ├── kontak_screen.dart           # [486 baris] Contact: address, phone, email, map
│   │           ├── layanan_screen.dart          # [273 baris] Services/printing details
│   │           ├── kebijakan_pengembalian_screen.dart  # [537 baris] Return policy
│   │           ├── kebijakan_privasi_screen.dart       # [485 baris] Privacy policy
│   │           ├── syarat_ketentuan_screen.dart        # [513 baris] Terms & conditions
│   │           └── panduan_ukuran_screen.dart   # [895 baris] Size guide + charts
│   │
│   └── ai/                                      # AI Chatbot
│       ├── data/
│       │   ├── ai_service.dart                  # HTTP: POST /ai/chat
│       │   └── ai_repository.dart               # Ai logic + error handling
│       ├── domain/models/
│       │   └── ai_models.dart                   # ChatMessage, ChatResponse
│       └── presentation/
│           ├── chatbot_screen.dart              # Chat UI: bubble, input, conversation
│           └── chatbot_provider.dart            # ChangeNotifier: messages, loading
│
├── assets/
│   └── images/                                  # Gambar statis (logo, etc.)
│
├── design.md                                    # [1312 baris] Dokumentasi redesign UI
│
└── pubspec.yaml                                 # Dependencies: provider, go_router, dio, google_fonts,
                                                  # cached_network_image, shimmer, flutter_svg,
                                                  # phosphor_flutter, webview_flutter, flutter_html, dll.
```

---

## Routing (GoRouter)

### Shell Routes (dengan Bottom Navigation)
| Path | Screen | Nav Label |
|------|--------|-----------|
| `/` | HomeView | Beranda |
| `/products` | CatalogView | Katalog |
| `/wishlist` | WishlistScreen | Wishlist |
| `/portfolio-tab` | PortfolioScreen | Portfolio |
| `/profile` | ProfileView | Akun |

### Standalone Routes (full screen, tanpa bottom nav)
| Path | Screen |
|------|--------|
| `/login` | LoginView |
| `/register` | RegisterView |
| `/forgot-password` | ForgotPasswordView |
| `/reset-password` | ResetPasswordView |
| `/product/:slug` | ProductDetailView |
| `/cart` | CartView |
| `/checkout` | CheckoutView |
| `/checkout/success` | CheckoutSuccessScreen |
| `/chatbot` | ChatbotScreen |
| `/pages/:handle` | CmsPageScreen |
| `/portfolio` | PortfolioScreen |
| `/portfolio/:slug` | PortfolioDetailScreen |
| `/tentang-kami` | AboutScreen |
| `/kontak` | KontakScreen |
| `/collections/:handle` | CollectionScreen |
| `/orders` | OrdersListScreen |
| `/orders/:orderNumber` | OrderDetailScreen |
| `/profile/addresses` | AddressesScreen |
| `/profile/edit` | EditProfileScreen |
| `/kategori` | KategoriScreen |
| `/faq` | FaqScreen |
| `/layanan` | LayananScreen |
| `/panduan-ukuran` | PanduanUkuranScreen |
| `/promo` | PromoScreen |
| `/kebijakan-pengembalian` | KebijakanPengembalianScreen |
| `/kebijakan-privasi` | KebijakanPrivasiScreen |
| `/syarat-ketentuan` | SyaratKetentuanScreen |
| `/privacy-policy` | → redirect ke `/kebijakan-privasi` |
| `/terms-of-service` | → redirect ke `/syarat-ketentuan` |
| `/terms-conditions` | → redirect ke `/syarat-ketentuan` |
| `/search?q=` | → redirect ke `/products?q=` |

---

## Bottom Navigation (MainShell)

5 tabs di bottom nav dengan custom container elevated + pill indicator:

| Tab | Icon (regular/fill) | Route |
|-----|---------------------|-------|
| Beranda | house | `/` |
| Katalog | storefront | `/products` |
| Wishlist | heart | `/wishlist` |
| Portfolio | images | `/portfolio-tab` |
| Akun | user | `/profile` |

---

## Pattern per Feature (contoh: Home)

Setiap fitur mengikuti struktur yang sama:

```
features/<nama>/
├── data/
│   ├── <nama>_service.dart         # HTTP calls via Dio
│   └── <nama>_repository.dart      # Service + parsing → model
├── domain/
│   └── models/
│       └── <nama>_model.dart        # Data class (Equatable)
└── presentation/
    ├── <nama>_view_model.dart       # ChangeNotifier (Provider)
    ├── views/
    │   └── <nama>_view.dart         # Screen widget
    └── widgets/                     # (optional) widgets spesifik screen
```

- **Service** → pure HTTP (Dio), return `ApiResponse<T>` atau `Response`
- **Repository** → panggil service, map JSON → model, handle error
- **ViewModel/Provider** → ChangeNotifier dengan state: `isLoading`, `error`, data
- **View** → `Consumer` / `context.watch` dari ViewModel

---

## Design System

### Warna
| Token | Value | Penggunaan |
|-------|-------|------------|
| `primary` | `#0C1A2E` (dark navy) | CTA, selected nav, header |
| `secondary` | `#CA8A04` (gold) | Aksen, badge, gradient premium |
| `background` | `#F8FAFC` | Scaffold background |
| `surface` | `#FFFFFF` | Card, sheet |
| `error` | `#BA1A1A` | Error states |
| `success` | `#2E7D32` | Success states |

### Typography
- Font: **Plus Jakarta Sans** (via `google_fonts`)
- Weight dominan: regular (400) + bold/semibold (600-800)
- Headline: 22-34sp, bold, letter spacing negatif
- Body: 14-16sp, regular
- Label/CTA: 12-14sp, bold, letter spacing positif

### Spacing
- Base unit: 4 (kelipatan 4)
- Padding horizontal default: 16-24px
- Radius: xs(6), sm(10), md(14), lg(18), xl(24), full(999)

---

## Catatan Penting

1. **Ada duplikasi widget** antara `lib/widgets/common/`, `lib/widgets/shared/`, dan `lib/core/widgets/` — file yang sama muncul di beberapa tempat
2. **Home screen** sebagian besar inline di `home_view.dart` (2001 baris) dan `home_sections.dart` (1471 baris) — banyak widget section yang sudah dipisah ke folder `widgets/` tapi tidak semuanya dipakai
3. **Design.md** (1312 baris) berisi spesifikasi redesign UI yang sangat detail — ini adalah panduan target tampilan yang diinginkan
4. **Stub/widget kosong**: `success_animations.dart`, `confetti_celebration.dart`, `cart_fly_to_animation.dart` — method kosong/blum implementasi
5. **Content feature** punya 14 screen sendiri — ini adalah halaman statis/CMS (About, FAQ, Kontak, Portfolio, Privasi, Syarat, dll)
