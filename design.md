# design.md — Redesign UI/UX Mitologi Clothing Mobile

## 1. Tujuan Redesign

Redesign ini bertujuan membuat aplikasi **Mitologi Clothing Mobile** terlihat lebih modern, simple, rapi, premium, dan responsive tanpa mengubah logic aplikasi yang sudah ada.

Fokus redesign:

* Memperbaiki tampilan visual seluruh screen.
* Membuat layout lebih rapi dan mudah dibaca.
* Membuat pengalaman belanja terasa seperti gabungan dari marketplace modern seperti Shopee, Tokopedia, TikTok Shop, dan fashion commerce premium.
* Menjaga identitas brand Mitologi Clothing dengan warna utama navy dan gold.
* Membuat typography lebih konsisten.
* Membuat spacing, radius, grid, dan card lebih seragam.
* Membuat aplikasi tetap ringan dan mudah dikembangkan.
* Tidak mengubah API, repository, provider, route, model, cart logic, checkout logic, payment logic, atau business logic lain.

---

## 2. Prinsip Utama Desain

### 2.1 Simple

Tampilan tidak boleh terlalu ramai. Walaupun terinspirasi dari marketplace besar, desain Mitologi Clothing harus tetap bersih.

Prinsip simple:

* Kurangi dekorasi berlebihan.
* Gunakan card yang bersih.
* Hindari terlalu banyak gradient dalam satu screen.
* Gunakan icon seperlunya.
* Gunakan whitespace yang cukup.
* Jangan menaruh terlalu banyak informasi dalam satu area kecil.

### 2.2 Rapi

Semua elemen harus memiliki alignment yang jelas.

Aturan rapi:

* Semua section punya padding horizontal konsisten.
* Semua title section rata kiri.
* Semua product card dalam grid harus punya tinggi yang konsisten.
* Semua button utama punya radius dan tinggi yang sama.
* Semua screen menggunakan spacing system yang sama.

### 2.3 Premium

Karena brand clothing dan printing, aplikasi harus terasa lebih premium dibanding marketplace biasa.

Ciri premium:

* Warna navy sebagai dasar kepercayaan.
* Gold sebagai aksen eksklusif.
* Typography tegas tapi tetap modern.
* Product image lebih dominan.
* Card tidak terlalu banyak border.
* Shadow halus, bukan shadow berat.
* CTA dibuat jelas dan elegan.

### 2.4 Marketplace Friendly

User tetap harus merasa aplikasi ini mudah digunakan seperti marketplace.

Ciri marketplace friendly:

* Search mudah ditemukan.
* Product card langsung menampilkan gambar, nama, harga, badge, dan wishlist.
* Filter mudah dipakai.
* Cart mudah diakses.
* Checkout ringkas.
* Bottom navigation konsisten.
* Harga dan promo mudah terlihat.

### 2.5 Social Commerce Feel

Sentuhan TikTok Shop dapat diterapkan melalui:

* Quick view bottom sheet.
* Product preview yang visual.
* Section portfolio yang lebih image-first.
* CTA cepat seperti “Tambah ke Keranjang”.
* Badge populer, promo, dan best seller.
* Animasi ringan ketika tap wishlist atau add to cart.

---

## 3. Design Direction

### 3.1 Nama Konsep

**Mitologi Premium Commerce UI**

Konsep ini menggabungkan:

* Clean marketplace layout.
* Fashion product discovery.
* Premium navy-gold branding.
* Responsive mobile-first experience.
* Simple and elegant checkout.

### 3.2 Mood Visual

Mood desain:

* Clean
* Premium
* Modern
* Trustworthy
* Fast
* Friendly
* Fashion-oriented
* Easy to scan

### 3.3 Referensi Rasa Desain

Bukan meniru mentah-mentah, tetapi mengambil pola terbaik:

#### Dari Shopee

* Product grid cepat dibaca.
* Badge promo jelas.
* CTA belanja cepat.
* Banyak item terlihat dalam satu layar.

#### Dari Tokopedia

* Layout lebih rapi dan bersih.
* Filter lebih terstruktur.
* Informasi produk terasa lebih trustworthy.
* Checkout terasa formal dan jelas.

#### Dari TikTok Shop

* Product discovery lebih visual.
* Quick action terasa cepat.
* Gambar produk lebih dominan.
* Interaksi terasa ringan dan engaging.

#### Dari Fashion Commerce Premium

* Typography lebih elegan.
* Spacing lebih lega.
* Hero section lebih brand-oriented.
* Warna lebih terkendali.
* Detail produk lebih storytelling.

---

## 4. Batasan Redesign

Redesign hanya boleh menyentuh:

* `core/theme/app_colors.dart`
* `core/theme/app_theme.dart`
* `core/theme/app_text_styles.dart`
* `core/theme/app_spacing.dart`
* `core/utils/responsive_utils.dart`
* `core/widgets/*`
* `widgets/common/*`
* `widgets/shared/*`
* Layout widget pada screen presentation
* Padding, margin, radius, shadow
* Typography
* Product card UI
* App bar UI
* Bottom navigation UI
* Section layout
* Empty state
* Loading state
* Error state
* Skeleton state
* Bottom sheet UI
* Dialog UI
* Form UI

Redesign tidak boleh mengubah:

* API endpoint
* Dio configuration
* Repository behavior
* Provider state logic
* ChangeNotifier flow
* GoRouter route path
* Cart calculation
* Checkout calculation
* Payment Midtrans behavior
* RajaOngkir behavior
* Auth token storage
* Model parsing
* Business rules

