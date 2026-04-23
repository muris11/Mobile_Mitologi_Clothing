import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'utils/haptic_feedback.dart';
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

class _ScaffoldWithBottomNavState extends State<ScaffoldWithBottomNav>
    with TickerProviderStateMixin {
  int _getCurrentIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/shop')) return 1;
    if (location.startsWith('/cart')) return 2;
    if (location.startsWith('/wishlist')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  late AnimationController _cartBadgeController;
  late Animation<double> _cartBadgeScale;
  int _previousCartCount = 0;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _cartBadgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _cartBadgeScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 0.9), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.1), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 25),
    ]).animate(
      CurvedAnimation(parent: _cartBadgeController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _cartBadgeController.dispose();
    super.dispose();
  }

  void _triggerCartAnimation() {
    _cartBadgeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _getCurrentIndex(location);

    // Track direction for slide animation
    final direction = currentIndex > _previousIndex ? 1 : -1;
    _previousIndex = currentIndex;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        reverseDuration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final isEntering = child.key == ValueKey(location);
          final slideAnimation = Tween<Offset>(
            begin: Offset(isEntering ? direction * 0.15 : -direction * 0.15, 0),
            end: Offset.zero,
          ).animate(animation);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey(location),
          child: widget.child,
        ),
      ),
      bottomNavigationBar: _buildFloatingNavBar(currentIndex),
    );
  }

  Widget _buildFloatingNavBar(int currentIndex) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.surface.withValues(alpha: 0.95),
                AppColors.surfaceContainerLow.withValues(alpha: 0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.12),
                blurRadius: 30,
                offset: const Offset(0, 12),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                index: 0,
                currentIndex: currentIndex,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Beranda',
                onTap: () => context.go('/home'),
              ),
              _buildNavItem(
                index: 1,
                currentIndex: currentIndex,
                icon: Icons.search_outlined,
                activeIcon: Icons.search_rounded,
                label: 'Belanja',
                onTap: () => context.go('/shop'),
              ),
              _buildNavItem(
                index: 2,
                currentIndex: currentIndex,
                icon: Icons.shopping_basket_outlined,
                activeIcon: Icons.shopping_basket_rounded,
                label: 'Keranjang',
                onTap: () => context.go('/cart'),
                showBadge: true,
              ),
              _buildNavItem(
                index: 3,
                currentIndex: currentIndex,
                icon: Icons.favorite_outline,
                activeIcon: Icons.favorite_rounded,
                label: 'Wishlist',
                onTap: () => context.go('/wishlist'),
              ),
              _buildNavItem(
                index: 4,
                currentIndex: currentIndex,
                icon: Icons.person_outline,
                activeIcon: Icons.person_rounded,
                label: 'Akun',
                onTap: () => context.go('/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required int currentIndex,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required VoidCallback onTap,
    bool showBadge = false,
  }) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          AppHaptics.selection();
          onTap();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.primaryContainer.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showBadge)
              Consumer<CartProvider>(
                builder: (context, cart, _) {
                  final count = cart.itemCount;
                  if (count > 0 && count != _previousCartCount) {
                    _previousCartCount = count;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _triggerCartAnimation();
                    });
                  }
                  return AnimatedBuilder(
                    animation: _cartBadgeController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: count > 0 ? _cartBadgeScale.value : 1.0,
                        child: Badge(
                          isLabelVisible: count > 0,
                          label: Text('$count'),
                          backgroundColor: const Color(0xFFE53935),
                          textColor: Colors.white,
                          smallSize: 8,
                          child: Icon(
                            isSelected ? activeIcon : icon,
                            size: 24,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                  );
                },
              )
            else
              AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                child: Icon(
                  isSelected ? activeIcon : icon,
                  size: 24,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
