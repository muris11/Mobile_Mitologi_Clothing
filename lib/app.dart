import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/product/product_list_screen.dart';
import 'screens/product/product_detail_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/checkout/checkout_screen.dart';
import 'screens/order/order_list_screen.dart';
import 'screens/order/order_detail_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/wishlist/wishlist_screen.dart';
import 'screens/profile/address_list_screen.dart';
import 'screens/cms/content_screen.dart';
import 'screens/chatbot/chatbot_screen.dart';
import 'screens/portfolio/portfolio_detail_screen.dart';

class AppPageTransitions {
  static const Duration _transitionDuration = Duration(milliseconds: 300);

  static CustomTransitionPage<T> fadeSlide<T>({
    required Widget child,
    required GoRouterState state,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: _transitionDuration,
      reverseTransitionDuration: _transitionDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuint,
          reverseCurve: Curves.easeInQuad,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  static CustomTransitionPage<T> slideUp<T>({
    required Widget child,
    required GoRouterState state,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: _transitionDuration,
      reverseTransitionDuration: _transitionDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuart,
          reverseCurve: Curves.easeInQuad,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
    );
  }

  static CustomTransitionPage<T> scaleFade<T>({
    required Widget child,
    required GoRouterState state,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: _transitionDuration,
      reverseTransitionDuration: _transitionDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuint,
          reverseCurve: Curves.easeInQuad,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale:
                Tween<double>(begin: 0.95, end: 1.0).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }
}

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
          path: '/splash',
          pageBuilder: (context, state) => AppPageTransitions.fadeSlide(
                child: const SplashScreen(),
                state: state,
              )),
      GoRoute(
          path: '/onboarding',
          pageBuilder: (context, state) => AppPageTransitions.fadeSlide(
                child: const OnboardingScreen(),
                state: state,
              )),
      GoRoute(
          path: '/login',
          pageBuilder: (context, state) => AppPageTransitions.slideUp(
                child: const LoginScreen(),
                state: state,
              )),
      GoRoute(
          path: '/register',
          pageBuilder: (context, state) => AppPageTransitions.slideUp(
                child: const RegisterScreen(),
                state: state,
              )),
      GoRoute(
          path: '/forgot-password',
          pageBuilder: (context, state) => AppPageTransitions.slideUp(
                child: const ForgotPasswordScreen(),
                state: state,
              )),
      GoRoute(
          path: '/reset-password',
          pageBuilder: (context, state) {
            final queryParams = state.uri.queryParameters;
            return AppPageTransitions.slideUp(
              child: ResetPasswordScreen(
                token: queryParams['token'],
                email: queryParams['email'],
              ),
              state: state,
            );
          }),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ScaffoldWithBottomNav(child: child),
        routes: [
          GoRoute(
              path: '/home',
              pageBuilder: (context, state) => AppPageTransitions.fadeSlide(
                    child: const HomeScreen(),
                    state: state,
                  )),
          GoRoute(
              path: '/shop',
              pageBuilder: (context, state) => AppPageTransitions.fadeSlide(
                    child: const ProductListScreen(),
                    state: state,
                  )),
          GoRoute(
              path: '/cart',
              pageBuilder: (context, state) => AppPageTransitions.fadeSlide(
                    child: const CartScreen(),
                    state: state,
                  )),
          GoRoute(
              path: '/wishlist',
              pageBuilder: (context, state) => AppPageTransitions.fadeSlide(
                    child: const WishlistScreen(),
                    state: state,
                  )),
          GoRoute(
              path: '/profile',
              pageBuilder: (context, state) => AppPageTransitions.fadeSlide(
                    child: const ProfileScreen(),
                    state: state,
                  )),
        ],
      ),
      GoRoute(
          path: '/products',
          pageBuilder: (context, state) {
            final queryParams = state.uri.queryParameters;
            return AppPageTransitions.fadeSlide(
              child: ProductListScreen(
                category: queryParams['category'],
                sort: queryParams['sort'],
                search: queryParams['search'],
              ),
              state: state,
            );
          }),
      GoRoute(
          path: '/product/:handle',
          pageBuilder: (context, state) => AppPageTransitions.scaleFade(
                child: ProductDetailScreen(
                    handle: state.pathParameters['handle']!),
                state: state,
              )),
      GoRoute(
          path: '/checkout',
          pageBuilder: (context, state) => AppPageTransitions.slideUp(
                child: const CheckoutScreen(),
                state: state,
              )),
      GoRoute(
          path: '/orders',
          pageBuilder: (context, state) => AppPageTransitions.fadeSlide(
                child: const OrderListScreen(),
                state: state,
              )),
      GoRoute(
          path: '/orders/:orderNumber',
          pageBuilder: (context, state) => AppPageTransitions.fadeSlide(
                child: OrderDetailScreen(
                    orderNumber: state.pathParameters['orderNumber']!),
                state: state,
              )),
      GoRoute(
          path: '/profile/addresses',
          pageBuilder: (context, state) => AppPageTransitions.slideUp(
                child: const AddressListScreen(),
                state: state,
              )),
      GoRoute(
          path: '/content/:handle',
          pageBuilder: (context, state) => AppPageTransitions.fadeSlide(
                child: ContentScreen(handle: state.pathParameters['handle']!),
                state: state,
              )),
      GoRoute(
          path: '/chatbot',
          pageBuilder: (context, state) => AppPageTransitions.slideUp(
                child: const ChatbotScreen(),
                state: state,
              )),
      GoRoute(
          path: '/portfolio/:slug',
          pageBuilder: (context, state) => AppPageTransitions.fadeSlide(
                child:
                    PortfolioDetailScreen(slug: state.pathParameters['slug']!),
                state: state,
              )),
    ],
    redirect: (context, state) {
      final location = state.uri.path;
      final publicRoutes = [
        '/splash',
        '/onboarding',
        '/login',
        '/register',
        '/forgot-password',
        '/reset-password',
        '/home',
        '/shop',
        '/products',
        '/product',
        '/content',
        '/chatbot',
        '/portfolio',
      ];
      if (publicRoutes.any((route) => location.startsWith(route))) {
        return null;
      }

      // Allow cart without auth (guest cart)
      if (location.startsWith('/cart')) {
        return null;
      }

      // Get auth state from Provider - safely handle if not available yet
      final authProvider =
          context.mounted ? context.read<AuthProvider>() : null;

      // Skip redirect if auth is still initializing - let user through on first load
      // The auth state will be properly checked after initialization completes
      if (authProvider == null || authProvider.isLoading) {
        return null;
      }

      // Check auth for protected routes
      if (!authProvider.isAuthenticated) {
        final protectedRoutes = ['/checkout', '/orders', '/addresses'];
        if (protectedRoutes.any((p) => location.startsWith(p))) {
          return '/login';
        }
      }
      return null;
    },
  );
}

class ScaffoldWithBottomNav extends StatefulWidget {
  final Widget child;
  const ScaffoldWithBottomNav({super.key, required this.child});
  @override
  State<ScaffoldWithBottomNav> createState() => _ScaffoldWithBottomNavState();
}

class _ScaffoldWithBottomNavState extends State<ScaffoldWithBottomNav> {
  int _getCurrentIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/shop')) return 1;
    if (location.startsWith('/cart')) return 2;
    if (location.startsWith('/wishlist')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _getCurrentIndex(location);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/shop');
              break;
            case 2:
              context.go('/cart');
              break;
            case 3:
              context.go('/wishlist');
              break;
            case 4:
              context.go('/profile');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Beranda'),
          NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search),
              label: 'Belanja'),
          NavigationDestination(
              icon: Icon(Icons.shopping_basket_outlined),
              selectedIcon: Icon(Icons.shopping_basket),
              label: 'Keranjang'),
          NavigationDestination(
              icon: Icon(Icons.favorite_outline),
              selectedIcon: Icon(Icons.favorite),
              label: 'Wishlist'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Akun'),
        ],
      ),
    );
  }
}