---

## 5. Design Tokens

## 5.1 Color System

### Primary Brand Colors

```dart
primary: Color(0xFF0C1A2E)
primarySoft: Color(0xFF132A46)
primaryDark: Color(0xFF07111F)
secondary: Color(0xFFCA8A04)
secondarySoft: Color(0xFFF6C766)
secondaryDark: Color(0xFF9A6700)
```

### Background Colors

```dart
background: Color(0xFFF8FAFC)
backgroundWarm: Color(0xFFFBF7EF)
surface: Color(0xFFFFFFFF)
surfaceSoft: Color(0xFFF1F5F9)
surfaceMuted: Color(0xFFEFF3F8)
```

### Text Colors

```dart
textPrimary: Color(0xFF111827)
textSecondary: Color(0xFF475569)
textTertiary: Color(0xFF64748B)
textMuted: Color(0xFF94A3B8)
textInverse: Color(0xFFFFFFFF)
```

### Border Colors

```dart
border: Color(0xFFE2E8F0)
borderSoft: Color(0xFFF1F5F9)
borderDark: Color(0xFFCBD5E1)
```

### Semantic Colors

```dart
success: Color(0xFF16A34A)
successSoft: Color(0xFFEAF7EE)
warning: Color(0xFFF59E0B)
warningSoft: Color(0xFFFFF7E6)
error: Color(0xFFDC2626)
errorSoft: Color(0xFFFEECEC)
info: Color(0xFF2563EB)
infoSoft: Color(0xFFEFF6FF)
```

### Promo Colors

```dart
promoRed: Color(0xFFE11D48)
promoOrange: Color(0xFFF97316)
promoPink: Color(0xFFDB2777)
flashSale: Color(0xFFFF4D00)
discount: Color(0xFFEF4444)
```

### Shadow Colors

```dart
shadowSoft: Color(0x14000000)
shadowMedium: Color(0x22000000)
shadowNavy: Color(0x260C1A2E)
shadowGold: Color(0x33CA8A04)
```

---

## 5.2 Gradient System

Gradient tidak boleh dipakai berlebihan. Gunakan hanya untuk area tertentu.

### Hero Gradient

