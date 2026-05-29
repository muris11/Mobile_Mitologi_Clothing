# DESIGN — Mitologi Clothing Mobile Commerce Experience
## Premium UI/UX Redesign Specification for Flutter Mobile App

**Dokumen:** `design.md`  
**Versi:** 1.0 — Mobile UI Redesign Direction  
**Produk:** Mitologi Clothing — Fashion & Merchandise E-Commerce  
**Platform target:** Flutter Mobile App — Android dan iOS  
**Ruang lingkup:** Tampilan, visual hierarchy, layout, typography, reusable UI component, animation, state UI, responsive behavior, dan pengalaman interaksi antarlayar  
**Di luar ruang lingkup:** Perubahan business logic, endpoint API, model data, state management, autentikasi, perhitungan cart, payment logic Midtrans, recommendation algorithm, route contract, backend, web storefront, atau dashboard admin  
**Arah visual:** fashion-commerce modern, premium, editorial, cepat dipakai, terasa personal, dan lebih bersih daripada marketplace promo-heavy generik  
**Sumber konteks project:** Proposal Mitologi Clothing menjelaskan mobile client Flutter dengan alur katalog, detail produk, pencarian/filter, wishlist, cart, checkout, pembayaran Midtrans, profile, riwayat pesanan, dan AI recommendation.

---

## 0. Instruksi Utama untuk Developer / AI Coding Agent

Dokumen ini adalah aturan redesign **UI-only** untuk aplikasi Flutter Mitologi Clothing. Implementasikan desain secara bertahap tanpa merusak alur aplikasi yang telah berjalan.

### 0.1 Aturan non-negotiable

1. **Pertahankan tema warna yang saat ini sudah digunakan di project.** Jangan mengganti warna brand utama dengan warna Shopee, Tokopedia, TikTok Shop, atau marketplace lain. Warna existing harus diekstrak dari `ThemeData`, `ColorScheme`, constants, extension, atau widget lama lalu dirapikan menjadi token semantik.
2. **Jangan mengubah logika kode.** Dilarang mengganti repository, provider/bloc/controller, API service, model JSON, payment flow, Midtrans integration, recommendation service, validation rules, route name, maupun data dummy/real yang telah dipakai aplikasi.
3. **Fokus hanya pada presentation layer.** Perubahan diperbolehkan pada widget UI, composition layout, padding, typography, iconography, asset placement, theme styling, animation visual, loading/error/empty state, dan responsiveness.
4. **Tidak menyalin satu marketplace tertentu.** Ambil pola terbaik dari commerce modern—pencarian cepat, katalog efisien, discovery visual, detail produk meyakinkan, checkout tenang—kemudian jadikan pengalaman unik untuk fashion brand Mitologi Clothing.
5. **Fashion-first, bukan promo-chaos.** Produk, fotografi, varian, size, rekomendasi outfit, serta kepercayaan transaksi harus menjadi fokus visual. Promo boleh terlihat menarik tetapi tidak membuat layar ramai, murah, atau sulit dibaca.
6. **No emoji sebagai icon UI.** Gunakan `Icons`/Material Symbols atau SVG icon yang konsisten. Emoji hanya dapat muncul sebagai isi review dari data pengguna apabila memang berasal dari backend.
7. **Jangan menambahkan fitur yang belum ada pada project.** Bagian seperti video/live, voucher, review, alamat, notifikasi, tracking, atau onboarding hanya didesain apabila screen/data tersebut sudah tersedia atau memang sedang diimplementasikan secara terpisah.
8. **Setiap state wajib rapi:** loading, empty, error, offline, disabled, success, out of stock, item unavailable, payment pending, payment success, dan payment failed.

### 0.2 Definition of Done redesign

Redesign dianggap selesai apabila:

- semua screen customer-facing memakai satu design system konsisten;
- warna existing tetap menjadi identitas utama;
- user dapat menemukan produk, memilih varian, masuk cart, checkout, membayar, dan melihat pesanan tanpa kebingungan;
- UI tidak memanggil API baru atau mengubah proses bisnis;
- tampilan nyaman pada ponsel kecil hingga tablet/foldable;
- seluruh CTA, label status, harga, size, payment status, dan error mudah dibaca;
- aplikasi terasa sebagai brand fashion profesional, bukan sekadar template Flutter e-commerce.

---

## 1. Konteks Produk dan Sasaran Redesign

### 1.1 Identitas produk

Mitologi Clothing adalah platform e-commerce untuk produk fashion dan merchandise. Mobile application Flutter merupakan salah satu client dalam ekosistem yang terhubung dengan backend, web storefront, Midtrans payment, dan AI recommendation service. Karena domainnya fashion, visual aplikasi harus mendukung keputusan pembelian yang sangat dipengaruhi oleh gambar produk, detail bahan, ukuran, pilihan warna, kecocokan gaya, dan rasa percaya terhadap brand.

### 1.2 Masalah desain yang hendak diperbaiki

Versi UI sekarang dinilai masih kurang menarik, terasa aneh, dan belum memberi kesan e-commerce modern. Redesign tidak boleh berhenti pada mengganti warna atau memperbesar card. Masalah yang wajib dibereskan melalui design system ini:

- tampilan belum terasa premium dan konsisten antarscreen;
- hirarki teks, harga, CTA, dan informasi pendukung belum jelas;
- card produk kemungkinan terlalu generik atau padat;
- halaman home/katalog/detail belum membangun pengalaman discovery fashion;
- alur cart–checkout–payment perlu lebih tenang, jelas, dan terpercaya;
- recommendation AI perlu ditampilkan sebagai nilai tambah brand, bukan sekadar section produk acak;
- spacing, radius, shadow, icon, skeleton, empty/error state, dan animation perlu memiliki standar yang sama.

### 1.3 Sasaran pengalaman pengguna

Pengguna harus merasakan pengalaman berikut:

1. **Cepat memahami brand** sejak membuka home: fashionable, terpercaya, dan curated.
2. **Mudah menemukan produk** melalui search, kategori, filter, dan rekomendasi.
3. **Yakin sebelum membeli** melalui PDP yang rapi: foto, nama, harga, varian, ukuran, detail, stok, dan CTA yang jelas.
4. **Checkout tanpa cemas** melalui ringkasan biaya, alamat/pengiriman apabila tersedia, pemilihan payment, serta status Midtrans yang transparan.
5. **Terasa personal** melalui recommendation yang relevan untuk style/produk yang diminati.
6. **Nyaman dipakai kembali** melalui wishlist, riwayat pesanan, profile, serta state aplikasi yang konsisten.

---

## 2. Benchmark Synthesis: Mengambil Kekuatan, Bukan Meniru

Redesign ini boleh terasa lebih matang daripada aplikasi commerce umum karena menggabungkan pola terbaik secara selektif, namun tetap membangun identitas Mitologi Clothing sendiri.

| Sumber inspirasi pola | Kekuatan yang diambil | Cara diterapkan di Mitologi Clothing | Yang tidak boleh ditiru |
|---|---|---|---|
| Marketplace besar seperti Tokopedia | pencarian cepat, kategori mudah dijelajahi, informasi transaksi jelas | search bar dominan, filter efektif, cart/checkout terstruktur | branding, warna, logo, atau layout copy-paste |
| Promo-driven commerce seperti Shopee | urgency promo dan benefit belanja terlihat jelas | promo chip/benefit card yang terkendali, harga diskon terbaca | halaman terlalu ramai, banner bertumpuk, kompetisi warna berlebihan |
| Discovery/social commerce seperti TikTok Shop | produk ditemukan melalui visual dan konteks pemakaian | hero editorial, rekomendasi “Complete the Look”, image-led discovery | membangun fitur LIVE/video apabila tidak tersedia di aplikasi |
| Premium fashion storefront | photography-first, white space, trust, fokus pada koleksi | gambar besar, type rapi, product detail elegan, curated sections | tampilan terlalu kosong hingga fungsi commerce sulit ditemukan |

