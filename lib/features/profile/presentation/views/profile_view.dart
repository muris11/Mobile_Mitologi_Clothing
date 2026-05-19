import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/features/auth/presentation/auth_view_model.dart';
import 'package:mitologi_clothing_mobile/features/checkout/domain/models/order_model.dart';
import 'package:mitologi_clothing_mobile/features/profile/presentation/profile_view_model.dart';
import 'package:mitologi_clothing_mobile/widgets/common/cart_icon_button.dart';
import 'package:mitologi_clothing_mobile/widgets/common/loading_indicator.dart';
import 'package:mitologi_clothing_mobile/widgets/shared/mitologi_sliver_app_bar.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = context.read<AuthViewModel>();
      if (authViewModel.isAuthenticated) {
        context.read<ProfileViewModel>().fetchProfileData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthViewModel, ProfileViewModel>(
      builder: (context, authVM, profileVM, child) {
        if (!authVM.isAuthenticated) {
          return _buildGuestView();
        }

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
          ),
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: profileVM.isLoading
                ? const Center(child: LoadingIndicator())
                : RefreshIndicator(
                    onRefresh: () => profileVM.fetchProfileData(),
                    child: CustomScrollView(
                      slivers: [
                        MitologiSliverAppBar(
                          pageTitle: 'Akun Saya',
                          actions: [
                            const CartIconButton(),
                            IconButton(
                              icon: const Icon(
                                PhosphorIconsRegular.signOut,
                                color: AppColors.primary,
                              ),
                              onPressed: () => _handleLogout(context, authVM),
                              tooltip: 'Keluar',
                            ),
                            const Gap(8),
                          ],
                        ),
                        _buildHeader(profileVM.user ?? authVM.user),
                        _buildMenuSection(context),
                        if (profileVM.orders.isNotEmpty)
                          _buildRecentOrders(profileVM),
                        const SliverToBoxAdapter(child: Gap(32)),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }


  Widget _buildHeader(dynamic user) {
    final initial = user?.name.isNotEmpty == true
        ? user!.name.substring(0, 1).toUpperCase()
        : 'U';
    final avatarUrl = user?.avatarUrl;

    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () => context.push('/profile/edit'),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: avatarUrl == null
                      ? LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryContainer],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: avatarUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          avatarUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildAvatarFallback(initial),
                        ),
                      )
                    : Center(
                        child: Text(
                          initial,
                          style: GoogleFonts.notoSerif(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Pengguna',
                      style: GoogleFonts.notoSerif(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      user?.email ?? '',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(String initial) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.notoSerif(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final menuItems = [
      _MenuItem(
        icon: PhosphorIconsRegular.shoppingBag,
        label: 'Pesanan Saya',
        subtitle: 'Lacak dan lihat riwayat pesanan',
        onTap: () => context.push('/orders'),
      ),
      _MenuItem(
        icon: PhosphorIconsRegular.heart,
        label: 'Wishlist',
        subtitle: 'Produk yang kamu simpan',
        onTap: () => context.push('/wishlist'),
      ),
      _MenuItem(
        icon: PhosphorIconsRegular.mapPin,
        label: 'Alamat Pengiriman',
        subtitle: 'Kelola alamat pengiriman',
        onTap: () => context.push('/profile/addresses'),
      ),
      _MenuItem(
        icon: PhosphorIconsRegular.headset,
        label: 'Mitologi AI Assistant',
        subtitle: 'Rekomendasi outfit personal',
        onTap: () => context.push('/chatbot'),
      ),
      _MenuItem(
        icon: PhosphorIconsRegular.question,
        label: 'FAQ',
        subtitle: 'Pertanyaan yang sering diajukan',
        onTap: () => context.push('/faq'),
      ),
      _MenuItem(
        icon: PhosphorIconsRegular.ruler,
        label: 'Panduan Ukuran',
        subtitle: 'Cari ukuran yang tepat',
        onTap: () => context.push('/panduan-ukuran'),
      ),
      _MenuItem(
        icon: PhosphorIconsRegular.tag,
        label: 'Promo & Penawaran',
        subtitle: 'Diskon dan benefit eksklusif',
        onTap: () => context.push('/promo'),
      ),
      _MenuItem(
        icon: PhosphorIconsRegular.info,
        label: 'Tentang Kami',
        subtitle: 'Cerita di balik Mitologi',
        onTap: () => context.push('/tentang-kami'),
      ),
      _MenuItem(
        icon: PhosphorIconsRegular.fileText,
        label: 'Kebijakan & Syarat',
        subtitle: 'Privasi, pengembalian, ketentuan',
        onTap: () => _showLegalBottomSheet(context),
      ),
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'MENU',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.outlineVariant),
                boxShadow: [AppShadows.cardSoft],
              ),
              child: Column(
                children: List.generate(menuItems.length, (i) {
                  final item = menuItems[i];
                  final isLast = i == menuItems.length - 1;
                  return _buildMenuItem(item, isLast);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item, bool isLast) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.icon,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  if (item.subtitle != null)
                    Text(
                      item.subtitle!,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(
              PhosphorIconsRegular.caretRight,
              size: 18,
              color: AppColors.outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrders(ProfileViewModel profileVM) {
    final orders = profileVM.orders.take(3).toList();
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PESANAN TERBARU',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/orders'),
                    child: Text(
                      'Lihat Semua',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.outlineVariant),
                boxShadow: [AppShadows.cardSoft],
              ),
              child: Column(
                children: List.generate(orders.length, (i) {
                  final order = orders[i];
                  final isLast = i == orders.length - 1;
                  return _buildOrderCard(order, isLast);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, bool isLast) {
    final statusColors = <String, Color>{
      'pending': const Color(0xFFB45309),
      'paid': const Color(0xFF047857),
      'processing': const Color(0xFF1D4ED8),
      'shipped': const Color(0xFF7C3AED),
      'delivered': const Color(0xFF0F766E),
      'completed': const Color(0xFF15803D),
      'cancelled': const Color(0xFFDC2626),
      'refunded': const Color(0xFF475569),
    };
    final statusLabels = <String, String>{
      'pending': 'Menunggu Bayar',
      'paid': 'Lunas',
      'processing': 'Diproses',
      'shipped': 'Dikirim',
      'delivered': 'Terkirim',
      'completed': 'Selesai',
      'cancelled': 'Dibatalkan',
      'refunded': 'Dikembalikan',
    };
    final color = statusColors[order.status] ?? AppColors.onSurfaceVariant;
    final label = statusLabels[order.status] ?? order.status;

    return InkWell(
      onTap: () => context.push('/orders/${order.orderNumber}'),
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${order.orderNumber}',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.itemsCount > 0 ? order.itemsCount : order.items.length} item',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  _formatCurrency(order.totalAmount),
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            if (!isLast) const Divider(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.")}';
  }

  void _showLegalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      elevation: 0,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const Gap(20),
                  Text(
                    'Kebijakan & Syarat',
                    style: GoogleFonts.notoSerif(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const Gap(6),
                  Text(
                    'Pilih dokumen hukum yang ingin Anda tinjau',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(20),
                  _buildLegalOption(
                    context,
                    icon: PhosphorIconsRegular.shieldCheck,
                    title: 'Kebijakan Privasi',
                    desc: 'Bagaimana kami mengelola & melindungi data Anda',
                    route: '/kebijakan-privasi',
                  ),
                  const Gap(10),
                  _buildLegalOption(
                    context,
                    icon: PhosphorIconsRegular.fileText,
                    title: 'Syarat & Ketentuan',
                    desc: 'Ketentuan penggunaan layanan Mitologi',
                    route: '/syarat-ketentuan',
                  ),
                  const Gap(10),
                  _buildLegalOption(
                    context,
                    icon: PhosphorIconsRegular.arrowsClockwise,
                    title: 'Kebijakan Pengembalian',
                    desc: 'Ketentuan pengembalian produk & refund',
                    route: '/kebijakan-pengembalian',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegalOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String desc,
    required String route,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        context.push(route);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    desc,
                    style: GoogleFonts.manrope(
                      fontSize: 11.5,
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              PhosphorIconsRegular.caretRight,
              size: 16,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context, AuthViewModel authVM) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Keluar dari Akun?',
          style: GoogleFonts.notoSerif(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun ini?',
          style: GoogleFonts.manrope(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: Text(
              'Batal',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
            ),
          ),
          FilledButton(
            onPressed: () {
              authVM.logout();
              ctx.pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Keluar',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildGuestView() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Akun Saya',
          style: GoogleFonts.notoSerif(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        centerTitle: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(PhosphorIconsRegular.userCircle,
                  size: 80, color: AppColors.outlineVariant),
              const Gap(16),
              Text(
                'Belum Masuk',
                style: GoogleFonts.notoSerif(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const Gap(8),
              Text(
                'Masuk untuk melihat akun dan pesanan Anda',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const Gap(24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go('/login'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Masuk'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  const _MenuItem({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });
}