```dart
LinearGradient(
  colors: [
    Color(0xFF0C1A2E),
    Color(0xFF132A46),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

### Gold CTA Gradient

```dart
LinearGradient(
  colors: [
    Color(0xFFF6C766),
    Color(0xFFCA8A04),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

### Promo Gradient

```dart
LinearGradient(
  colors: [
    Color(0xFFFF4D00),
    Color(0xFFE11D48),
  ],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
)
```

### Soft Background Gradient

```dart
LinearGradient(
  colors: [
    Color(0xFFF8FAFC),
    Color(0xFFFBF7EF),
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
)
```

---

## 5.3 Radius System

Gunakan radius konsisten.

```dart
radiusXs: 6
radiusSm: 10
radiusMd: 14
radiusLg: 18
radiusXl: 24
radius2xl: 32
radiusFull: 999
```

Penggunaan:

| Komponen       |                    Radius |
| -------------- | ------------------------: |
| Small badge    |                       999 |
| Input field    |                        14 |
| Product card   |                        18 |
| Image product  |                        16 |
| Bottom sheet   | 28 top-left, 28 top-right |
| Primary button |                        16 |
| Icon button    |                        14 |
| Promo banner   |                        24 |
| Dialog         |                        28 |

---

## 5.4 Spacing System

Gunakan base 4.

```dart
space2: 2
space4: 4
space6: 6
space8: 8
space10: 10
space12: 12
space14: 14
space16: 16
space20: 20
space24: 24
space28: 28
space32: 32
space40: 40
space48: 48
space64: 64
```

Default spacing:

| Area                              | Spacing |
| --------------------------------- | ------: |
| Screen horizontal padding mobile  |      16 |
| Screen horizontal padding tablet  |      24 |
| Screen horizontal padding desktop |      32 |
| Section vertical gap              |      24 |
| Card inner padding                |   14-16 |
| Product grid gap mobile           |      12 |
| Product grid gap tablet           |      16 |
| Button icon gap                   |       8 |
| Title-subtitle gap                |       6 |
| Form field gap                    |      14 |
| Checkout block gap                |      16 |

---

# 6. Typography System

## 6.1 Font Utama

Font utama tetap:

```dart
Plus Jakarta Sans
```

Alasan:

* Modern.
* Cocok untuk marketplace.
* Cocok untuk brand fashion.
* Mudah dibaca.
* Sudah dipakai di project.
* Terasa lebih premium dibanding font default.

## 6.2 Prinsip Typography

Typography harus:

* Mudah dibaca di mobile.
* Tidak terlalu kecil.
* Tidak terlalu berat.
* Konsisten antar screen.
* Menonjolkan harga dan CTA.
* Membuat hierarchy jelas antara title, subtitle, body, label, dan metadata.

## 6.3 Font Weight

Gunakan weight berikut:

| Weight        | Penggunaan                          |
| ------------- | ----------------------------------- |
| 400 Regular   | Body text, deskripsi                |
| 500 Medium    | Label, menu, metadata penting       |
| 600 SemiBold  | Section title, product name, button |
| 700 Bold      | Harga, screen title, hero title     |
| 800 ExtraBold | Hero headline tertentu saja         |

Hindari menggunakan 800 terlalu sering agar tidak terasa berat.

---

## 6.4 Type Scale Mobile

### Display

Untuk hero title besar.

```dart
displayLarge: 34sp / 42 line height / weight 800
displayMedium: 30sp / 38 line height / weight 800
displaySmall: 26sp / 34 line height / weight 700
```

### Headline

Untuk judul screen dan section besar.

```dart
headlineLarge: 24sp / 32 line height / weight 700
headlineMedium: 22sp / 30 line height / weight 700
headlineSmall: 20sp / 28 line height / weight 700
```

### Title

Untuk card title, section title kecil, form group title.

```dart
titleLarge: 18sp / 26 line height / weight 700
titleMedium: 16sp / 24 line height / weight 600
titleSmall: 14sp / 20 line height / weight 600
```

### Body

Untuk teks umum.

```dart
bodyLarge: 16sp / 24 line height / weight 400
bodyMedium: 14sp / 22 line height / weight 400
bodySmall: 12sp / 18 line height / weight 400
```

### Label

Untuk button, badge, tab, metadata.

```dart
labelLarge: 14sp / 20 line height / weight 700
labelMedium: 12sp / 18 line height / weight 600
labelSmall: 11sp / 16 line height / weight 600
```

---

## 6.5 Type Scale Tablet

Tablet membutuhkan sedikit peningkatan size.

```dart
displayLarge: 40sp
displayMedium: 34sp
displaySmall: 30sp

headlineLarge: 28sp
headlineMedium: 24sp
headlineSmall: 22sp

titleLarge: 20sp
titleMedium: 17sp
titleSmall: 15sp

bodyLarge: 17sp
bodyMedium: 15sp
bodySmall: 13sp

labelLarge: 15sp
labelMedium: 13sp
labelSmall: 12sp
```

---

## 6.6 Type Scale Desktop / Wide Screen

Jika app dijalankan di desktop/web Flutter, jangan membuat teks terlalu besar.

```dart
displayLarge: 44sp
displayMedium: 38sp
displaySmall: 32sp

headlineLarge: 30sp
headlineMedium: 26sp
headlineSmall: 23sp

titleLarge: 21sp
titleMedium: 18sp
titleSmall: 15sp

bodyLarge: 17sp
bodyMedium: 15sp
bodySmall: 13sp

labelLarge: 15sp
labelMedium: 13sp
labelSmall: 12sp
```

---

## 6.7 Typography per Komponen

### AppBar Title

```dart
fontSize: 18
fontWeight: FontWeight.w700
letterSpacing: -0.2
color: textPrimary
```

### Section Title

```dart
fontSize: 18
fontWeight: FontWeight.w700
height: 1.25
letterSpacing: -0.2
```

### Section Subtitle

```dart
fontSize: 13
fontWeight: FontWeight.w400
height: 1.45
color: textSecondary
```

### Product Name

```dart
fontSize: 13
fontWeight: FontWeight.w600
height: 1.35
maxLines: 2
overflow: TextOverflow.ellipsis
```

### Product Price

```dart
fontSize: 15
fontWeight: FontWeight.w800
height: 1.2
color: primary
```

### Old Price

```dart
fontSize: 11
fontWeight: FontWeight.w500
decoration: TextDecoration.lineThrough
color: textMuted
```

### Discount Badge

```dart
fontSize: 10
fontWeight: FontWeight.w800
letterSpacing: 0.2
color: Colors.white
```

### Button Text

```dart
fontSize: 14
fontWeight: FontWeight.w700
letterSpacing: 0.1
```

### Bottom Nav Label

```dart
fontSize: 11
fontWeight selected: FontWeight.w700
fontWeight unselected: FontWeight.w500
```

### Form Label

```dart
fontSize: 13
fontWeight: FontWeight.w600
color: textPrimary
```

### Input Text

```dart
fontSize: 14
fontWeight: FontWeight.w500
color: textPrimary
```

### Helper Text

```dart
fontSize: 12
fontWeight: FontWeight.w400
color: textSecondary
```

---

# 7. Layout System

## 7.1 Breakpoint

Gunakan breakpoint sederhana.

```dart
compact: width < 600
medium: 600 <= width < 1024
expanded: width >= 1024
```

Atau:

```dart
mobileSmall: width < 360
mobile: 360 - 599
tablet: 600 - 1023
desktop: >= 1024
```

## 7.2 Max Content Width

Agar layout tidak terlalu melebar di tablet/desktop:

```dart
maxContentWidthMobile: double.infinity
maxContentWidthTablet: 720
maxContentWidthDesktop: 1180
```

Pada desktop:

```dart
Center(
  child: ConstrainedBox(
    constraints: BoxConstraints(maxWidth: 1180),
    child: child,
  ),
)
```

## 7.3 Screen Padding

```dart
mobile: EdgeInsets.symmetric(horizontal: 16)
tablet: EdgeInsets.symmetric(horizontal: 24)
desktop: EdgeInsets.symmetric(horizontal: 32)
```

## 7.4 Section Layout

Setiap section wajib memakai pola:

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    SectionHeader(),
    SizedBox(height: 12),
    SectionContent(),
  ],
)
```

Jarak antar section:

```dart
mobile: 24
tablet: 32
desktop: 40
```

---

# 8. Product Grid Layout

## 8.1 Mobile Grid

Untuk mobile:

```dart
crossAxisCount: 2
crossAxisSpacing: 12
mainAxisSpacing: 14
childAspectRatio: 0.62 - 0.68
```

Product image ratio:

```dart
AspectRatio(aspectRatio: 3 / 4)
```

## 8.2 Tablet Grid

Untuk tablet:

```dart
crossAxisCount: 3
crossAxisSpacing: 16
mainAxisSpacing: 18
childAspectRatio: 0.66
```

## 8.3 Desktop Grid

Untuk desktop:

```dart
crossAxisCount: 4 atau 5
crossAxisSpacing: 18
mainAxisSpacing: 22
childAspectRatio: 0.70
```

## 8.4 Product Card Structure

Urutan isi product card:

1. Image produk
2. Badge promo atau status
3. Wishlist button di pojok kanan atas image
4. Nama produk
5. Harga
6. Old price / discount jika ada
7. Mini metadata seperti kategori atau sold count jika tersedia
8. Quick action optional

Struktur visual:

```text
┌────────────────────┐
│ Image              │
│     ♡              │
│ PROMO              │
├────────────────────┤
│ Product Name       │
│ Rp 120.000         │
│ Rp 150.000  -20%   │
│ Best Seller        │
└────────────────────┘
```

## 8.5 Product Card Style

```dart
background: surface
borderRadius: 18
border: 1px borderSoft
shadow: soft
padding: 8 for image area, 10-12 for content
```

Image:

```dart
borderRadius: 16
background: surfaceSoft
fit: BoxFit.cover
```

Wishlist button:

```dart
size: 34
background: Colors.white.withOpacity(0.92)
radius: 999
iconSize: 18
```

Badge:

```dart
height: 22
padding horizontal: 8
radius: 999
fontSize: 10
fontWeight: 800
```

---

# 9. AppBar Design

## 9.1 Home AppBar

Home tidak perlu app bar terlalu formal.

Isi:

* Logo / brand name
* Search bar kecil
* Cart icon
* Chatbot icon optional

Layout:

```text
[Mitologi]      [Search] [Cart]
```

Atau:

```text
[Logo Mitologi]
[Search produk, kategori, portfolio...]
```

Rekomendasi untuk mobile:

* Logo dan cart di row pertama.
* Search bar full width di bawahnya.
* AppBar bisa sticky ketika scroll.

## 9.2 Catalog AppBar

Catalog butuh search dominan.

```text
[Back optional] [Search produk...] [Filter]
```

Search bar:

```dart
height: 46
radius: 16
background: surfaceSoft
border: borderSoft
```

## 9.3 Product Detail AppBar

PDP harus clean.

Isi:

* Back button
* Share button
* Wishlist button
* Cart button

Gunakan transparent appbar saat image di atas, berubah solid ketika scroll.

## 9.4 Checkout AppBar

Checkout harus formal.

```text
[Back] Checkout
```

Tidak perlu banyak icon.

---

# 10. Bottom Navigation

Project memakai 5 tab:

* Beranda
* Katalog
* Wishlist
* Portfolio
* Akun

## 10.1 Mobile Bottom Navigation

Style:

```dart
height: 72-80
background: white
border top: borderSoft
shadow: soft upward
selected color: primary
unselected color: textMuted
indicator: soft navy/gold pill
```

Selected item:

* Icon filled.
* Label bold.
* Ada pill background tipis.

Unselected item:

* Icon regular.
* Label medium.
* Tidak ada background.

## 10.2 Tablet Navigation

Untuk tablet portrait masih boleh bottom nav.

Untuk tablet landscape atau desktop, bisa gunakan NavigationRail tetapi hanya jika tidak mengubah routing.

Rekomendasi adaptive:

```dart
if width >= 1024:
  use side navigation rail