### 2.1 Positioning visual yang dipilih

**Mitologi Clothing = Curated Fashion Commerce with Smart Personalization.**

Aplikasi tidak harus terlihat seperti marketplace massal yang menjual semuanya. Ia harus terasa seperti brand fashion yang memiliki katalog terkurasi, tetapi tetap memiliki kenyamanan transaksi kelas marketplace: cepat dicari, mudah ditambahkan ke wishlist/cart, checkout jelas, dan pembayaran terpercaya.

### 2.2 Formula pengalaman UI

- **Kecepatan marketplace:** search, kategori, filter, cart badge, checkout ringkas.
- **Discovery commerce:** gambar produk menjadi pusat perhatian, koleksi, recommendation personal.
- **Premium fashion:** typography bersih, spacing lapang, foto konsisten, CTA tidak berisik.
- **Trust commerce:** status pembayaran dan pesanan eksplisit, total harga transparan, feedback action jelas.

---

## 3. Guardrails Teknis: Redesign Tanpa Mengubah Logika

### 3.1 Lapisan yang boleh disentuh

Perubahan UI dapat dilakukan pada:

- file theme (`ThemeData`, `ColorScheme`, `TextTheme`, component themes);
- widget tampilan screen;
- reusable UI widgets seperti product card, search bar, button, bottom sheet, chip, skeleton;
- layout wrapper, spacing, padding, safe area, grid behavior;
- icon, image aspect ratio, placeholder, animation transisi visual;
- pengelompokan widget presentasional agar rapi, selama callback/data tetap sama;
- `Semantics`, tooltip, visual focus, dan accessibility UI.

### 3.2 Lapisan yang tidak boleh diubah

Jangan mengubah:

- nama route dan tujuan route yang sudah aktif;
- parameter callback seperti `onAddToCart`, `onCheckout`, `onPay`, `onToggleWishlist`, `onFilterChanged`;
- pengambilan dan pemetaan data dari API;
- state management apa pun yang sudah digunakan (`Provider`, `Riverpod`, `Bloc`, `GetX`, controller, setState, atau lainnya);
- model `Product`, `Cart`, `Order`, `Payment`, `User`, `Recommendation`;
- field JSON dan request/response API;
- autentikasi, cart calculation, discount calculation, stok, quantity restriction, payment flow, Midtrans token/webhook handling;
- algoritma AI recommendation atau penentuan produk rekomendasi;
- database, backend, web storefront, admin dashboard.

### 3.3 Cara aman menerapkan redesign

1. Audit file existing dan identifikasi seluruh screen serta widget reusable.
2. Temukan sumber warna existing; jadikan semantic design tokens tanpa mengganti nilai brand.
3. Buat atau rapikan komponen presentasional kecil terlebih dahulu.
4. Redesign screen satu per satu dengan mempertahankan parameter dan callback lama.
5. Setelah setiap screen, uji alur: tampil data, tap CTA, navigation, loading, empty, error.
6. Jalankan golden/screenshot comparison atau minimal rekam seluruh flow sebelum dan sesudah.
7. Jangan refactor arsitektur data bersamaan dengan redesign UI.

---

## 4. Visual Direction: Premium Fashion Commerce

### 4.1 Mood dan karakter visual

Gunakan kata kunci berikut sebagai kontrol kualitas desain:

- **Modern:** rapi, responsif, hierarki jelas, tidak tampak seperti template lama.
- **Editorial:** gambar produk dan koleksi mendapat ruang yang layak.
- **Premium:** warna brand dipakai penuh kontrol, bukan dibanjirkan pada setiap elemen.
- **Personal:** recommendation terasa relevan dan dibingkai dengan bahasa yang manusiawi.
- **Trustworthy:** harga, payment, order state, stok, dan CTA mudah diverifikasi pengguna.
- **Fast:** konten utama segera terlihat; skeleton dan state tidak menghambat orientasi.

### 4.2 Hal yang harus dihindari

- gradient berlebihan pada setiap card;
- shadow tebal dan gelap seperti UI lama;
- radius berbeda-beda tanpa aturan;
- terlalu banyak badge promo bertabrakan;
- text kecil, abu-abu pucat, atau kontras rendah;
- image produk dengan ukuran tidak seragam;
- semua elemen memakai primary color sehingga tidak ada hierarchy;
- animation berlebihan yang memperlambat belanja;
- bottom navigation yang terlalu tinggi atau penuh menu;
- desain checkout yang penuh banner promosi sehingga pengguna ragu dengan total bayar.

---

## 5. Color System — Pertahankan Tema Existing

### 5.1 Aturan warna terpenting

**Jangan menentukan warna brand baru dari dokumen ini.** Nilai warna final harus diambil dari project Flutter saat ini. Design agent wajib memeriksa, secara berurutan:

1. `ThemeData` / `ColorScheme` di file app theme;
2. file constants seperti `colors.dart`, `app_colors.dart`, `theme.dart`, atau extension sejenis;
3. warna tombol/navbar/logo yang saat ini menjadi identitas aplikasi;
4. asset logo/brand guideline apabila tersedia.

Setelah ditemukan, warna tersebut dipindahkan atau dipetakan ke token semantik berikut tanpa mengganti nuansa brand.

### 5.2 Token warna semantik

| Token | Mengambil dari warna existing | Penggunaan wajib |
|---|---|---|
| `brandPrimary` | primary existing | CTA utama, selected nav, focus, highlight terukur |
| `brandPrimaryContainer` | tonal/light version dari primary existing | selected chip, banner ringan, recommendation highlight |
| `brandSecondary` | secondary/accent existing bila ada | aksen koleksi atau elemen dekoratif terbatas |
| `surfacePage` | background existing atau neutral harmonis | latar halaman utama |
| `surfaceCard` | surface existing | product card, info card, sheet |
| `surfaceElevated` | surface paling terang/tinggi | sticky bottom CTA, floating search, modal |
| `textPrimary` | text dominant existing | heading, nama produk, harga utama |
| `textSecondary` | muted existing yang masih terbaca | metadata, helper, subtitle |
| `outlineSoft` | divider/border existing | card border, input outline, separator |
| `success` | status existing | payment success, delivered, in-stock sesuai penggunaan |
| `warning` | status existing | payment pending, low-stock |
| `error` | status existing | failed payment, validation error, out of stock |
| `scrim` | derived neutral | overlay bottom sheet/dialog/image |

### 5.3 Prinsip pemakaian warna

- Rasio visual kira-kira: neutral/background dominan, text dan image sebagai isi utama, brand primary hanya pada action/selected state/brand moment.
- Tombol utama memakai `brandPrimary`; tombol sekunder memakai outline atau tonal container, bukan warna brand lain.
- Harga utama memakai `textPrimary`, sementara diskon/badge boleh memakai semantic token yang konsisten.
- Jangan menambahkan warna kompetitor, khususnya hijau/oranye/merah khas marketplace lain, apabila tidak menjadi bagian theme existing.
- Status payment tidak hanya dibedakan berdasarkan warna; selalu sertakan icon dan label teks.
- Hero/banner boleh menggunakan visual yang sesuai theme, tetapi tidak mengubah brand palette.

### 5.4 Flutter theming direction

Aplikasi disarankan memakai satu sumber theme sebagai UI foundation:

```dart
// Conceptual only: map values from the existing project, do not replace brand colors.
ThemeData buildAppTheme(CurrentBrandPalette existing) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: existing.primary,
    brightness: Brightness.light,
  ).copyWith(
    primary: existing.primary,
    secondary: existing.secondary,
    error: existing.error,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: existing.pageBackground,
    // Apply text, card, input, button and navigation component themes here.
  );
}
```

Kode di atas hanya arah implementasi visual. Nilai warna tetap wajib berasal dari theme project yang sudah ada.

---

## 6. Typography System

### 6.1 Pilihan font

Typography boleh diperbarui walaupun warna tetap sama. Untuk Mitologi Clothing, arah font yang direkomendasikan:

