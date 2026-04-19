import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'config/theme.dart';
import 'features/chatbot/data/chatbot_service_adapter.dart';
import 'features/chatbot/presentation/chatbot_provider.dart';
import 'features/content/data/content_service_adapter.dart';
import 'features/content/presentation/content_provider.dart';
import 'features/wishlist/data/wishlist_service_adapter.dart';
import 'features/wishlist/presentation/wishlist_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/checkout_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'providers/profile_provider.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/cart_service.dart';
import 'services/chatbot_service.dart';
import 'services/order_service.dart';
import 'services/product_service.dart';
import 'services/profile_service.dart';
import 'services/review_service.dart';
import 'services/wishlist_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MitologiApp());
}

class MitologiApp extends StatefulWidget {
  const MitologiApp({super.key});

  @override
  State<MitologiApp> createState() => _MitologiAppState();
}

class _MitologiAppState extends State<MitologiApp> {
  late final ApiService apiService;
  late final AuthService authService;
  late final CartService cartService;
  late final AuthProvider authProvider;
  late final OrderService orderService;

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    authService = AuthService(apiService);
    cartService = CartService(apiService);
    orderService = OrderService(apiService);
    authProvider = AuthProvider(authService, cartService);
    // Set callback to clear token caches on logout
    authProvider.setOnLogoutCallback(() {
      orderService.clearTokenCache();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productService = ProductService(apiService);
    final cartService = CartService(apiService);
    // orderService already created in initState
    final wishlistService = WishlistService(apiService);
    final profileService = ProfileService(apiService);
    final chatbotService = ChatbotService(apiService);
    final reviewService = ReviewService(apiService);

    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        Provider<AuthService>.value(value: authService),
        Provider<ProductService>.value(value: productService),
        Provider<CartService>.value(value: cartService),
        Provider<OrderService>.value(value: orderService),
        Provider<WishlistService>.value(value: wishlistService),
        Provider<ProfileService>.value(value: profileService),
        Provider<ChatbotService>.value(value: chatbotService),
        Provider<ReviewService>.value(value: reviewService),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => CartProvider(cartService)),
        ChangeNotifierProvider(create: (_) => ProductProvider(productService)),
        ChangeNotifierProvider(create: (_) => ProfileProvider(profileService)),
        ChangeNotifierProvider(
          create: (_) => ChatbotProvider(ChatbotServiceAdapter(chatbotService)),
        ),
        ChangeNotifierProvider(
          create: (_) => ContentProvider(ProductContentServiceAdapter(productService)),
        ),
        ChangeNotifierProvider(
          create: (_) => WishlistProvider(WishlistServiceAdapter(wishlistService)),
        ),
        ChangeNotifierProxyProvider<CartProvider, CheckoutProvider>(
          create: (context) => CheckoutProvider(
            context.read<CartProvider>(),
            profileService,
            orderService,
          ),
          update: (context, cartProvider, previous) =>
              previous ??
              CheckoutProvider(cartProvider, profileService, orderService),
        ),
        ChangeNotifierProvider(create: (_) => OrderProvider(orderService)),
      ],
      child: MaterialApp.router(
        title: 'Mitologi Clothing',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