else:
  use bottom navigation
```

Namun kalau ingin minim risiko, tetap pakai bottom nav di semua device, tetapi content diberi max width.

---

# 11. Home Screen Layout

Home screen saat ini besar dan kompleks. Redesign harus membuatnya lebih modular.

## 11.1 Urutan Section Home

Urutan yang disarankan:

1. Header + search
2. Hero carousel
3. Quick category chips
4. Promo / flash deal strip
5. Featured products
6. Categories
7. Portfolio preview
8. Printing methods
9. Why choose us
10. Testimonials
11. Partners
12. Order flow
13. CTA contact / chatbot

## 11.2 Home Header

Style:

```dart
background: primary gradient
border bottom radius: 28
padding top: safe area + 16
padding horizontal: 16
padding bottom: 18
```

Isi:

* Greeting / brand
* Cart icon
* Search bar
* Mini quick links

Contoh copy:

```text
Mitologi Clothing
Custom apparel, printing, dan produk fashion pilihan.
```

## 11.3 Search Bar Home

Search bar harus terasa seperti marketplace.

```dart
height: 48
radius: 16
background: white
icon: search
placeholder: "Cari produk, kategori, atau portfolio..."
```

## 11.4 Hero Carousel

Hero jangan terlalu tinggi.

Mobile:

```dart
height: 180 - 220
radius: 24
```

Tablet:

```dart
height: 260 - 320
```

Isi hero:

* Image / background
* Title pendek
* Subtitle
* CTA
* Badge kecil

Jangan menaruh terlalu banyak teks di hero.

## 11.5 Category Chips

Gunakan horizontal scroll.

```text
[Kaos] [Hoodie] [Jersey] [Printing] [Promo] [Portfolio]
```

Style:

```dart
height: 38
radius: 999
background selected: primary
background unselected: surface
border: borderSoft
```

## 11.6 Featured Product Section

Section header:

```text
Produk Pilihan
Lihat semua
```

Gunakan product grid 2 kolom mobile.

Untuk home, tampilkan maksimal 4 atau 6 produk agar tidak terlalu panjang.

## 11.7 Promo Strip

Promo strip bisa seperti marketplace.

```dart
height: 76
radius: 20
background: promo gradient
```

Isi:

```text
Promo Custom Apparel
Diskon khusus untuk pemesanan batch dan komunitas
[Claim]
```

## 11.8 Portfolio Preview

Karena Mitologi Clothing punya portfolio, tampilkan sebagai visual proof.

Layout mobile:

* Horizontal card 160x200
* Image dominan
* Category badge
* Project title

---

# 12. Catalog Screen Layout

## 12.1 Catalog Header

Isi:

* Search field
* Filter button
* Sort button
* Category horizontal chips

## 12.2 Product Grid

Gunakan grid adaptive.

Mobile:

```dart
2 columns
```

Tablet:

```dart
3 columns
```

Desktop:

```dart
4-5 columns
```

## 12.3 Filter UI

Filter sebaiknya bottom sheet.

Isi filter:

* Category
* Price range
* Sort
* Availability
* Promo
* Reset button
* Apply button

Bottom sheet style:

```dart
radius top: 28
padding: 20
drag handle
sticky bottom action
```

## 12.4 Empty Catalog

Empty state:

```text
Produk tidak ditemukan
Coba ubah kata kunci atau filter pencarian.
[Reset Filter]
```

Gunakan icon box/search.

---

# 13. Product Detail Page Layout

## 13.1 Struktur PDP

Urutan:

1. Image gallery
2. Product info
3. Price
4. Variant selector
5. Quantity selector
6. Description
7. Specification
8. Reviews/testimonials jika ada
9. Related products
10. Sticky bottom CTA

## 13.2 Image Gallery

Mobile:

```dart
AspectRatio 1:1 atau 4:5
```

Gunakan:

* PageView
* Indicator dots
* Thumbnail optional

## 13.3 Product Info

Nama produk:

```dart
titleLarge 18sp bold
maxLines optional 3
```

Harga:

```dart
20sp / 22sp
fontWeight 800
color primary
```

Badge:

```text
Best Seller
Custom Ready
Preorder
Promo
```

## 13.4 Variant Selector

Variant jangan terlihat seperti form biasa. Buat chip.

```dart
ChoiceChip
radius: 999
selected background: primary
unselected background: surface
```

## 13.5 Sticky Bottom CTA

PDP wajib punya CTA sticky.

```text
[Chat] [Keranjang] [Beli Sekarang]
```

Atau:

```text
[Tambah ke Keranjang] [Checkout]
```

Mobile:

* CTA full width bottom.
* SafeArea bottom.
* Shadow top.

---

# 14. Cart Screen Layout

## 14.1 Cart Item Card

Isi:

* Checkbox optional
* Product image
* Product name
* Variant
* Price
* Quantity stepper
* Remove button

Layout:

```text
[img] Product name      [x]
      Variant
      Rp xxx
      [-] 1 [+]