- **Utama:** `Plus Jakarta Sans` karena terasa modern, bersih, ramah, dan cocok untuk brand digital Indonesia.
- **Alternatif sangat aman:** `Inter` apabila project sudah menggunakannya atau tim ingin font utilitarian yang ringan.
- **Fallback:** `system-ui` / default platform apabila menambah font tidak diizinkan.

**Aturan implementasi:** jangan menambah dependency font pada tahap UI tanpa persetujuan project. Jika `google_fonts` atau asset font telah tersedia, gunakan; jika belum, terapkan type scale pada font existing terlebih dahulu.

### 6.2 Tone typography

- Judul koleksi boleh tegas dan editorial, tidak harus memakai uppercase seluruhnya.
- Harga harus menjadi informasi paling cepat terbaca setelah gambar/nama produk.
- Body product detail harus nyaman dibaca, bukan terlalu kecil atau terlalu rapat.
- Label status dan CTA harus singkat, kuat, serta konsisten.

### 6.3 Type scale mobile

| Token | Size | Weight | Line height | Letter spacing | Penggunaan |
|---|---:|---:|---:|---:|---|
| `displayHero` | 30–34sp | 700 | 1.12 | -0.6 | hero editorial home/collection |
| `headlinePage` | 24sp | 700 | 1.20 | -0.3 | title utama screen |
| `headlineSection` | 20sp | 700 | 1.25 | -0.2 | title section home/detail |
| `titleCard` | 15–16sp | 600 | 1.30 | 0 | nama card/list title |
| `pricePrimary` | 18–20sp | 700 | 1.20 | -0.2 | harga detail/total utama |
| `priceCard` | 15–16sp | 700 | 1.20 | 0 | harga product card |
| `bodyLarge` | 16sp | 400/500 | 1.50 | 0 | description lead/payment explanation |
| `body` | 14sp | 400 | 1.50 | 0 | description, metadata |
| `label` | 12sp | 600 | 1.30 | 0.1 | chip, tab, badge, metadata |
| `caption` | 11–12sp | 400/500 | 1.35 | 0.1 | helper, secondary note |
| `button` | 15sp | 600 | 1.20 | 0.1 | semua CTA |
| `navLabel` | 11–12sp | 600 | 1.20 | 0 | bottom navigation |

### 6.4 Rules typography

- Maksimal dua weight dominan per screen: regular dan semibold/bold.
- Nama produk pada grid maksimal dua baris dengan ellipsis.
- Jangan memotong harga atau status pesanan.
- Gunakan formatter harga existing; desain tidak boleh mengubah format nominal/logika mata uang.
- Minimal ukuran teks body interaktif 14sp; jangan membuat CTA/status penting sangat kecil.
- Text scaling perangkat harus tetap menghasilkan layout dapat digunakan; jangan mematikan text scale.

---

## 7. Layout Foundation dan Spacing

### 7.1 Grid dasar

Gunakan sistem spacing berbasis kelipatan 4 agar seluruh screen konsisten.

| Token | Nilai | Penggunaan |
|---|---:|---|
| `space2` | 2px | optical adjustment sangat kecil |
| `space4` | 4px | jarak icon-label mini |
| `space8` | 8px | internal badge, gap item kecil |
| `space12` | 12px | chip, compact row |
| `space16` | 16px | padding horizontal mobile default, card content |
| `space20` | 20px | section compact |
| `space24` | 24px | gap antarkomponen utama |
| `space32` | 32px | gap antarsection home/detail |
| `space40` | 40px | section separator premium |
| `space48` | 48px | large hero/content breathing room |

### 7.2 Mobile screen layout

- Padding horizontal default screen: **16px** pada ponsel kecil; **20px** pada ponsel lebar.
- Jangan menempelkan card atau tulisan ke tepi layar.
- Section home menggunakan vertical gap 28–36px untuk memberi kesan premium.
- Grid produk menggunakan gap 12px; image ratio tetap konsisten.
- Sticky CTA di product detail/cart/checkout harus menghormati safe area bottom.

### 7.3 Radius

| Token | Nilai | Penggunaan |
|---|---:|---|
| `radiusXs` | 6px | badge kecil |
| `radiusSm` | 10px | chip, compact container |
| `radiusMd` | 14px | input, small card, icon button |
| `radiusLg` | 18px | product card, promo/recommendation card |
| `radiusXl` | 24px | modal sheet, hero card, payment status card |
| `radiusFull` | 999px | pill CTA/chip sesuai kebutuhan |

**Rule:** jangan mencampur radius tajam dan ultra-rounded secara acak. Product imagery/card memakai `radiusLg`, input dan normal button memakai `radiusMd` atau `radiusFull` sesuai theme final.

### 7.4 Elevation dan border

Fashion premium lebih baik menggunakan border halus dan layering daripada shadow gelap.

| Komponen | Style |
|---|---|
| Product card default | border tipis lembut atau tanpa border di atas page neutral; shadow sangat halus opsional |
| Search floating/header | surface elevated + shadow lembut saat scroll |
| Sticky checkout bar | top border lembut + shadow hanya ke atas |
| Bottom sheet/dialog | elevated surface + scrim terkontrol |
| Selected card/chip | border/tonal primary; bukan shadow tebal |

---

## 8. Photography, Asset, dan Iconography

### 8.1 Product image direction

Karena Mitologi Clothing menjual fashion/merchandise, image bukan dekorasi—image adalah konten utama.

- Gunakan rasio gambar produk konsisten: **3:4** untuk grid fashion; detail dapat memakai carousel 1:1 atau 3:4 mengikuti asset yang paling stabil.
- Product card tidak boleh menampilkan gambar dengan crop tidak konsisten antarkartu.
- Utamakan `BoxFit.cover` dengan area produk tetap terbaca; gunakan placeholder neutral saat image loading/failed.
- Banner koleksi sebaiknya editorial: satu foto hero yang kuat, text singkat, satu CTA; bukan tumpukan grafis promo.
- Image background harus sinkron dengan theme existing, tidak menambah palet brand kompetitor.

### 8.2 Icon system

- Gunakan satu gaya icon: rounded/outlined secara konsisten.
- Icon ukuran standar: 20px di input/list, 22–24px di action utama/nav, 16px di badge/meta.
- Wishlist: heart outline ketika belum dipilih, filled dengan brand/status color ketika dipilih.
- Cart badge harus terbaca namun tidak mendominasi header.
- Status payment/order memakai icon + teks, jangan warna saja.

### 8.3 Logo and brand moment

- Logo Mitologi Clothing harus mendapat ruang bersih pada splash/auth/home header apabila sudah tersedia.
- Jangan mengganti logo atau memodifikasi warna logo tanpa asset resmi project.
- Jangan menampilkan logo kompetitor atau UI yang membuat app terlihat sebagai marketplace lain.

---

## 9. Motion dan Interaction Feel

### 9.1 Prinsip motion

Motion harus memperjelas action, bukan memperlambat belanja.

| Interaksi | Animasi yang disarankan | Durasi |
|---|---|---:|
| Tap card menuju detail | native route transition / subtle shared feel bila sudah ada | platform default / 220–300ms |
| Wishlist toggle | scale kecil + fill transition | 160–220ms |
| Add to cart feedback | toast/snackbar atau mini confirmation | 180–250ms |
| Filter bottom sheet muncul | slide-up platform pattern | 250–320ms |
| Tab/category change | subtle fade/slide | 160–240ms |
| Skeleton ke konten | crossfade halus | 180–240ms |
| Payment status berhasil | icon transition minimal; tidak carnival | 240–420ms |

### 9.2 Haptic dan feedback

- Gunakan haptic ringan hanya jika project sudah memiliki support/utility atau dapat dilakukan tanpa menambah kompleksitas logic.
- Setiap action penting harus memberi feedback UI: add cart, wishlist, apply filter, retry, pay, copy order id apabila memang tersedia.
- Tidak boleh ada tombol terasa tidak merespons hanya karena request sedang diproses: tampilkan loading/disabled state.

