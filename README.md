# Mitologi Clothing Mobile

A premium e-commerce Flutter application for Mitologi Clothing, featuring AI-powered recommendations and a luxury shopping experience.

## Features

- 🛍️ **Product Catalog**: Browse products by category, collection, or search
- 🛒 **Shopping Cart**: Add items, update quantities, and checkout
- 🔐 **User Authentication**: Login, register, and profile management
- 📦 **Order Management**: View order history and track shipments
- ❤️ **Wishlist**: Save favorite items for later
- 🤖 **AI Recommendations**: Personalized product suggestions
- 💳 **Payment Integration**: Midtrans payment gateway
- 🎨 **Premium Design**: Elegant UI based on Material Design 3

## Tech Stack

- **Framework**: Flutter 3.5+
- **State Management**: Provider
- **Navigation**: GoRouter
- **HTTP Client**: http / dio
- **Styling**: Custom theme with Google Fonts
- **Security**: flutter_secure_storage for sensitive data

## Project Structure

```
lib/
├── config/
│   ├── api_config.dart      # API endpoints and configuration
│   └── theme.dart           # App theme, colors, typography
├── models/
│   ├── user.dart            # User model
│   ├── product.dart         # Product model
│   ├── cart.dart            # Cart model
│   ├── order.dart           # Order model
│   ├── address.dart         # Address model
│   └── ...
├── services/
│   ├── api_service.dart     # Base HTTP client
│   ├── auth_service.dart    # Auth operations
│   ├── product_service.dart # Product operations
│   ├── cart_service.dart    # Cart operations
│   ├── order_service.dart   # Order operations
│   └── ...
├── providers/
│   ├── auth_provider.dart   # Auth state
│   ├── cart_provider.dart   # Cart state
│   └── product_provider.dart # Product state
├── screens/
│   ├── auth/                # Login, Register
│   ├── home/                # Home screen
│   ├── product/             # Product list, detail
│   ├── cart/                # Cart
│   ├── checkout/            # Checkout
│   ├── order/               # Orders
│   ├── profile/             # Profile, addresses
│   └── ...
├── widgets/
│   ├── common/              # Reusable widgets
│   ├── product/             # Product-related widgets
│   └── cart/                # Cart-related widgets
└── main.dart                # Entry point
```

## Getting Started

### Prerequisites

- Flutter 3.5.0 or higher
- Dart SDK 3.5.0 or higher
- Android Studio / Xcode for emulators

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/mitologi_clothing_mobile.git
cd mitologi_clothing_mobile
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure API base URL:

The app uses `dart-define` for configuration. You need to provide the backend URL when running:

```bash
# For Android emulator (localhost via 10.0.2.2)
flutter run --dart-define=MITOLOGI_API_BASE_URL=http://10.0.2.2:8000

# For iOS simulator
flutter run --dart-define=MITOLOGI_API_BASE_URL=http://127.0.0.1:8000

# For physical device (use your computer's local IP)
flutter run --dart-define=MITOLOGI_API_BASE_URL=http://192.168.1.100:8000

# For production
flutter run --dart-define=MITOLOGI_API_BASE_URL=https://api.yourdomain.com
```

### Backend Configuration

This app connects to the Mitologi Clothing Laravel backend. Make sure the backend is running at the configured URL.

Default backend ports:
- Laravel Backend: `http://localhost:8000`
- API Base Path: `/api/v1`

## Running the App

### Development

```bash
# Run with hot reload
flutter run --dart-define=MITOLOGI_API_BASE_URL=http://10.0.2.2:8000

# Run in debug mode
flutter run --debug --dart-define=MITOLOGI_API_BASE_URL=http://10.0.2.2:8000

# Run in profile mode
flutter run --profile --dart-define=MITOLOGI_API_BASE_URL=http://10.0.2.2:8000
```

### Building

```bash
# Build APK for Android
flutter build apk --dart-define=MITOLOGI_API_BASE_URL=https://api.yourdomain.com

# Build App Bundle for Play Store
flutter build appbundle --dart-define=MITOLOGI_API_BASE_URL=https://api.yourdomain.com

# Build iOS
flutter build ios --dart-define=MITOLOGI_API_BASE_URL=https://api.yourdomain.com
```

## API Integration

The app integrates with the Mitologi Clothing REST API. Key endpoints:

### Public Endpoints
- `GET /api/v1/landing-page` - Home page data
- `GET /api/v1/products` - Product list
- `GET /api/v1/products/{handle}` - Product detail
- `GET /api/v1/categories` - Categories

### Protected Endpoints (Auth Required)
- `GET /api/v1/cart` - Get cart
- `POST /api/v1/cart/items` - Add to cart
- `POST /api/v1/checkout` - Process checkout
- `GET /api/v1/orders` - Order history
- `GET /api/v1/wishlist` - Wishlist

See `lib/config/api_config.dart` for all endpoints.

## Design System

The app follows the Mitologi Clothing design system from the `stitch` folder:

### Colors
- Primary: `#000613` (Dark Navy)
- Secondary: `#735C00` (Gold)
- Surface: `#FAF9F5` (Cream)
- Background: `#FAF9F5`

### Typography
- Headlines: Noto Serif
- Body: Manrope

### Shapes
- Cards: 24px border radius
- Buttons: 16px border radius
- Inputs: 16px border radius

## Testing

```bash
# Run unit tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Format code
flutter format lib/
```

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `MITOLOGI_API_BASE_URL` | Backend API base URL | Yes |
| `MITOLOGI_STORAGE_BASE_URL` | Storage URL for images | Optional |
| `MITOLOGI_MIDTRANS_CLIENT_KEY` | Midtrans payment key | For payments |

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.

## Support

For support, email support@mitologiclothing.com or join our Discord channel.

---

Made with ❤️ by Mitologi Clothing Team