```

## 14.2 Cart Summary

Sticky bottom:

```text
Total
Rp xxx.xxx
[Checkout]
```

Style:

```dart
background: white
border top: borderSoft
shadow: soft upward
```

## 14.3 Empty Cart

```text
Keranjang masih kosong
Yuk pilih produk custom favoritmu.
[Belanja Sekarang]
```

---

# 15. Checkout Screen Layout

Checkout harus paling jelas dan tidak ramai.

## 15.1 Urutan Checkout

1. Address card
2. Shipping method
3. Payment method
4. Order items summary
5. Price breakdown
6. Notes optional
7. Pay button

## 15.2 Address Card

Style:

```dart
background: surface
radius: 18
padding: 16
border: borderSoft
```

Isi:

* Label alamat
* Recipient
* Phone
* Full address
* Change button

## 15.3 Price Breakdown

Gunakan list rapi:

```text
Subtotal        Rp xxx
Ongkir          Rp xxx
Diskon          -Rp xxx
Total           Rp xxx
```

Total:

```dart
fontSize: 18
fontWeight: 800
color: primary
```

## 15.4 Checkout CTA

Button:

```dart
height: 52
radius: 16
background: primary
text: Bayar Sekarang
```

---

# 16. Wishlist Screen

Wishlist harus seperti catalog grid tapi lebih personal.

## 16.1 Layout

* Header simple.
* Product grid 2 column.
* Remove wishlist icon jelas.
* CTA ke detail produk.

## 16.2 Empty State

```text
Wishlist masih kosong
Simpan produk favoritmu agar mudah ditemukan lagi.
[Jelajahi Produk]
```

---

# 17. Profile Screen

Profile screen harus lebih rapi dan tidak terlalu banyak card berat.

## 17.1 Header Profile

```dart
background: primary gradient
radius bottom: 28
```

Isi:

* Avatar
* Name
* Email / phone
* Edit profile button

## 17.2 Menu List

Gunakan grouped menu.

Group 1:

* Pesanan Saya
* Alamat
* Wishlist

Group 2:

* FAQ
* Kebijakan Privasi
* Syarat & Ketentuan

Group 3:

* Ubah Password
* Logout

Menu item style:

```dart
height: 56
icon container 36
title 14 semibold
chevron right
```

---

# 18. Auth Screen

Auth screen harus clean dan premium.

## 18.1 Login Layout

```text
Logo
Welcome Back
Email
Password
Forgot password
Login button
Register link
```

## 18.2 Background

Gunakan soft gradient:

```dart
backgroundWarm to background
```

Tambahkan decorative shape navy/gold tipis, jangan terlalu ramai.

## 18.3 Form Field

```dart
height: 52
radius: 16
filled: true
fillColor: white
border: borderSoft
```

---

# 19. CMS Pages

CMS page seperti About, FAQ, Kontak, Layanan, Panduan Ukuran harus seragam.

## 19.1 CMS Header

```dart
title
subtitle optional
breadcrumb optional
```

## 19.2 Content Card

Setiap content block gunakan:

```dart
background: white
radius: 20
padding: 16
border: borderSoft
```

## 19.3 FAQ

FAQ pakai accordion.

```dart
radius: 16
expanded background: surfaceSoft
title: 14 semibold
body: 13 regular
```

---

# 20. Chatbot Screen

Chatbot harus terasa seperti assistant commerce.

## 20.1 Layout

* Header: “Mitologi Assistant”
* Bubble chat
* Input sticky bottom
* Suggested prompt chips

## 20.2 Bubble

User bubble:

```dart
align right
background primary
text white
radius 18
```

Bot bubble:

```dart
align left
background surface
text textPrimary
border borderSoft
radius 18
```

## 20.3 Suggested Prompt

Contoh:

```text
"Cari hoodie custom"
"Berapa estimasi ongkir?"
"Lihat promo"
"Cara order custom?"
```

---

# 21. Button System

## 21.1 Primary Button

```dart
height: 50-52
radius: 16
background: primary
text: white
fontWeight: 700
```

## 21.2 Secondary Button

```dart
height: 50
radius: 16
background: secondarySoft
text: primary
```

## 21.3 Outline Button

```dart
height: 48
radius: 16
border: primary
text: primary
```

## 21.4 Ghost Button

```dart
height: 44
background: transparent
text: primary
```

## 21.5 Danger Button

```dart
background: error
text: white
```

---

# 22. Input System

## 22.1 Text Field

```dart
height: 52
radius: 16
fillColor: surface
border: borderSoft
focusedBorder: primary
errorBorder: error
```

## 22.2 Search Field

```dart
height: 46-48
radius: 16 atau 999
prefixIcon: search
suffixIcon: clear/filter optional
```

## 22.3 Dropdown

Gunakan bottom sheet untuk pilihan panjang.

Untuk pilihan pendek gunakan dropdown biasa.

---

# 23. Card System

## 23.1 Standard Card

```dart
background: surface
radius: 18
padding: 16
border: borderSoft
shadow: very soft
```

## 23.2 Product Card

```dart
radius: 18
padding: 8
image radius: 16
```

## 23.3 Promo Card

```dart
radius: 22
gradient: promo/brand
padding: 16
```

## 23.4 Info Card

```dart
background: infoSoft
border: transparent
radius: 16
```

## 23.5 Warning Card

```dart
background: warningSoft
border: warning with opacity
radius: 16
```

---

# 24. Badge System

## 24.1 Promo Badge

```dart
background: promoRed
text: white
radius: 999
fontSize: 10
fontWeight: 800
```

## 24.2 Category Badge

```dart
background: surfaceSoft
text: textSecondary
radius: 999
fontSize: 11
fontWeight: 600
```

## 24.3 Premium Badge

```dart
background: secondarySoft
text: primary
radius: 999
fontSize: 11
fontWeight: 800
```

## 24.4 Status Badge

Success:

```dart
background: successSoft
text: success
```

Warning:

```dart
background: warningSoft
text: warning
```

Error:

```dart
background: errorSoft
text: error
```

---

# 25. Image System

## 25.1 Product Image

Wajib menggunakan cached image dengan shimmer.

Default:

```dart
fit: BoxFit.cover
background: surfaceSoft
borderRadius: 16
```

## 25.2 Error Image

Jika image gagal:

* Tampilkan icon image.
* Background surfaceSoft.
* Text optional “Gambar tidak tersedia”.

## 25.3 Skeleton Image

Skeleton harus mengikuti bentuk asli image.

Product card skeleton:

* Image block 3:4.
* Text line 2 buah.
* Price line.

---

# 26. Loading State

## 26.1 Full Page Loading

Gunakan loading center:

```text
Memuat data...
```

Dengan spinner kecil.

## 26.2 Skeleton Loading

Untuk home dan catalog jangan pakai full spinner terus.

Gunakan skeleton:

* Hero skeleton
* Category chip skeleton
* Product grid skeleton
* Card skeleton

## 26.3 Button Loading

Button loading harus menjaga width/height.

```dart
CircularProgressIndicator size 18
```

---

# 27. Empty State

Setiap empty state harus punya:

* Icon/illustration
* Title
* Description
* CTA optional

Format:

```text
Title: 16 bold
Description: 13 regular
CTA: primary button
```

Contoh:

```text
Belum ada produk
Produk akan tampil di sini setelah tersedia.
```

---

# 28. Error State

Error harus user-friendly.

Jangan tampilkan error teknis langsung.

Contoh:

```text
Gagal memuat data
Periksa koneksi internet kamu lalu coba lagi.
[Coba Lagi]
```

Jika error dari API spesifik, mapping lewat `error_mapper.dart`.

---

# 29. Motion & Animation

Animasi harus ringan.

## 29.1 Duration

```dart
fast: 120ms
normal: 200ms
slow: 320ms
```

## 29.2 Curve

```dart
Curves.easeOutCubic
Curves.easeInOutCubic
```

## 29.3 Animasi yang Disarankan

* Fade in section.
* Scale button saat tap.
* Wishlist heart micro interaction.
* Add to cart bottom sheet slide.
* Skeleton shimmer.
* Cart badge bounce kecil.
* Bottom nav selected indicator animation.

## 29.4 Animasi yang Dihindari

* Animasi terlalu lama.
* Banyak animasi bersamaan.
* Parallax berat.
* Blur terlalu banyak.
* Confetti terus-menerus.

---

# 30. Responsive Rules Detail

## 30.1 Mobile Small `< 360`

* Padding horizontal 14.
* Grid tetap 2 kolom, gap 10.
* Product name max 2 lines.
* Hero height 170.
* Bottom nav label boleh lebih kecil 10sp.

## 30.2 Mobile Normal `360 - 599`

* Padding horizontal 16.
* Grid 2 kolom.
* Hero height 190-220.
* Search bar 48.
* Bottom nav normal.

## 30.3 Tablet `600 - 1023`

* Padding 24.
* Content max width 720.
* Product grid 3 kolom.
* Hero height 280.
* Product detail bisa 2 column ringan:

  * image di atas tetap boleh untuk portrait.
  * landscape bisa image kiri, info kanan.

## 30.4 Desktop / Web `>= 1024`

* Content max width 1180.
* Product grid 4-5 kolom.
* Detail page 2 column:

  * gallery kiri
  * product info kanan
* Checkout 2 column:

  * form kiri
  * summary kanan sticky
* Bottom nav bisa tetap atau diganti NavigationRail jika aman.

---

# 31. Screen-by-Screen Redesign Checklist

## 31.1 Splash

* Logo centered.
* Background primary atau soft gradient.
* Loading subtle.
* Jangan terlalu lama.

## 31.2 Login

* Clean form.
* CTA jelas.
* Password visibility icon.
* Forgot password mudah terlihat.

## 31.3 Register

* Field spacing 14.
* Button sticky jika keyboard aman.
* Link login jelas.

## 31.4 Home

* Header marketplace.
* Search prominent.
* Hero modern.
* Category chips.
* Product grid.
* Portfolio preview.
* CTA chatbot/contact.

## 31.5 Catalog

* Search sticky.
* Filter bottom sheet.
* Grid adaptive.
* Sort mudah.

## 31.6 Product Detail

* Image besar.
* Price jelas.
* Variant chip.
* Sticky CTA.
* Description rapi.
* Related product grid.

## 31.7 Cart

* Item card clean.
* Quantity stepper mudah.
* Total sticky.
* Checkout CTA jelas.

## 31.8 Checkout

* Step jelas.
* Address card.
* Shipping card.
* Payment card.
* Summary sticky.
* Pay button jelas.

## 31.9 Wishlist

* Grid sama dengan catalog.
* Empty state bagus.
* Remove wishlist mudah.

## 31.10 Portfolio

* Visual grid.
* Filter category chips.
* Detail image-first.

## 31.11 Profile

* Header premium.
* Menu grouped.
* Logout jelas tapi tidak terlalu dominan.

## 31.12 Orders

* Status tabs.
* Order card.
* Timeline di detail order.
* CTA bayar ulang jika belum bayar.

## 31.13 CMS

* Content card konsisten.
* Typography rapi.
* Jangan terlalu panjang tanpa section.

## 31.14 Chatbot

* Bubble rapi.
* Prompt chips.
* Input sticky.

---

# 32. Component Refactor Recommendation

Karena project punya duplikasi widget di:

* `lib/core/widgets`
* `lib/widgets/common`
* `lib/widgets/shared`
* `lib/widgets/product`

Maka aturan baru:

## 32.1 Single Source of Truth

Komponen base pindahkan ke:

```text
lib/core/widgets/
```

Komponen shared app pindahkan ke:

```text
lib/widgets/shared/
```

Komponen feature-specific tetap di:

```text
lib/features/<feature>/presentation/widgets/
```

## 32.2 Product Card

Gunakan satu product card utama:

```text
lib/widgets/shared/product_card.dart
```

Jika butuh variasi:

```dart
enum ProductCardVariant {
  compact,
  regular,
  horizontal,
  featured,
}
```

Jangan punya banyak file product_card berbeda dengan behavior berbeda.

## 32.3 Section Header

Gunakan satu:

```text
lib/core/widgets/section_header.dart
```

Props:

```dart
title
subtitle
actionText
onActionTap
eyebrow
```

## 32.4 App Image

Gunakan satu:

```text
lib/core/widgets/app_image.dart
```

Props:

```dart
url
width
height
borderRadius
fit
placeholderType
```

---

# 33. Naming Convention

Gunakan nama yang konsisten:

```dart
MitologiProductCard
MitologiSearchBar
MitologiSectionHeader
MitologiBottomNav
MitologiButton
MitologiBadge
MitologiInfoCard
MitologiEmptyState
MitologiSkeleton
MitologiAppBar
```

Atau jika ingin lebih general:

```dart
AppProductCard
AppSearchBar
AppSectionHeader
AppButton
AppBadge
```

Pilih salah satu. Jangan campur terlalu banyak.

---

# 34. Implementation Priority

## Phase 1 — Foundation

* Rapikan `app_colors.dart`
* Rapikan `app_text_styles.dart`
* Rapikan `app_spacing.dart`
* Update `app_theme.dart`
* Tambahkan responsive helper
* Buat base widgets

## Phase 2 — Core Components

* Button
* Input
* Search bar
* Product card
* Section header
* App image
* Badge
* Empty state
* Skeleton
* Bottom sheet

## Phase 3 — Main Commerce Screens

* Home
* Catalog
* Product detail
* Cart
* Checkout
* Wishlist

## Phase 4 — Account & CMS

* Profile
* Orders
* Address
* About
* FAQ
* Contact
* Portfolio
* Policy pages

## Phase 5 — Polish

* Animation
* Loading state
* Error state
* Micro interaction
* Tablet layout
* Desktop/web layout

---

# 35. Do and Don't

## Do

* Gunakan spacing konsisten.
* Gunakan typography token.
* Buat product image dominan.
* Jaga CTA tetap jelas.
* Gunakan skeleton loading.
* Gunakan bottom sheet untuk filter.
* Gunakan max width di layar besar.
* Buat card ringan dan bersih.
* Gunakan navy dan gold secara elegan.

## Don't

* Jangan ubah logic Provider.
* Jangan ubah API.
* Jangan ubah model.
* Jangan ubah route path.
* Jangan membuat semua section pakai gradient.
* Jangan membuat terlalu banyak shadow.
* Jangan membuat font terlalu kecil.
* Jangan membuat product card terlalu padat.
* Jangan membuat checkout terlalu ramai.
* Jangan menampilkan error teknis langsung ke user.

---

# 36. Example AppTextStyles

```dart
class AppTextStyles {
  static TextStyle get displayLarge => GoogleFonts.plusJakartaSans(
        fontSize: 34,
        height: 42 / 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      );