---

## 10. Information Architecture Mobile

### 10.1 Bottom navigation

Gunakan bottom navigation maksimum 4–5 destinasi utama, bergantung pada route yang **sudah ada**. Struktur rekomendasi untuk customer mobile:

| Destination | Tujuan UX | Catatan implementasi |
|---|---|---|
| Beranda | discovery dan entrypoint personal | pertahankan route home existing |
| Katalog / Explore | browse semua produk/filter | gunakan label yang cocok dengan project existing |
| Wishlist | item tersimpan | hanya jika fitur sudah ada |
| Keranjang | item siap dibeli + badge quantity | badge mengambil state existing |
| Profil | akun, pesanan, pengaturan | tidak membuat fitur baru |

**Rule:** jika app existing hanya memiliki empat destinasi, jangan menambah tab baru hanya demi desain. Cart boleh tetap sebagai action header bila arsitektur lama demikian.

### 10.2 Global navigation behavior

- Home dan catalog boleh memiliki persistent bottom nav.
- Product detail membuka layar penuh dengan back button dan wishlist/cart action.
- Checkout dan payment sebaiknya meminimalkan distraksi; bottom nav dapat tidak tampil bila alur existing sudah demikian.
- Semua back/navigation harus mempertahankan behavior dan route existing.

---

## 11. Global Component Library

Seluruh screen harus dibangun dari komponen visual konsisten. Nama widget berikut bersifat rekomendasi; jangan merusak struktur project jika widget dengan nama berbeda sudah ada.

### 11.1 `AppTopBar`

**Kegunaan:** header standar dengan back/title/actions atau home greeting/search.

**Spesifikasi visual:**

- height efektif 56–64px di luar safe area;
- background menyatu dengan page atau elevated setelah scroll;
- title memakai `headlineSection` atau `titleCard` tergantung screen;
- action icon button area tap minimal 44×44px;
- cart badge kecil, jelas, dan tidak menutupi icon.

### 11.2 `CommerceSearchBar`

**Kegunaan:** search entry pada home/catalog.

**Anatomy:** leading search icon, hint text, optional filter icon/camera only bila sudah tersedia, tap/callback existing.

**Visual:**

- height 48–52px;
- radius `radiusFull` atau `radiusMd` konsisten;
- surface ringan, outline soft, focused state menggunakan primary;
- hint contoh: `Cari kaos, hoodie, atau merchandise`;
- jangan membuat search terlalu kecil atau sekadar icon.

### 11.3 `CategoryChip` / `FilterChip`

- horizontal scroll bila banyak kategori;
- selected menggunakan `brandPrimaryContainer` + text primary kuat;
- unselected surface neutral dengan outline;
- memiliki clear selected visual selain warna apabila memungkinkan;
- tap target nyaman.

### 11.4 `ProductCard`

**Komponen terpenting katalog.**

**Anatomy wajib berdasarkan data yang tersedia:**

1. image 3:4 dengan rounded corner;
2. badge opsional: `Baru`, `Diskon`, `Recommended`, atau stock state hanya bila datanya ada;
3. wishlist icon overlay kanan atas;
4. product name maksimal dua baris;
5. price utama;
6. original price/discount/rating hanya jika data existing tersedia;
7. optional quick-add hanya bila callback existing aman.

**Visual rules:**

- jangan memasukkan terlalu banyak informasi ke card;
- gambar harus mengambil porsi terbesar;
- nama item di bawah gambar, tidak menimpa image kecuali badge kecil;
- price dipertegas, metadata sekunder redup namun tetap terbaca;
- seluruh card dapat ditap menuju detail sesuai callback lama;
- wishlist memiliki feedback selected.

### 11.5 `CollectionHeroCard`

**Kegunaan:** section editorial home untuk koleksi/banner yang sudah tersedia atau dapat memetakan produk featured existing.

- image besar dengan overlay ringan hanya agar teks terbaca;
- heading maksimal dua baris;
- CTA satu saja seperti `Jelajahi Koleksi`;
- tidak meletakkan empat tombol di hero;
- tidak membuat promo countdown apabila data tidak tersedia.

### 11.6 `PriceBlock`

- harga utama paling dominan;
- original price dicoret bila memang tersedia dari data;
- discount label berupa chip singkat;
- installment, voucher, atau promo hanya tampil bila data/app sudah mendukungnya;
- total payment di checkout selalu memiliki hirarki lebih kuat daripada savings.

### 11.7 `PrimaryButton` dan `SecondaryButton`

| Type | Visual | Use case |
|---|---|---|
| Primary | filled `brandPrimary`, text on-primary | `Beli Sekarang`, `Lanjut Pembayaran`, `Bayar Sekarang` |
| Secondary | tonal/outline | `Tambah ke Keranjang`, `Lihat Detail`, `Coba Lagi` |
| Destructive | semantic error, digunakan hemat | hapus item/logout apabila sudah ada |
| Text action | text primary/icon | `Lihat Semua`, `Ubah`, `Pilih Semua` |

- height CTA utama: 52–56px;
- CTA penting tidak menggunakan disabled opacity terlalu rendah; masih harus terbaca;
- loading state menahan double tap tanpa mengubah alur bisnis.

### 11.8 `QuantityStepper`

- minus, value, plus di container rapi;
- tap target minimal nyaman;
- disabled state jelas ketika quantity tidak dapat berkurang/bertambah berdasarkan logic existing;
- tidak mengubah min/max quantity dari logic saat ini.

### 11.9 `OrderStatusBadge` / `PaymentStatusCard`

- status ditulis jelas: `Menunggu Pembayaran`, `Pembayaran Berhasil`, `Sedang Diproses`, `Dikirim`, `Selesai`, atau state existing;
- selalu icon + teks + warna status;
- payment status card di halaman hasil pembayaran memiliki title, penjelasan singkat, order/total jika tersedia, serta CTA lanjutan.

### 11.10 `EmptyState`, `ErrorState`, `SkeletonState`

- visual minimal dan konsisten, dapat memakai SVG/image existing atau simple icon;
- empty state memberi next best action;
- error state punya tombol `Coba Lagi` bila callback retry sudah ada;
- skeleton mengikuti ukuran komponen final agar tidak ada layout shift besar.

---

## 12. Screen Specification — Beranda / Home

### 12.1 Tujuan screen

Membangun kesan pertama premium sekaligus memudahkan pengguna masuk ke produk yang relevan dengan cepat.

### 12.2 Urutan konten rekomendasi

Susunan mengikuti data/fitur yang memang sudah ada. Jangan membuat section tanpa data.

1. Safe-area top header: brand/greeting ringan + action cart/notification bila existing.
2. Search bar jelas dan mudah ditap.
3. Hero koleksi atau promotion utama, satu fokus visual.
4. Category chips horizontal.
5. Section `Pilihan untuk Kamu` / rekomendasi AI apabila service/data sudah tersedia.
6. Section `Produk Terbaru` atau `Koleksi Populer` berdasarkan data existing.
7. Section curated seperti `Lengkapi Gayamu` apabila rekomendasi compatibility sudah terhubung.
8. Bottom navigation.

### 12.3 Header home

- Gunakan background bersih; jangan padat banner.
- Apabila terdapat nama pengguna, copy: `Halo, [Nama]` di label kecil dan `Temukan gaya barumu` sebagai title ringkas.
- Apabila tidak ada nama user, tampilkan logo/title Mitologi Clothing dan tagline pendek.
- Action cart harus terlihat dan memuat badge count dari state existing.

### 12.4 Hero utama

- Tinggi: sekitar 188–224px pada mobile normal.
- Radius: `radiusXl`.
- Konten: eyebrow kecil, heading pendek, optional supporting line, CTA.
- Satu hero aktif sudah cukup; carousel hanya jika sebelumnya telah tersedia dan benar-benar diperlukan.
- Jika menggunakan carousel existing, indikator dibuat minimal dan tidak mengambil perhatian produk.

