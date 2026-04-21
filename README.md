# Mitologi Clothing - Mobile App

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.5.0+-blue?style=for-the-badge&logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.0+-blue?style=for-the-badge&logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Platforms-Android%20|%20iOS-green?style=for-the-badge" alt="Platforms">
</p>

A premium, high-performance mobile e-commerce application for **Mitologi Clothing**, built with Flutter to provide a seamless shopping experience on both Android and iOS.

## ✨ Features

- **Premium UI:** Smooth animations with Lottie, custom typography via Google Fonts, and a sleek dark/light mode.
- **Product Exploration:** Categorized browsing, advanced search, and high-quality image caching.
- **AI Recommendations:** Personalized product suggestions integrated directly into the home and product detail screens.
- **Secure Checkout:** Full integration with the Midtrans payment gateway via WebView.
- **Authentication:** Secure user login and profile management with token persistence.
- **Wishlist & Cart:** Local and remote synchronization of user favorites and shopping items.

## 🛠 Tech Stack

- **Framework:** [Flutter](https://flutter.dev)
- **State Management:** Provider
- **Navigation:** GoRouter
- **API Client:** Dio & HTTP
- **Local Storage:** Flutter Secure Storage & Shared Preferences
- **UI Utils:** Lottie, Cached Network Image, Shimmer, Carousel Slider

## 📦 Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/muris11/Mobile_Mitologi_Clothing.git
   cd Mobile_Mitologi_Clothing
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Environment:**
   Ensure you have the backend URL configured in your service layer (usually `lib/core/constants/api_constants.dart` or via `--dart-define`).

4. **Run the App:**
   ```bash
   flutter run
   ```

## 📱 Project Structure

- `lib/core`: Core utilities, constants, and theme configurations.
- `lib/features`: Feature-based modules (Auth, Shop, Cart, Profile).
- `lib/services`: API services and external integrations.
- `assets`: Custom images, icons, and Lottie animations.

## 🧪 Testing

Run unit and widget tests:
```bash
flutter test
```

For integration tests:
```bash
flutter drive --target=test_driver/app.dart
```

## 📄 License

The Mitologi Clothing Mobile App is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
