import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:mitologi_clothing_mobile/core/api/api_client.dart';
import 'package:mitologi_clothing_mobile/core/router/app_router.dart';
import 'package:mitologi_clothing_mobile/core/storage/cart_storage.dart';
import 'package:mitologi_clothing_mobile/core/storage/token_storage.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_theme.dart';
import 'package:mitologi_clothing_mobile/features/ai/data/ai_repository.dart';
import 'package:mitologi_clothing_mobile/features/ai/data/ai_service.dart';
import 'package:mitologi_clothing_mobile/features/ai/presentation/chatbot_provider.dart';
import 'package:mitologi_clothing_mobile/features/auth/data/auth_repository.dart';
import 'package:mitologi_clothing_mobile/features/auth/data/auth_service.dart';
import 'package:mitologi_clothing_mobile/features/auth/presentation/auth_view_model.dart';
import 'package:mitologi_clothing_mobile/features/cart/data/cart_repository.dart';
import 'package:mitologi_clothing_mobile/features/cart/data/cart_service.dart';
import 'package:mitologi_clothing_mobile/features/cart/presentation/cart_view_model.dart';
import 'package:mitologi_clothing_mobile/features/catalog/data/catalog_repository.dart';
import 'package:mitologi_clothing_mobile/features/catalog/data/catalog_service.dart';
import 'package:mitologi_clothing_mobile/features/catalog/presentation/catalog_view_model.dart';
import 'package:mitologi_clothing_mobile/features/checkout/data/checkout_repository.dart';
import 'package:mitologi_clothing_mobile/features/checkout/data/checkout_service.dart';
import 'package:mitologi_clothing_mobile/features/checkout/presentation/checkout_view_model.dart';
import 'package:mitologi_clothing_mobile/features/content/data/content_repository.dart';
import 'package:mitologi_clothing_mobile/features/content/data/content_service.dart';
import 'package:mitologi_clothing_mobile/features/content/presentation/content_provider.dart';
import 'package:mitologi_clothing_mobile/features/home/data/home_repository.dart';
import 'package:mitologi_clothing_mobile/features/home/data/home_service.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/home_view_model.dart';
import 'package:mitologi_clothing_mobile/features/profile/data/profile_repository.dart';
import 'package:mitologi_clothing_mobile/features/profile/data/profile_service.dart';
import 'package:mitologi_clothing_mobile/features/profile/presentation/profile_view_model.dart';
import 'package:mitologi_clothing_mobile/features/splash/presentation/splash_screen.dart';
import 'package:mitologi_clothing_mobile/features/wishlist/data/wishlist_repository.dart';
import 'package:mitologi_clothing_mobile/features/wishlist/data/wishlist_service.dart';
import 'package:mitologi_clothing_mobile/features/wishlist/presentation/wishlist_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exception}\n${details.stack}');
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error: ${details.exception}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  };

  final tokenStorage = TokenStorage();
  final cartStorage = CartStorage();
  final apiClient = ApiClient(tokenStorage, cartStorage);

  final authRepository = AuthRepository(AuthService(apiClient), tokenStorage);
  final homeRepository = HomeRepository(HomeService(apiClient));
  final catalogRepository = CatalogRepository(CatalogService(apiClient));
  final cartRepository = CartRepository(CartService(apiClient), cartStorage);
  final checkoutRepository = CheckoutRepository(CheckoutService(apiClient));
  final profileRepository = ProfileRepository(ProfileService(apiClient));
  final wishlistRepository = WishlistRepository(WishlistService(apiClient));
  final aiRepository = AiRepository(AiService(apiClient));
  final contentRepository = ContentRepository(ContentService(apiClient));

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: authRepository),
        Provider<HomeRepository>.value(value: homeRepository),
        Provider<CatalogRepository>.value(value: catalogRepository),
        Provider<CartRepository>.value(value: cartRepository),
        Provider<CheckoutRepository>.value(value: checkoutRepository),
        Provider<ProfileRepository>.value(value: profileRepository),
        Provider<WishlistRepository>.value(value: wishlistRepository),
        Provider<AiRepository>.value(value: aiRepository),
        Provider<ContentRepository>.value(value: contentRepository),
        ChangeNotifierProvider(
            create: (_) => WishlistProvider(wishlistRepository)),
        ChangeNotifierProvider(create: (_) => ChatbotProvider(aiRepository)),
        ChangeNotifierProvider(
            create: (_) => ContentProvider(contentRepository)),
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authRepository),
        ),
        ChangeNotifierProvider(
            create: (_) => ProfileViewModel(profileRepository)),
        ChangeNotifierProvider(create: (_) => HomeViewModel(homeRepository)),
        ChangeNotifierProvider(
            create: (_) => CatalogViewModel(catalogRepository)),
        ChangeNotifierProvider(create: (_) => CartViewModel(cartRepository)),
        ChangeNotifierProvider(
            create: (_) => CheckoutViewModel(checkoutRepository)),
      ],
      child: const MitologiApp(),
    ),
  );
}

class MitologiApp extends StatefulWidget {
  const MitologiApp({super.key});

  @override
  State<MitologiApp> createState() => _MitologiAppState();
}

class _MitologiAppState extends State<MitologiApp> {
  bool _initialized = false;

  Future<void> _initialize() async {
    try {
      final authVM = context.read<AuthViewModel>();
      final cartVM = context.read<CartViewModel>();

      await authVM.checkAuthStatus().timeout(
        const Duration(seconds: 5),
        onTimeout: () => debugPrint('Auth initialization timed out'),
      );

      if (authVM.isAuthenticated) {
        unawaited(cartVM.fetchCart().timeout(
          const Duration(seconds: 3),
          onTimeout: () => debugPrint('Cart fetch timed out'),
        ));
      }
    } catch (e) {
      debugPrint('Initialization error: $e');
    } finally {
      if (mounted) {
        FlutterNativeSplash.remove();
        setState(() => _initialized = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp.router(
      title: 'Mitologi Clothing',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );

    if (_initialized) return app;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: SplashScreen(onInitComplete: _initialize),
    );
  }
}