### 12.5 Rekomendasi AI di home

Recommendation merupakan keunggulan produk Mitologi Clothing. Tampilan harus lebih menarik daripada product list biasa.

**Header:**
- title: `Pilihan untuk Kamu` atau label existing;
- subtitle opsional: `Disesuaikan dari produk yang kamu sukai` hanya jika klaim sesuai logic/data;
- action: `Lihat Semua` bila route tersedia.

**Card treatment:**
- gunakan product card yang sama dengan badge tonal kecil `Recommended` atau icon sparkle abstrak non-emoji;
- jangan mengklaim AI mengetahui preferensi tertentu yang tidak dikirim sistem;
- bila data rekomendasi kosong, tampilkan fallback section sesuai state existing, bukan data palsu.

### 12.6 Home loading/empty/error

- Loading: skeleton untuk header, hero, chips, dan satu baris product cards.
- Error load sebagian: screen tetap bisa menampilkan section yang berhasil; gagal recommendation tidak harus merusak seluruh halaman apabila logic existing mendukung partial UI.
- Jika tidak ada produk: empty state profesional `Produk belum tersedia` dengan action refresh bila ada.

---

## 13. Screen Specification — Katalog / Explore / Search Results

### 13.1 Tujuan screen

Menyajikan seluruh produk dalam cara yang cepat dipindai, mudah disaring, dan tetap terlihat premium.

### 13.2 Struktur katalog

1. App bar: title + cart action.
2. Search field atau search trigger sticky pada scroll bila sudah tersedia.
3. Horizontal category/filter chips.
4. Sorting/filter toolbar ringkas: jumlah produk bila tersedia, `Filter`, `Urutkan`.
5. Product grid dua kolom di ponsel.
6. Pagination/infinite loading state mengikuti logic lama.

### 13.3 Product grid

- Dua kolom untuk lebar ponsel normal; jangan memaksa tiga kolom sehingga informasi fashion sempit.
- Aspect ratio image 3:4.
- Horizontal gap 12px; vertical gap 20–24px.
- Product card height menyesuaikan text maksimal dua baris dan harga.
- Tablet dapat menggunakan 3–4 kolom berdasarkan available width.

### 13.4 Filter dan sorting

- Tampilkan filter dalam modal bottom sheet bila implementasi existing mendukung.
- Filter chip active terlihat jelas.
- Tombol `Reset` dan `Terapkan` hanya menghubungkan callback/filter state existing.
- Jangan menambahkan opsi filter yang tidak tersedia dari data backend/local existing.
- Pilihan size/color/category hanya muncul jika sudah didukung aplikasi.

### 13.5 Search experience

- Initial state: tampilkan hint atau recent/popular hanya bila data tersedia.
- Search result: tampilkan query dan jumlah result bila telah diketahui dari state.
- Empty result copy: `Produk tidak ditemukan` dan saran mengubah kata kunci/filter.
- Debounce/API logic tidak boleh diubah pada redesign UI kecuali diminta dalam task terpisah.

---

## 14. Screen Specification — Product Detail Page (PDP)

### 14.1 Tujuan screen

Mengubah ketertarikan visual menjadi keputusan beli dengan rasa yakin dan tanpa informasi berantakan.

### 14.2 Layout PDP mobile

1. Full-width image gallery/carousel di bagian atas.
2. Floating/back header actions: back, wishlist, cart/share bila sudah tersedia.
3. Product info block: category/label kecil, nama produk, harga, diskon bila ada.
4. Variant selection: warna/size apabila datanya ada.
5. Stock/availability state.
6. Description/material/detail expandable.
7. Recommendation section: `Padukan dengan` / `Kamu mungkin suka` sesuai data existing.
8. Sticky bottom action: `Tambah ke Keranjang` + `Beli Sekarang`, atau struktur action yang already exists.

### 14.3 Gallery

- Gambar menjadi fokus dengan background clean.
- Indikator posisi gambar minimal.
- Jangan overlay text marketing besar pada gambar produk detail.
- Image failed state elegan dan tidak merusak ukuran layout.

### 14.4 Variant/size selection

- Jika user wajib memilih size/variant, UI harus terlihat sebagai langkah penting sebelum CTA.
- Selected variant menggunakan tonal primary/border jelas.
- Out-of-stock menggunakan disabled style dan label bila datanya tersedia.
- Error pilih varian harus dekat dengan control, bukan hanya snackbar jauh dari konteks.
- Redesign hanya mengubah penyajian; rules validasi tetap berasal dari logic existing.

### 14.5 Description dan product trust

- Detail produk menggunakan accordion/collapsible bila kontennya panjang dan widget lama memungkinkan.
- Tampilkan atribut yang benar-benar tersedia: bahan, ukuran, care instruction, kategori, stock, atau lainnya.
- Jangan membuat rating, review, shipping promise, authenticity guarantee, atau return policy apabila tidak berasal dari data/requirement.

### 14.6 Sticky CTA PDP

- Berada di bawah layar dengan safe-area padding.
- Surface elevated dan top border tipis.
- `Tambah ke Keranjang` secondary; `Beli Sekarang` primary jika kedua action ada.
- Apabila hanya ada satu action existing, tampilkan satu tombol utama full-width; jangan membuat flow baru.
- Tampilkan loading/disabled sesuai state callback existing.

---

## 15. Screen Specification — Wishlist

### 15.1 Tujuan screen

Memberi ruang penyimpanan produk yang terasa curated dan mengajak pengguna melanjutkan pembelian tanpa tekanan.

### 15.2 Layout

- App bar: title `Wishlist` dan jumlah item bila tersedia.
- Gunakan grid dua kolom agar konsisten dengan katalog.
- Tombol heart selected mudah diakses pada setiap card.
- Optional action ke cart hanya bila fitur existing mendukungnya.

### 15.3 Empty state

- Icon/illustration ringan.
- Heading: `Wishlist kamu masih kosong`.
- Supporting copy: `Simpan produk favoritmu untuk dilihat lagi nanti.`
- CTA: `Jelajahi Produk` menuju route catalog/home existing.

---

## 16. Screen Specification — Keranjang / Cart

### 16.1 Tujuan screen

Memastikan pengguna mengerti item yang akan dibeli dan total sementara sebelum menuju checkout.

### 16.2 Struktur cart

1. App bar `Keranjang` + optional select/delete action existing.
2. Item list yang mudah dipindai.
3. Voucher/promo hanya apabila sudah menjadi fitur aplikasi.
4. Ringkasan harga singkat.
5. Sticky checkout area: total + CTA `Checkout`.

### 16.3 Cart item card

**Anatomy:**

- thumbnail konsisten 72–88px;
- nama produk maksimal dua baris;
- variant/size sebagai secondary line bila ada;
- harga jelas;
- quantity stepper;
- remove/wishlist action hanya bila existing.

**Rules:**

- apabila produk unavailable/out-of-stock didukung oleh state, tampilkan banner kecil dan disable checkout item sesuai logic;
- quantity button tidak boleh mengubah aturan stok/minimum;
- item card tidak boleh terlalu tinggi akibat metadata yang tidak penting.

### 16.4 Cart summary sticky bar

- tampilkan label `Total` dan nominal utama;
- CTA primary `Checkout`;
- biaya pengiriman/pembayaran final dapat ditampilkan di checkout jika memang belum tersedia pada tahap cart;
- jangan menyembunyikan total di bawah bottom nav/safe area.

### 16.5 Empty cart

Copy rekomendasi:

- title: `Keranjangmu masih kosong`;
- description: `Temukan produk Mitologi Clothing yang cocok untuk gayamu.`;
- CTA: `Mulai Belanja`.

---

## 17. Screen Specification — Checkout dan Midtrans Payment

### 17.1 Tujuan screen

Membuat proses pembayaran terasa aman, sederhana, dan transparan. Pada tahap ini desain harus tenang: kurangi distraction, promosional overload, dan navigasi yang tidak perlu.

### 17.2 Struktur checkout

