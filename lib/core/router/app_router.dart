import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/features/ai/presentation/chatbot_screen.dart';
import 'package:mitologi_clothing_mobile/features/auth/data/auth_repository.dart';
import 'package:mitologi_clothing_mobile/features/auth/presentation/views/forgot_password_view.dart';
import 'package:mitologi_clothing_mobile/features/auth/presentation/views/login_view.dart';
import 'package:mitologi_clothing_mobile/features/auth/presentation/views/register_view.dart';
import 'package:mitologi_clothing_mobile/features/auth/presentation/views/reset_password_view.dart';
import 'package:mitologi_clothing_mobile/features/cart/presentation/views/cart_view.dart';
import 'package:mitologi_clothing_mobile/features/catalog/presentation/views/catalog_view.dart';
import 'package:mitologi_clothing_mobile/features/catalog/presentation/views/product_detail_view.dart';
import 'package:mitologi_clothing_mobile/features/checkout/presentation/views/addresses_screen.dart';
import 'package:mitologi_clothing_mobile/features/checkout/presentation/views/checkout_success_screen.dart';
import 'package:mitologi_clothing_mobile/features/checkout/presentation/views/checkout_view.dart';
import 'package:mitologi_clothing_mobile/features/checkout/presentation/views/midtrans_payment_screen.dart';
import 'package:mitologi_clothing_mobile/features/content/presentation/about_screen.dart';
import 'package:mitologi_clothing_mobile/features/content/presentation/cms_page_screen.dart';
import 'package:mitologi_clothing_mobile/features/content/presentation/collection_screen.dart';
import 'package:mitologi_clothing_mobile/features/content/presentation/faq_screen.dart';
import 'package:mitologi_clothing_mobile/features/content/presentation/kategori_screen.dart';
import 'package:mitologi_clothing_mobile/features/content/presentation/kontak_screen.dart';
import 'package:mitologi_clothing_mobile/features/content/presentation/layanan_screen.dart';
import 'package:mitologi_clothing_mobile/features/content/presentation/panduan_ukuran_screen.dart';
import 'package:mitologi_clothing_mobile/features/content/presentation/portfolio_detail_screen.dart';
import 'package:mitologi_clothing_mobile/features/content/presentation/portfolio_screen.dart';
import 'package:mitologi_clothing_mobile/features/content/presentation/promo_screen.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/main_shell.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/views/home_view.dart';
import 'package:mitologi_clothing_mobile/features/profile/presentation/views/order_detail_screen.dart';
import 'package:mitologi_clothing_mobile/features/profile/presentation/views/orders_list_screen.dart';
import 'package:mitologi_clothing_mobile/features/profile/presentation/views/profile_view.dart';
import 'package:mitologi_clothing_mobile/features/wishlist/presentation/wishlist_screen.dart';
import 'package:provider/provider.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final authRepo = context.read<AuthRepository>();
      final isLoggedIn = authRepo.isLoggedIn;

      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn &&
          !isLoggingIn &&
          state.matchedLocation.startsWith('/profile')) {}

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordView(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => ResetPasswordView(
          token: state.uri.queryParameters['token'] ?? '',
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeView(),
          ),
          GoRoute(
            path: '/products',
            builder: (context, state) => CatalogView(
              initialQuery: state.uri.queryParameters['q'] ??
                  state.uri.queryParameters['category'],
            ),
          ),
          GoRoute(
            path: '/wishlist',
            builder: (context, state) => const WishlistScreen(),
          ),
          GoRoute(
            path: '/portfolio-tab',
            builder: (context, state) => const PortfolioScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileView(),
          ),
        ],
      ),
      GoRoute(
        path: '/product/:slug',
        builder: (context, state) => ProductDetailView(
          slug: state.pathParameters['slug']!,
        ),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartView(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutView(),
      ),
      GoRoute(
        path: '/chatbot',
        builder: (context, state) => const ChatbotScreen(),
      ),
      GoRoute(
        path: '/pages/:handle',
        builder: (context, state) => CmsPageScreen(
          handle: state.pathParameters['handle']!,
        ),
      ),
      GoRoute(
        path: '/portfolio',
        builder: (context, state) => const PortfolioScreen(),
      ),
      GoRoute(
        path: '/portfolio/:slug',
        builder: (context, state) => PortfolioDetailScreen(
          slug: state.pathParameters['slug']!,
        ),
      ),
      GoRoute(
        path: '/tentang-kami',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/kontak',
        builder: (context, state) => const KontakScreen(),
      ),
      GoRoute(
        path: '/collections/:handle',
        builder: (context, state) => CollectionScreen(
          handle: state.pathParameters['handle']!,
        ),
      ),
      GoRoute(
        path: '/checkout/success',
        builder: (context, state) => CheckoutSuccessScreen(
          orderNumber: state.uri.queryParameters['order'],
        ),
      ),
      GoRoute(
        path: '/payment/midtrans',
        builder: (context, state) => MidtransPaymentScreen(
          paymentUrl: state.uri.queryParameters['url'] ?? '',
          orderNumber: state.uri.queryParameters['order'] ?? '',
        ),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersListScreen(),
      ),
      GoRoute(
        path: '/orders/:orderNumber',
        builder: (context, state) => OrderDetailScreen(
          orderNumber: state.pathParameters['orderNumber']!,
        ),
      ),
      GoRoute(
        path: '/profile/addresses',
        builder: (context, state) => const AddressesScreen(),
      ),
      GoRoute(
        path: '/kategori',
        builder: (context, state) => const KategoriScreen(),
      ),
      GoRoute(
        path: '/faq',
        builder: (context, state) => const FaqScreen(),
      ),
      GoRoute(
        path: '/layanan',
        builder: (context, state) => const LayananScreen(),
      ),
      GoRoute(
        path: '/panduan-ukuran',
        builder: (context, state) => const PanduanUkuranScreen(),
      ),
      GoRoute(
        path: '/promo',
        builder: (context, state) => const PromoScreen(),
      ),
      GoRoute(
        path: '/kebijakan-pengembalian',
        builder: (context, state) =>
            const CmsPageScreen(handle: 'kebijakan-pengembalian'),
      ),
      GoRoute(
        path: '/kebijakan-privasi',
        builder: (context, state) =>
            const CmsPageScreen(handle: 'kebijakan-privasi'),
      ),
      GoRoute(
        path: '/syarat-ketentuan',
        builder: (context, state) =>
            const CmsPageScreen(handle: 'syarat-ketentuan'),
      ),
      GoRoute(
        path: '/privacy-policy',
        builder: (context, state) =>
            const CmsPageScreen(handle: 'privacy-policy'),
      ),
      GoRoute(
        path: '/terms-of-service',
        builder: (context, state) =>
            const CmsPageScreen(handle: 'terms-of-service'),
      ),
      GoRoute(
        path: '/search',
        redirect: (context, state) {
          final q = state.uri.queryParameters['q'];
          return q != null && q.isNotEmpty ? '/products?q=$q' : '/products';
        },
      ),
    ],
  );
}
