# SISTEM DESAIN & PANDUAN IMPLEMENTASI MITOLOGI CLOTHING MOBILE
*(Hasil Pemetaan Komprehensif dari Next.js Commerce ke Flutter Mobile)*

Dokumen ini menyajikan panduan sistem desain yang sangat detail dan lengkap untuk mentransisikan identitas brand, struktur data, komponen visual, tata letak interaksi, dan alur mikro-animasi dari platform **Next.js Commerce** (Web) ke dalam aplikasi **Flutter Mobile** (`mitologi_clothing_mobile`).

---

## 1. PONDASI BRAND & PRINSIP TEMA (DESIGN TOKENS)

Tema utama mengusung **"Luxurious Indonesian Heritage & Modern Premium Fashion"** yang memadukan keindahan mitologi Nusantara dengan kesederhanaan minimalis modern.

### A. Palet Warna (Color Palette)

| Kategori Token | Nama Token (Web / CSS) | Nilai Hex / OKLCH (Web) | Token Flutter (`AppColors`) | Peran Desain / Kasus Penggunaan Mobile |
| :--- | :--- | :--- | :--- | :--- |
| **Primary** | `mitologi-navy` | `oklch(0.25 0.05 260)` / `#000613` | `Color(0xFF000613)` | Latar belakang header, tombol aksi utama (CTA), teks judul premium. |
| **Primary Light** | `mitologi-navy-light`| `oklch(0.32 0.06 260)` / `#1E3A5F` | `Color(0xFF001F3F)` | Gradient penyeimbang navy, aksen panel aktif, hover-equivalent. |
| **Secondary** | `mitologi-gold` | `oklch(0.75 0.16 75)` / `#CA8A04` | `Color(0xFF735C00)` | Lencana kurasi, bintang rating, lencana stok terbatas, aksen loyalitas. |
| **Secondary Light**| `fashion-highlight` | `oklch(0.82 0.16 75)` / `#FED65B` | `Color(0xFFFED65B)` | Gradasi emas premium, latar belakang diskon tipis, highlight promo. |
| **Background** | `background` | `#f8fafc` | `Color(0xFFFAF9F5)` | Kanvas latar belakang utama (Creamy warm white yang nyaman di mata). |
| **Surface** | `surface` | `#ffffff` | `Color(0xFFFFFFFF)` | Dasar kartu produk, lembar bawah (bottom sheets), kartu keranjang belanja. |
| **Muted** | `muted` | `#f1f5f9` | `Color(0xFFF4F4F0)` | Latar belakang input form default, kerangka skeleton loader. |
| **Border** | `border` | `#e2e8f0` | `Color(0xFFEFEEEA)` | Garis batas tipis pemisah antar elemen, border kartu statis. |
| **Success** | `success` | `#10b981` | `Color(0xFF2E7D32)` | Indikator pembayaran sukses, konfirmasi stok ada, status pengiriman. |
| **Error** | `error` | `#ef4444` | `Color(0xFFBA1A1A)` | Pesan error validasi form, notifikasi transaksi gagal. |

### B. Tipografi (Typography)

Aplikasi mobile memadukan tiga keluarga font premium untuk menciptakan ritme visual yang seimbang:

1. **Brand Headers (`headlineLarge`, `headlineMedium`)**: Menggunakan font **Outfit** (Google Fonts). Berkarakter tegas, modern, dan bernuansa butik kelas atas.
2. **Subtitles & Card Titles (`titleLarge`, `titleMedium`)**: Menggunakan font **Inter** atau **Noto Serif** untuk memberikan sentuhan etnik klasik/elegan ketika menyorot nama koleksi mitologi.
3. **Body Texts & Forms (`bodyLarge`, `bodyMedium`, `labelLarge`)**: Menggunakan font **Plus Jakarta Sans** (Google Fonts). Sangat bersih, proporsional, dan nyaman dibaca pada layar ponsel berukuran kecil.

#### Pemetaan Skala Tipografi:
*   **Hero/Title Utama Screen**: `Outfit`, Bold, Size `32`, Line Height `1.2` (`headlineLarge` di Flutter).
*   **Judul Section**: `Outfit`, Bold, Size `24`, Line Height `1.25` (`headlineMedium` di Flutter).
*   **Nama Produk di Kartu**: `Inter`, Semi-Bold, Size `16`, Line Height `1.3` (`titleMedium` di Flutter).
*   **Teks Deskripsi Produk**: `Plus Jakarta Sans`, Regular, Size `14`, Line Height `1.45`, Warna `onSurfaceVariant` (`bodyMedium` di Flutter).
*   **Label Tombol & Menu**: `Inter`, Semi-Bold, Size `14`, Tracking `0.5px`, Semua Huruf Besar/Kapital (atau Title Case) (`labelLarge` di Flutter).