Gunakan section cards terpisah dengan urutan mengikuti data/flow existing:

1. App bar `Checkout`.
2. Alamat pengiriman apabila fitur tersedia.
3. Ringkasan item pesanan.
4. Opsi pengiriman apabila fitur tersedia.
5. Metode pembayaran / entry Midtrans sesuai flow existing.
6. Price breakdown: subtotal, pengiriman, potongan, biaya lain hanya jika datanya benar-benar tersedia.
7. Grand total.
8. CTA sticky `Lanjut Pembayaran` / `Bayar Sekarang`.

### 17.3 Price breakdown

- Grand total adalah angka paling kuat dalam screen.
- Semua biaya yang tersedia harus menggunakan label mudah dipahami.
- Jangan menciptakan diskon/free shipping palsu hanya untuk tampilan.
- Jika backend hanya memberi total, tampilkan data tersebut dengan jujur tanpa simulasi breakdown.

### 17.4 Payment flow UI

- Saat token/payment page sedang diproses, tampilkan loading state dengan copy jelas: `Menyiapkan pembayaran...`.
- Saat user diarahkan ke atau kembali dari Midtrans, jangan membuat asumsi status sukses sebelum state dari sistem menyatakannya.
- Payment state yang perlu memiliki tampilan berbeda apabila tersedia pada logic: pending, success/settlement, failed/deny/cancel/expire.

### 17.5 Payment status screen

| Status | Visual tone | Heading | CTA yang sesuai route existing |
|---|---|---|---|
| Success | success icon + calm positive card | `Pembayaran berhasil` | `Lihat Pesanan` / `Kembali Belanja` |
| Pending | warning/neutral icon | `Menunggu pembayaran` | `Lihat Detail Pembayaran` / `Cek Status` jika ada |
| Failed | error icon tanpa panic visual | `Pembayaran belum berhasil` | `Coba Bayar Lagi` jika logic mendukung |
| Expired/Cancelled | neutral/error-soft | `Pembayaran berakhir` | route tindakan existing |

- Status harus sama dengan data aplikasi; UI dilarang mengubah payment decision.
- Jangan mengklaim order dikirim sebelum status pesanan memang menyatakan demikian.

---

## 18. Screen Specification — Pesanan dan Detail Pesanan

### 18.1 Daftar pesanan

- App bar: `Pesanan Saya`.
- Filter tabs/chips berdasarkan status existing, misalnya semua/diproses/dikirim/selesai jika data mendukung.
- Order card menampilkan order reference/date, item preview, total, status badge, dan CTA `Lihat Detail`.
- Status text lebih penting daripada dekorasi warna.

### 18.2 Detail pesanan

Urutan blok yang dianjurkan:

1. status order utama;
2. payment status jika berbeda/tersedia;
3. item yang dibeli;
4. alamat/pengiriman jika tersedia;
5. payment/price summary;
6. action lanjutan sesuai feature existing.

Timeline order hanya digunakan jika backend/state sudah menyediakan data tahap tracking. Jangan membuat tracking timeline dummy.

---

## 19. Screen Specification — AI Recommendation Experience

### 19.1 Peran recommendation dalam brand

Recommendation adalah pembeda Mitologi Clothing dari toko fashion biasa. Namun UI harus jujur: menampilkan rekomendasi yang dikirim service, bukan mengarang alasan personalisasi.

### 19.2 Jenis tampilan yang dapat digunakan sesuai data

| Data/fitur yang tersedia | Section label yang sesuai | UI treatment |
|---|---|---|
| daftar rekomendasi general/personal | `Pilihan untuk Kamu` | horizontal product cards / grid |
| item kompatibel dengan PDP | `Padukan dengan Produk Ini` | horizontal pair/product cards |
| related/similar products | `Produk Serupa` | grid/list sederhana |
| fallback popular products | `Sedang Banyak Disukai` hanya jika benar dari data | regular product section tanpa klaim AI |

### 19.3 Rules recommendation UI

- Gunakan badge `Recommended` dengan style lembut, bukan neon/heboh.
- Hindari kalimat seperti “AI membaca gaya kamu” kecuali memang ada penjelasan dan data yang mendukung.
- Jika recommendation gagal, katalog/detail tetap usable; tampilkan fallback UI hanya jika logic telah menanganinya.
- Section recommendation tidak boleh menggeser CTA product detail hingga sulit dijangkau.

---

## 20. Screen Specification — Profil, Akun, dan Autentikasi

### 20.1 Profile

- Header profil sederhana: avatar atau initial, nama/email dari data existing.
- Menu dikelompokkan: pesanan, wishlist, alamat/payment apabila ada, pengaturan, bantuan/logout apabila ada.
- Gunakan list tiles clean dengan icon konsisten dan separator lembut.
- Jangan menampilkan statistik palsu atau membership tier yang tidak tersedia.

### 20.2 Login/Register bila tersedia

- Design fashion-premium: logo, title singkat, input lega, CTA utama terlihat.
- Keyboard-safe layout; field tidak tertutup keyboard.
- Input error dekat dengan field dan konsisten.
- Social login hanya tampil jika benar-benar berfungsi.
- Jangan mengubah validasi atau authentication flow.

### 20.3 Copy tone

Gunakan Bahasa Indonesia yang ringkas, natural, dan konsisten:

- `Masuk` bukan bergantian dengan `Login` tanpa alasan.
- `Buat Akun` atau `Daftar` pilih satu sesuai wording existing dan pertahankan.
- `Keluar dari akun` untuk destructive confirmation, bukan label ambigu.

---

## 21. State Design System

### 21.1 Loading state

- Gunakan skeleton sesuai struktur final, bukan spinner layar penuh untuk seluruh kasus.
- Spinner diperbolehkan untuk action kecil seperti submit payment/login.
- Product grid skeleton: gambar, dua text bars, price line.
- Cart/checkout skeleton jangan menampilkan nominal palsu.

### 21.2 Empty state matrix

| Screen | Title | Supporting text | CTA |
|---|---|---|---|
| Search result | `Produk tidak ditemukan` | `Coba gunakan kata kunci lain atau hapus filter.` | `Reset Filter` bila callback ada |
| Wishlist | `Wishlist kamu masih kosong` | `Simpan produk favorit untuk dilihat kembali.` | `Jelajahi Produk` |
| Cart | `Keranjangmu masih kosong` | `Temukan produk yang cocok untuk gayamu.` | `Mulai Belanja` |
| Orders | `Belum ada pesanan` | `Pesanan yang kamu buat akan tampil di sini.` | `Belanja Sekarang` |
| Recommendation | `Belum ada rekomendasi` | `Jelajahi koleksi kami terlebih dahulu.` | action hanya bila route tersedia |

### 21.3 Error state

- Error umum: icon sederhana, title jelas, penjelasan pendek, CTA `Coba Lagi`.
- Error pembayaran harus lebih spesifik bila state menyediakan pesan; jangan mereduksi payment failure menjadi generic network error.
- Error image hanya mengganti thumbnail, tidak menutup akses informasi produk.

### 21.4 Disabled state

- Tombol disabled tetap terbaca; gunakan fill/outline muted dengan text kontras cukup.
- Jelaskan sebab disable ketika penting, misalnya varian belum dipilih atau item habis, berdasarkan state existing.

---

## 22. Accessibility dan Usability Standards

Redesign wajib membuat aplikasi lebih mudah dipakai, bukan hanya lebih cantik.

### 22.1 Touch target

- Semua icon button/tappable element: target interaksi minimal sekitar 44–48px.
- Product wishlist overlay memiliki background/surface agar tetap terlihat pada foto terang/gelap.
- Quantity stepper tidak dibuat terlalu kecil.

### 22.2 Contrast dan readable UI

- Text utama harus jelas di atas surface/image.
- Overlay pada hero digunakan secukupnya agar title terbaca.
- Primary button memiliki contrast yang cukup berdasarkan warna existing.
- Secondary/muted text tidak dibuat terlalu pucat.
- Status tidak bergantung pada warna: selalu ada teks/icon.