  static TextStyle get headlineLarge => GoogleFonts.plusJakartaSans(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      );

  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        height: 26 / 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      );

  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        height: 22 / 14,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        height: 18 / 12,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        height: 18 / 12,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get productName => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get productPrice => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        height: 18 / 15,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
      );
}
```

---

# 37. Example Responsive Utils

```dart
enum DeviceType {
  mobileSmall,
  mobile,
  tablet,
  desktop,
}

class ResponsiveUtils {
  static DeviceType deviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 360) return DeviceType.mobileSmall;
    if (width < 600) return DeviceType.mobile;
    if (width < 1024) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  static bool isMobile(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width < 600;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= 600 && width < 1024;
  }

  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= 1024;
  }

  static double horizontalPadding(BuildContext context) {
    final type = deviceType(context);

    switch (type) {
      case DeviceType.mobileSmall:
        return 14;
      case DeviceType.mobile:
        return 16;
      case DeviceType.tablet:
        return 24;
      case DeviceType.desktop:
        return 32;
    }
  }

  static int productGridCount(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 600) return 2;
    if (width < 1024) return 3;
    if (width < 1280) return 4;
    return 5;
  }

  static double maxContentWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 600) return double.infinity;
    if (width < 1024) return 720;
    return 1180;
  }
}
```

---

# 38. Example Responsive Wrapper

```dart
class AppResponsiveContainer extends StatelessWidget {
  const AppResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveUtils.maxContentWidth(context);
    final horizontal = ResponsiveUtils.horizontalPadding(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.symmetric(horizontal: horizontal),
          child: child,
        ),
      ),
    );
  }
}
```

---

# 39. Example Product Grid

```dart
class AppProductGrid extends StatelessWidget {
  const AppProductGrid({
    super.key,
    required this.children,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  final List<Widget> children;
  final bool shrinkWrap;
  final ScrollPhysics physics;

  @override
  Widget build(BuildContext context) {
    final count = ResponsiveUtils.productGridCount(context);
    final isMobile = ResponsiveUtils.isMobile(context);

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: children.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count,
        crossAxisSpacing: isMobile ? 12 : 16,
        mainAxisSpacing: isMobile ? 14 : 18,
        childAspectRatio: isMobile ? 0.64 : 0.70,
      ),
      itemBuilder: (context, index) => children[index],
    );
  }
}
```

---

# 40. Final Visual Target

Setelah redesign, aplikasi Mitologi Clothing harus terasa seperti:

* Home rapi seperti marketplace modern.
* Catalog cepat dipakai seperti e-commerce besar.
* Product detail premium seperti fashion store.
* Checkout jelas seperti aplikasi profesional.
* Profile bersih dan mudah dipahami.
* Portfolio visual dan meyakinkan.
* Typography konsisten.
* Spacing tidak berantakan.
* Mobile nyaman.
* Tablet tetap proporsional.
* Desktop/web tidak melebar berlebihan.
* Semua logic lama tetap aman.

Target akhir:

**Simple, clean, premium, responsive, marketplace-friendly, dan tetap punya identitas Mitologi Clothing.**

[mitologi_clothing_mobile](directory;file:///c%3A/laragon/www/Mitologi%20Clothing/mitologi_clothing_mobile) buat planning lengkap untuk redesign folder ini sesuai dengan [design.md](file;file:///c%3A/laragon/www/Mitologi%20Clothing/mitologi_clothing_mobile/design.md) planning yang super duper lengkap 