### C. Elevasi & Bayangan (Shadows & Elevation)

Mengikuti prinsip **Premium Corporate Trust**, aplikasi mobile tidak menggunakan bayangan hitam pekat yang kasar. Semua bayangan menggunakan opacity sangat halus berbasis warna Navy primer:
*   **`AppShadows.card`**: `BoxShadow(color: Color(0x14000613), blurRadius: 20, offset: Offset(0, 10))` - Untuk kartu produk, kartu promo di beranda.
*   **`AppShadows.floating`**: `BoxShadow(color: Color(0x26000613), blurRadius: 20, offset: Offset(0, 6), spreadRadius: -4)` - Untuk tombol melayang (seperti WhatsApp Floating, Chatbot Trigger, Bottom Bar).
*   **`AppShadows.glass`**: `BoxShadow(color: Color(0x0D000613), blurRadius: 16, offset: Offset(0, 4))` - Efek kedalaman kaca akrilik (glassmorphism) pada panel filter melayang.

### D. Sudut Lengkung (Border Radius)

Menggunakan nilai kelengkungan layout yang konsisten untuk menghadirkan kesan lembut namun modern:
*   **`AppBorderRadius.xs` (`4.0`)**: Label diskon kecil, lencana kategori terkecil.
*   **`AppBorderRadius.sm` (`8.0`)**: Tag/Pills filter aktif, kolom kuantitas produk.
*   **`AppBorderRadius.md` (`12.0`)**: Kartu alamat, kartu checkout ringkasan belanja.
*   **`AppBorderRadius.lg` (`16.0`)**: *Golden Ratio* kelengkungan untuk Kartu Produk Utama, Field Input Form, dan Tombol CTA Utama.
*   **`AppBorderRadius.xxl` (`20.0`)**: Bottom Sheet kontainer popup (hanya melengkung di sudut atas).
*   **`AppBorderRadius.full` (`9999.0`)**: Tombol melayang berbentuk lingkaran, lencana jumlah keranjang belanja.

---

## 2. ARSITEKTUR LAYOUT & STRUKTUR HALAMAN MOBILE

Mengubah tata letak web responsif menjadi struktur mobile yang ramah jempol (*thumb-friendly*):

```
+------------------------------------------+
|  [Logo]          [Search Input]    [Cart]|  <-- Sticky Glassmorphic Header (AppBar)
+------------------------------------------+
|  [ Kategori: Kaos  |  Kemeja  |  Jaket ]  |  <-- Horizontal Pills (Scrollable)
+------------------------------------------+
|  +------------------------------------+  |
|  |           HERO BANNER              |  |
|  |      Koleksi Astabrata (Emas)      |  |  <-- Swiper Carousel
|  +------------------------------------+  |
+------------------------------------------+
|  PRODUK TERBARU               [Lihat Semua] |  <-- Section Header
|  +--------------+    +--------------+    |
|  |  [3:4 Image] |    |  [3:4 Image] |    |
|  |  Lembusura   |    |  Gatotkaca   |    |  <-- Staggered Masonry Grid (2 Kolom)
|  |  Rp 249.000  |    |  Rp 299.000  |    |
|  +--------------+    +--------------+    |
+------------------------------------------+
|     [Home]    [Catalog]    [Cart]   [Me] |  <-- Fixed Bottom Navigation Bar
+------------------------------------------+
```

### A. Struktur Halaman Utama (Home & Store)
1.  **Header (AppBar)**: 
    *   Tinggi tetap `64px`.
    *   Menggunakan efek semi-transparan `AppColors.glassSurface` dengan `BackdropFilter` blur `8.0`.
    *   Menampilkan logo brand di kiri, bilah pencarian mini di tengah, dan ikon keranjang belanja di kanan dengan lencana angka merah.
2.  **Navigation (BottomNavigationBar)**:
    *   Tinggi tetap `72px`.
    *   Tata letak 4 tab utama: `Beranda`, `Katalog`, `Keranjang`, dan `Akun`.
    *   Tab aktif diberi warna `AppColors.primary` (Navy) dengan indikator garis emas kecil di bawahnya. Tab tidak aktif berwarna `AppColors.outline` (Abu-abu lembut).