### 22.3 Semantics

Untuk implementasi widget custom, tambahkan semantics yang relevan tanpa menyentuh logic:

- product card: nama produk dan harga;
- wishlist button: `Tambahkan ke wishlist` / `Hapus dari wishlist`;
- cart badge: jumlah item;
- quantity control: aksi tambah/kurangi;
- payment status: status dibacakan secara jelas.

### 22.4 Text scaling dan orientation

- Jangan menonaktifkan text scaling.
- Judul atau CTA tidak boleh overflow ketika font device membesar.
- App harus tetap usable ketika orientasi berubah atau pada window lebih lebar jika project mendukungnya.

---

## 23. Responsive dan Adaptive Flutter Behavior

### 23.1 Breakpoint berbasis available width

Gunakan `LayoutBuilder` atau `MediaQuery.sizeOf(context)` sesuai ruang layout yang dibutuhkan. Jangan sekadar menebak berdasarkan jenis device.

| Available width | Behavior utama |
|---:|---|
| `< 360px` | padding 12–16px; grid dua kolom dengan content sangat ringkas; CTA tidak terpotong |
| `360–599px` | default mobile experience; grid dua kolom; bottom navigation |
| `600–839px` | tablet compact/foldable; grid 3 kolom; max content width bila detail terlalu luas |
| `>= 840px` | tablet landscape; grid 3–4 kolom; optional navigation rail hanya bila arsitektur UI memang memerlukannya |

### 23.2 SafeArea

- Sticky bottom CTA, bottom navigation, checkout bar, dan modal action wajib aman dari gesture area/notch.
- Hero boleh edge-to-edge apabila memang didesain demikian, tetapi action/header tidak boleh tertutup status bar.

### 23.3 Large screen layout

- Jangan meregangkan product detail text/full-width hingga sulit dibaca pada tablet.
- PDP tablet dapat menempatkan image dan informasi produk berdampingan hanya sebagai presentational adaptation, dengan data/callback tetap sama.
- Catalog tablet menggunakan grid lebih banyak kolom, bukan memperbesar card tanpa batas.

---

## 24. Flutter Component Theme Direction

Bagian ini adalah panduan presentasional. Sesuaikan nama file dan struktur project existing; jangan memindahkan arsitektur aplikasi tanpa kebutuhan.

### 24.1 Component theme yang dirapikan

- `textTheme`
- `filledButtonTheme`
- `outlinedButtonTheme`
- `iconButtonTheme`
- `inputDecorationTheme`
- `cardTheme`
- `chipTheme`
- `navigationBarTheme`
- `bottomSheetTheme`
- `snackBarTheme`
- `dividerTheme`

### 24.2 Contoh aturan styling konseptual

```dart
// Styling direction only — preserve existing ColorScheme values.
ThemeData themeFromExisting(ThemeData current) {
  final c = current.colorScheme;
  return current.copyWith(
    useMaterial3: true,
    scaffoldBackgroundColor: c.surface,
    cardTheme: CardThemeData(
      elevation: 0,
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: c.outlineVariant.withValues(alpha: .45)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surfaceContainerLowest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c.primary, width: 1.5),
      ),
    ),
  );
}
```

**Penting:** agent tidak perlu menyalin snippet ini mentah-mentah. Gunakan hanya bila cocok dengan versi Flutter dan struktur theme project.

### 24.3 Penyusunan widget aman

Jika project sudah memiliki widget misalnya `ProductCard`, `CustomButton`, `CustomTextField`, atau `BottomNav`, redesign komponen tersebut secara in-place lebih aman daripada mengganti semua penggunaan. Preserve constructor, parameter, callbacks, keys, dan state binding yang ada.

---

## 25. Recommended Presentation-Layer File Organization

Gunakan struktur ini **hanya bila** sejalan dengan project saat ini. Tidak wajib memindahkan semua file.

```text
lib/
  core/
    theme/
      app_theme.dart                 # map dari warna existing
      app_color_tokens.dart          # semantic alias, bukan palet baru
      app_typography.dart
      app_spacing.dart
      app_radius.dart
  shared/
    widgets/
      app_top_bar.dart
      commerce_search_bar.dart
      product_card.dart
      collection_hero_card.dart
      price_block.dart
      app_primary_button.dart
      app_secondary_button.dart
      quantity_stepper.dart
      order_status_badge.dart
      app_empty_state.dart
      app_error_state.dart
      product_card_skeleton.dart
  features/
    home/presentation/
    catalog/presentation/
    product_detail/presentation/
    wishlist/presentation/
    cart/presentation/
    checkout/presentation/
    orders/presentation/
    profile/presentation/
```

### 25.1 Warnings

- Jangan memindahkan repository/service/controller ke folder baru hanya karena UI dirapikan.
- Jangan rename field model atau endpoint agar sesuai nama widget.
- Jangan menghapus widget lama sebelum dipastikan seluruh flow sudah menggunakan widget baru dengan benar.

---

## 26. Visual Specification per Flow Kritis

### 26.1 Flow: Discovery ke Detail

**Home → Search/Kategori → Product Card → Product Detail**

- pengguna selalu bisa melihat jalur menuju cart;
- transition tidak menghilangkan konteks;
- nama/harga pada card konsisten dengan detail;
- selected wishlist state tetap konsisten karena menggunakan state lama, bukan local UI palsu.

### 26.2 Flow: Detail ke Cart

**PDP → pilih variant/size → add to cart → cart feedback**

- CTA sticky tidak tertutup bottom inset;
- error belum pilih size tampil dekat selector;
- setelah add sukses, tampilkan feedback visual berdasarkan action result existing;
- jangan otomatis navigasi ke cart apabila sebelumnya flow tidak demikian.

### 26.3 Flow: Cart ke Payment

**Cart → Checkout → Midtrans → Payment Status → Order Detail**

- cart total dan checkout total mudah dibandingkan;
- pengguna memahami sedang berada di tahap pembayaran;
- loading/proses tidak terasa sebagai error;
- payment success/pending/failure sangat jelas;
- CTA sesudah payment mengikuti route dan state existing.

### 26.4 Flow: Recommendation ke Purchase

**Personal recommendation → PDP → add/cart/checkout**

- recommendation card menggunakan product navigation biasa;
- label personalisasi tidak berlebihan;
- tidak ada perbedaan behavior pembelian antara produk rekomendasi dan produk katalog kecuali logic memang menentukan demikian.

---

## 27. Content dan Microcopy Guidelines

### 27.1 Voice and tone

Mitologi Clothing berbicara seperti brand fashion yang ramah dan percaya diri:

- ringkas;
- modern;
- tidak terlalu formal;
- tidak memaksa dengan gimmick promo berlebihan;
- jelas pada proses transaksi.

### 27.2 Label CTA yang dianjurkan

| Konteks | Label yang bersih |
|---|---|
| Hero | `Lihat Koleksi` / `Belanja Sekarang` |
| Product card/detail | `Lihat Detail` bila dibutuhkan |
| PDP | `Tambah ke Keranjang`, `Beli Sekarang` |
| Cart | `Checkout` |
| Checkout | `Lanjut Pembayaran` / `Bayar Sekarang` sesuai flow |
| Error | `Coba Lagi` |
| Empty wishlist/cart | `Jelajahi Produk` / `Mulai Belanja` |
| Orders | `Lihat Pesanan` / `Lihat Detail` |

### 27.3 Copy yang harus dihindari

- klaim diskon, gratis ongkir, original/authentic, stock terbatas, best seller, atau rekomendasi personal tanpa data pendukung;
- copy sangat panjang di card;
- teks all caps terlalu banyak;
- label action ambigu seperti `Submit` untuk checkout/payment.

---

## 28. UI Testing dan Acceptance Checklist

### 28.1 Regression guard: logic tidak berubah

Sebelum merge redesign, verifikasi seluruh poin ini:

- [ ] login/register tetap bekerja apabila tersedia;
- [ ] daftar produk tetap berasal dari sumber data yang sama;
- [ ] pencarian/filter/sorting tetap bekerja sesuai behavior lama;
- [ ] wishlist toggle tetap tersimpan sesuai state existing;
- [ ] add/remove/update quantity cart tetap bekerja;
- [ ] validasi variant/size tetap sama;
- [ ] checkout tetap membuat order sesuai flow lama;
- [ ] Midtrans/payment integration tidak diubah;
- [ ] payment status dan riwayat pesanan tetap tampil sesuai response asli;
- [ ] AI recommendation tetap mengambil data dari service/state lama;
- [ ] routes dan deep link existing tidak rusak.

### 28.2 Visual quality checklist

- [ ] warna brand existing tetap dipakai sebagai primary identity;
- [ ] tidak ada screen yang terasa berasal dari design system berbeda;
- [ ] typography hierarchy konsisten;
- [ ] semua product images memiliki framing konsisten;
- [ ] CTA utama terlihat jelas pada setiap alur kritis;
- [ ] spacing rapi dan tidak penuh sesak;
- [ ] states loading/empty/error/disabled/success memiliki tampilan khusus;
- [ ] tidak ada overflow pada layar sempit;
- [ ] tidak ada bottom CTA tertutup gesture bar;
- [ ] tidak ada hardcoded warna kompetitor baru;
- [ ] tidak ada emoji sebagai icon komponen UI;
- [ ] tablet/landscape tetap usable.

### 28.3 Accessibility checklist

- [ ] tap target tombol/icon memadai;
- [ ] contrast teks/CTA dapat dibaca;
- [ ] status payment/order tidak mengandalkan warna saja;
- [ ] text scale besar tidak memotong label kritis;
- [ ] semantic label pada custom actionable widget ditambahkan;
- [ ] focus/keyboard navigation dipertimbangkan untuk tablet/web build apabila project mendukungnya.

---

## 29. Rencana Implementasi Bertahap

Redesign jangan dilakukan sekaligus secara acak. Kerjakan dalam urutan berikut agar risiko kecil dan hasil cepat terlihat.

### Phase 0 — Audit existing UI

- inventaris seluruh customer-facing screen;
- temukan theme/color/font/icon existing;
- catat widget reused dan constructor-nya;
- identifikasi feature yang nyata tersedia versus hanya rencana proposal;
- screenshot semua screen sebelum redesign.

**Output:** screen inventory dan mapping token warna existing.

### Phase 1 — Design foundation

- rapikan theme tokens tanpa mengganti brand color;
- tetapkan type scale, spacing, radius, component styling;
- buat standard button/input/chip/card/empty/skeleton.

**Output:** app sudah memiliki komponen dasar yang konsisten.

### Phase 2 — Commerce discovery

- redesign home;
- redesign catalog/search/filter;
- redesign product card;
- redesign recommendation section.

**Output:** pengguna merasakan peningkatan utama saat browsing.

### Phase 3 — Conversion flow

- redesign PDP;
- redesign wishlist/cart;
- redesign checkout dan payment status.

**Output:** alur menuju transaksi terasa profesional dan jelas.

### Phase 4 — Retention/account

- redesign orders/detail order;
- redesign profile/auth screen bila tersedia;
- lengkapkan empty/error/loading states.

**Output:** pengalaman aplikasi end-to-end konsisten.

### Phase 5 — QA polish

- test small phone/tablet;
- visual regression;
- test state payment/order/recommendation;
- inspect overflow/contrast/semantics;
- final spacing dan animation polish.

---

## 30. Priority Screen Matrix

| Priority | Screen/Component | Alasan |
|---:|---|---|
| P0 | Theme foundation, typography, buttons, ProductCard | memengaruhi hampir semua screen |
| P0 | Home, catalog, PDP | kesan pertama dan keputusan membeli |
| P0 | Cart, checkout, payment state | menentukan kepercayaan transaksi |
| P1 | Wishlist dan recommendations | meningkatkan personalisasi dan return usage |
| P1 | Orders/detail order | kejelasan after-purchase |
| P2 | Profile/auth/supporting screens | konsistensi lengkap dan retention |

---

## 31. Handoff Prompt untuk AI Coding Agent

Copy instruksi berikut ketika meminta AI mengimplementasikan UI pada repository Flutter:

```text
Baca design.md ini secara menyeluruh dan implementasikan redesign UI-only pada aplikasi Flutter Mitologi Clothing.

Batas keras:
1. Jangan mengubah business logic, API, model, state management, routes, authentication flow, cart calculation, payment/Midtrans logic, recommendation algorithm, atau backend contract.
2. Pertahankan theme warna existing. Audit ThemeData/ColorScheme/constants pada project, lalu map ke semantic design tokens. Jangan mengganti primary/secondary brand color dengan palet baru.
3. Refactor hanya presentation layer: ThemeData component styles, reusable visual widgets, layout, spacing, typography, icon, image treatment, empty/loading/error/payment-status views, responsive behavior, dan animasi visual ringan.
4. Pertahankan constructor/callback/data binding widget existing kecuali perubahan murni presentasional yang backward-compatible.
5. Jangan membuat fitur atau dummy data baru. Tampilkan hanya informasi yang sudah didukung state/data project.
6. Terapkan screen secara bertahap: foundation → home/catalog/product detail → wishlist/cart → checkout/payment → orders/profile → QA.
7. Setelah setiap screen selesai, uji flow existing agar tidak ada regresi fungsi.

Arah visual:
Fashion e-commerce premium, bersih, photography-first, curated, personal melalui recommendation section, cepat dipakai seperti marketplace modern, tetapi bukan clone Shopee/Tokopedia/TikTok Shop. Jangan gunakan emoji sebagai icon UI.

Mulai dengan:
- scan struktur lib/ dan theme/color existing;
- laporkan screen/widget/theme yang ditemukan;
- buat rencana file yang akan diedit khusus UI;
- baru implementasikan tanpa merusak flow yang ada.
```

---

## 32. Final Design Acceptance Statement

UI Mitologi Clothing yang baru harus terasa sebagai **mobile fashion storefront modern dengan kenyamanan marketplace dan personalisasi cerdas**, bukan sebagai template toko online biasa. Ia mengambil pelajaran dari pola commerce terbaik—discovery yang cepat, product browsing yang efisien, content visual yang menarik, checkout yang percaya diri, dan rekomendasi yang relevan—tanpa menyalin identitas aplikasi lain.

Keberhasilan redesign dinilai bukan dari banyaknya animasi atau banner, melainkan dari hal-hal berikut:

- brand tetap dikenali melalui warna existing;
- pengguna lebih nyaman melihat dan memilih produk;
- detail produk terlihat lebih meyakinkan;
- cart dan checkout lebih jelas;
- payment status lebih terpercaya;
- recommendation tampil bernilai;
- seluruh improvement dilakukan tanpa mengubah logika aplikasi yang sudah bekerja.

---

## 33. Referensi Desain dan Implementasi

Referensi berikut digunakan sebagai arah prinsip dan benchmark pola, bukan untuk menjiplak tampilan maupun identitas brand:

1. Flutter Documentation — Adaptive and responsive design: https://docs.flutter.dev/ui/adaptive-responsive
2. Flutter Documentation — SafeArea and MediaQuery: https://docs.flutter.dev/ui/adaptive-responsive/safearea-mediaquery
3. Flutter Documentation — User input and accessibility: https://docs.flutter.dev/ui/adaptive-responsive/input
4. Material Design 3 — Cards: https://m3.material.io/components/cards/overview
5. Material Design 3 — Chips: https://m3.material.io/components/chips/overview
6. Material Design 3 — Buttons: https://m3.material.io/components/buttons/overview
7. Shopee Indonesia official commerce experience reference: https://shopee.co.id/
8. TikTok Shop official commerce/discovery reference: https://ads.tiktok.com/help/article/tiktok-shopping-and-showcase