3.  **Feed Katalog Halaman Toko (Masonry Grid)**:
    *   Konfigurasi grid: **2 Kolom** menggunakan `SliverSimpleGridDelegateWithFixedCrossAxisCount` untuk mengatasi variasi rasio gambar produk.
    *   Rasio gambar produk dikunci pada **3:4** untuk mempertahankan fokus estetika mode premium.
    *   Batas luar grid berjarak `16.0` piksel dari tepi layar ponsel.

---

## 3. KOMPONEN DETAIL & PETA STRUKTUR DATA

Bagian ini merinci pemetaan komponen utama web ke Flutter Mobile lengkap dengan variabel data API yang digunakan.

### A. Komponen Kartu Produk (`ProductCard`)

Memetakan struktur dari `components/shop/product-card.tsx` ke widget Flutter kustom:

*   **Rasio Gambar**: 3:4. Dilengkapi dengan transisi visual `FadeInImage` dan `Shimmer` placeholder saat memuat data.
*   **Sistem Lencana (Badge System)**:
    *   *Diskon*: Latar belakang merah lembut, teks putih berukuran 10pt (`AppBorderRadius.sm`).
    *   *Premium / Best Seller*: Latar belakang `AppColors.secondary` (Emas), teks putih, bertuliskan "Koleksi Eksklusif".
*   **Tombol Tambah Cepat ke Keranjang (Quick Add-to-Cart)**:
    *   Tombol melayang berupa ikon tas belanja/keranjang di sudut kanan bawah gambar produk.
    *   Saat ditekan, menampilkan lembar interaksi bawah (*Bottom Sheet*) untuk memilih ukuran dan variasi warna.
*   **Pemetaan Data API**:
    ```dart
    class ProductModel {
      final String id;
      final String title;
      final String handle;
      final String description;
      final double price;
      final double? compareAtPrice;
      final String featuredImageUrl;
      final List<String> imageUrls;
      final double rating;
      final int reviewCount;
      final int soldCount;
      final Map<String, List<String>> options; // e.g. {"Size": ["S", "M", "L"], "Color": ["Black"]}
      final List<ProductVariantModel> variants;
    }
    ```

### B. Komponen Bilah Pencarian & Filter (`SearchBar` & `ProductFilters`)

Memetakan struktur dari `components/shop/search-bar.tsx` dan `components/shop/product-filters.tsx`:

*   **Pencarian**:
    *   Input pencarian dilengkapi dengan tombol hapus cepat (ikon silang) dan deteksi ketik dinamis (*debounce* selama 500ms) sebelum memicu permintaan API.
*   **Penyaringan (Filter Panel)**:
    *   Di mobile, filter dipindahkan dari panel samping (*sidebar*) ke dalam **Bottom Sheet** interaktif yang muncul ketika tombol "Filter & Urutkan" ditekan.
    *   *Filter Kategori*: Menggunakan deretan horizontal chip pilihan (`ChoiceChip`).
    *   *Filter Harga*: Slider jangkauan dua arah (*RangeSlider*) dinamis dari `Rp 0` hingga `Rp 1.000.000+` lengkap dengan input angka manual di bawahnya untuk kemudahan jempol pengguna.

### C. Komponen Kalkulator Ukuran Premium (`SizeCalculator`)

Komponen unggulan untuk menekan angka pengembalian produk akibat salah ukuran, diadaptasi dari `components/shop/size-calculator.tsx`:

*   **Alur Interaksi Mobile**:
    1. Pengguna menekan tombol "Panduan Ukuran" pada halaman detail produk.
    2. Muncul dialog modal yang meminta input tinggi badan (cm) dan berat badan (kg) melalui slider horizontal yang responsif.
    3. Algoritma menghitung ukuran rekomendasi instan (S, M, L, XL, XXL) berdasarkan tabel ukuran produk.
    4. Menampilkan visualisasi persentase kecocokan (misal: "Ukuran L cocok 95% untuk Anda, Longgar di Dada, Pas di Bahu").

---

## 4. DESIGN SYSTEM BRIDGE: DARI TAILWIND CSS KE FLUTTER

Tabel di bawah ini memetakan kelas-kelas styling Tailwind CSS v4 yang ada di proyek Next.js Commerce ke dalam kode styling Flutter yang setara:

| Tailwind CSS v4 Class | Properti CSS Utama | Flutter Equivalent Code | Catatan / Tips Mobile |
| :--- | :--- | :--- | :--- |
| `bg-background` | `background-color: #f8fafc` | `color: AppColors.background` | Gunakan pada scaffold utama. |
| `text-foreground` | `color: #0f172a` | `color: AppColors.onBackground` | Warna dasar teks artikel/paragraf. |
| `bg-mitologi-navy` | `background-color: oklch(0.25 0.05 260)` | `color: AppColors.primary` | Warna dominan elemen penunjuk aksi utama. |
| `text-mitologi-gold` | `color: oklch(0.75 0.16 75)` | `color: AppColors.secondary` | Gunakan untuk harga diskon, info rating. |
| `rounded-lg` | `border-radius: 8px` | `BorderRadius.circular(8.0)` | Digunakan untuk chip atau tag menu kecil. |
| `rounded-2xl` | `border-radius: 24px` | `BorderRadius.circular(24.0)` | Digunakan untuk kontainer panel bottom sheet. |
| `shadow-premium` | `box-shadow: 0 4px 24px ...` | `box-shadow: AppShadows.card` | Terapkan pada dekorasi kontainer kartu produk. |
| `animate-fade-in-up`| `animation: fade-in-up 0.6s` | `AnimatedOpacity` + `SlideTransition` | Gunakan `Tween<Offset>` dari `Offset(0, 0.1)` ke `zero`. |
| `hover:scale-105` | `transform: scale(1.05)` | `GestureDetector` + `AnimatedScale` | Skalakan kartu produk menjadi `1.02` saat ditekan. |

---

## 5. REKOMENDASI INTERAKSI MIKRO & TRANSISI (PREMIUM UX)

Untuk menghadirkan pengalaman berbelanja butik premium yang hidup dan menyenangkan, terapkan mikro-animasi berikut menggunakan pustaka bawaan Flutter atau paket animasi pendukung:

### A. Animasi Kartu Produk (`fashion-card` & `shine-effect`)
*   **Deskripsi**: Saat kartu produk disentuh (*tap down*), buat kartu sedikit mengecil (skala `1.0` ke `0.98`) untuk memberi umpan balik fisik yang memuaskan.
*   **Efek Berkilau (Shine Effect)**: Pada koleksi eksklusif, tambahkan efek gradasi cahaya berkilau yang menyapu secara horizontal melintasi kartu setiap 5 detik menggunakan shader gradasi linier beranimasi (`LinearGradient` yang bergeser koordinat `Alignment`-nya).

### B. Transisi Halaman Detail Produk (Hero Animations)
*   **Deskripsi**: Saat pengguna mengetuk produk dari katalog, gambar produk di katalog harus bergeser mulus dan membesar menjadi gambar utama di halaman detail produk.
*   **Implementasi Flutter**: Bungkus gambar produk di katalog dan di halaman detail menggunakan widget `Hero` dengan `tag: 'product_image_${product.id}'` yang sama.

### C. Efek Mengambang Premium (`animate-float` / `FloatingWhatsApp`)
*   **Deskripsi**: Tombol bantuan WhatsApp dan Asisten AI Chatbot mengapung naik turun secara perlahan (jarak 4px, durasi 3 detik) untuk menarik perhatian tanpa mengganggu fokus membaca pengguna.
*   **Implementasi Flutter**: Gunakan `AnimatedBuilder` dikombinasikan dengan fungsi `sin(animationValue)` untuk memodifikasi offset vertikal widget secara berkala.

### D. Skeleton Loader Premium
*   **Deskripsi**: Latar belakang skeleton tidak menggunakan abu-abu solid polos. Gunakan gradasi linear yang bergerak dari kiri ke kanan secara terus-menerus (`AppGradients.shimmer`) untuk memberikan indikasi visual bahwa data sedang dimuat dengan elegan.
*   **Implementasi Flutter**: Gunakan widget kustom berbasis `ShaderMask` atau paket `shimmer` dengan warna dasar `AppColors.surfaceContainerLow` dan warna sorotan `AppColors.surfaceContainerHigh`.

---

## 6. PENUTUP & REKOMENDASI PENGEMBANGAN

Dengan menerapkan panduan sistem desain yang selaras ini, aplikasi **Mitologi Clothing Mobile** akan memiliki kesatuan estetika yang sempurna dengan platform web **Next.js Commerce**-nya. 

Langkah taktis berikutnya untuk tim pengembang mobile:
1. Pastikan semua file di `lib/core/theme/` telah diperbarui dengan token terbaru di atas.
2. Gunakan `MultiProvider` di `main.dart` untuk mengelola data katalog, keranjang belanja, kalkulator ukuran, dan preferensi tema.
3. Selalu uji tampilan antarmuka pada layar beresolusi rendah (seperti layar berlebar 320dp/360dp) untuk memastikan tidak terjadi kebocoran piksel (*overflow*) pada teks harga atau tata letak grid.
