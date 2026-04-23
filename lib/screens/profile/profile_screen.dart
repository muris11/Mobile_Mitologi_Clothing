import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/address.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/skeleton_loading.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  List<Address> _addresses = [];
  bool _isLoading = true;
  bool _hasLoaded = false;
  bool _profileLoadScheduled = false;
  bool? _lastAuthState;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncProfileState();
      }
    });
  }

  void _syncProfileState() {
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final isAuthenticated = authProvider.isAuthenticated;

    if (_lastAuthState != isAuthenticated) {
      _lastAuthState = isAuthenticated;
    }

    if (!isAuthenticated) {
      if (_user != null || _addresses.isNotEmpty || _hasLoaded || _isLoading) {
        setState(() {
          _user = null;
          _addresses = [];
          _hasLoaded = false;
          _isLoading = false;
        });
      }
      return;
    }

    if (_hasLoaded || _profileLoadScheduled) {
      return;
    }

    _profileLoadScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        await _loadProfile();
      } finally {
        _profileLoadScheduled = false;
      }
    });
  }

  Future<void> _loadProfile() async {
    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();

    if (!authProvider.isAuthenticated) {
      setState(() {
        _isLoading = false;
        _hasLoaded = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      await profileProvider.load();
      if (!mounted) return;
      setState(() {
        _user = profileProvider.user;
        _addresses = profileProvider.addresses;
        _isLoading = false;
        _hasLoaded = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasLoaded = true;
        _loadError = 'Gagal memuat profil. Silakan coba lagi.';
      });
    }
  }

  Future<void> _logout() async {
    // Capture provider before async operation
    final authProvider = context.read<AuthProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Keluar',
          style: GoogleFonts.notoSerif(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Yakin ingin keluar dari akun?',
          style: GoogleFonts.manrope(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.manrope(),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Keluar',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await authProvider.logout();
      if (!mounted) return;
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (_lastAuthState != authProvider.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _syncProfileState();
            }
          });
        }

        if (!authProvider.isAuthenticated) {
          return _buildGuestView();
        }

        if (_isLoading) {
          return const Scaffold(
            body: ProfileSkeleton(),
          );
        }

        if (_loadError != null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: AnimatedEmptyState(
                icon: Icons.error_outline,
                title: 'Gagal Memuat Profil',
                subtitle: _loadError!,
                actionLabel: 'Coba Lagi',
                onAction: () {
                  setState(() => _loadError = null);
                  _loadProfile();
                },
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                pinned: true,
                elevation: 0,
                backgroundColor: AppColors.surface.withAlpha(240),
                title: Text(
                  'Akun Saya',
                  style: GoogleFonts.notoSerif(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {
                      _showSettingsSheet(context);
                    },
                  ),
                ],
              ),

              // Profile Header
              SliverToBoxAdapter(
                child: _wrapWithReveal(_buildProfileHeader()),
              ),

              // Profile Detail Card
              SliverToBoxAdapter(
                child: _wrapWithReveal(_buildProfileDetailCard()),
              ),

              // Menu Grid
              SliverToBoxAdapter(
                child: _wrapWithReveal(_buildMenuGrid()),
              ),

              // CMS Content Pages
              SliverToBoxAdapter(
                child: _wrapWithReveal(_buildContentPagesSection()),
              ),

              // Addresses Section
              SliverToBoxAdapter(
                child: _wrapWithReveal(_buildAddressesSection()),
              ),

              // Orders Section
              SliverToBoxAdapter(
                child: _wrapWithReveal(_buildOrdersSection()),
              ),

              // Logout Button
              SliverToBoxAdapter(
                child: _wrapWithReveal(_buildLogoutButton()),
              ),

              // Contact Info Section
              SliverToBoxAdapter(
                child: _wrapWithReveal(_buildContactSection()),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 120),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _wrapWithReveal(Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, childWidget) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 30),
            child: childWidget,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildGuestView() {
    return AnimatedEmptyState(
      icon: Icons.person_outline,
      title: 'Masuk ke Akun Anda',
      subtitle: 'Silakan login untuk melihat profil dan pesanan Anda',
      actionLabel: 'Masuk',
      onAction: () => context.push('/login'),
      iconColor: AppColors.secondary,
    );
  }

  Widget _buildProfileHeader() {
    final avatarUrl = _user?.avatarUrl?.trim() ?? '';
    final role = _user?.role?.trim() ?? '';
    final phone = _user?.phone?.trim() ?? '';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(40),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipOval(
              child: SizedBox(
                width: 72,
                height: 72,
                child: avatarUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: avatarUrl,
                        fit: BoxFit.cover,
                        memCacheWidth: 144,
                        memCacheHeight: 144,
                        placeholder: (context, url) => Container(
                          color: AppColors.surfaceContainerLow,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => _buildAvatarFallback(),
                      )
                    : _buildAvatarFallback(),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _user?.name ?? 'Pengguna',
                    style: GoogleFonts.notoSerif(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _user?.email ?? 'email@example.com',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      color: AppColors.onPrimary.withAlpha(180),
                    ),
                  ),
                  if (phone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      phone,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: AppColors.onPrimary.withAlpha(180),
                      ),
                    ),
                  ],
                  if (role.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.onPrimary.withAlpha(20),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        role.toUpperCase(),
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Container(
      color: AppColors.onPrimary.withAlpha(20),
      child: Icon(
        Icons.person,
        size: 36,
        color: AppColors.onPrimary,
      ),
    );
  }

  Widget _buildProfileDetailCard() {
    if (_user == null) return const SizedBox.shrink();

    final details = <Map<String, String>>[
      {'label': 'Nama', 'value': _user?.name ?? '-'},
      {'label': 'Email', 'value': _user?.email ?? '-'},
      if ((_user?.phone ?? '').trim().isNotEmpty)
        {'label': 'Telepon', 'value': _user!.phone!.trim()},
      if ((_user?.role ?? '').trim().isNotEmpty)
        {'label': 'Role', 'value': _user!.role!.trim()},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail Akun',
              style: GoogleFonts.notoSerif(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            for (final detail in details) ...[
              _buildProfileDetailRow(detail['label']!, detail['value']!),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuGrid() {
    final menuItems = [
      {
        'icon': Icons.shopping_bag_outlined,
        'label': 'Pesanan',
        'route': '/orders',
      },
      {
        'icon': Icons.favorite_outline,
        'label': 'Wishlist',
        'route': '/wishlist',
      },
      {
        'icon': Icons.location_on_outlined,
        'label': 'Alamat',
        'route': '/profile/addresses',
      },
      {
        'icon': Icons.headset_mic_outlined,
        'label': 'Bantuan',
        'route': '/chatbot',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        children: menuItems.map((item) {
          return GestureDetector(
            onTap: () => context.push(item['route'] as String),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: AppColors.secondary,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['label'] as String,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAddressesSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alamat Tersimpan',
                style: GoogleFonts.notoSerif(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/profile/addresses'),
                child: Text(
                  'Lihat Semua',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_addresses.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.add_location_alt_outlined,
                    color: AppColors.outline,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Belum ada alamat tersimpan',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/profile/addresses'),
                    child: Text(
                      'Tambah',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ..._addresses.take(2).map((address) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.outlineVariant.withAlpha(50),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address.label ?? 'Alamat',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            address.shortAddress,
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (address.isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'DEFAULT',
                          style: GoogleFonts.manrope(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildOrdersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pesanan Terbaru',
            style: GoogleFonts.notoSerif(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.secondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lihat Riwayat Pesanan',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pantau status dan riwayat pembelian Anda',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.outline,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentPagesSection() {
    final contentPages = [
      {
        'icon': Icons.info_outline,
        'label': 'Tentang Kami',
        'handle': 'about',
      },
      {
        'icon': Icons.privacy_tip_outlined,
        'label': 'Kebijakan Privasi',
        'handle': 'privacy-policy',
      },
      {
        'icon': Icons.help_outline,
        'label': 'FAQ',
        'handle': 'faq',
      },
      {
        'icon': Icons.gavel_outlined,
        'label': 'Syarat & Ketentuan',
        'handle': 'terms-conditions',
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi',
            style: GoogleFonts.notoSerif(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: contentPages.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isLast = index == contentPages.length - 1;

                return Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 2,
                      ),
                      leading: Icon(
                        item['icon'] as IconData,
                        color: AppColors.secondary,
                      ),
                      title: Text(
                        item['label'] as String,
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: AppColors.outline,
                      ),
                      onTap: () {
                        context.push('/content/${item['handle']}');
                      },
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        indent: 56,
                        endIndent: 16,
                        color: AppColors.outlineVariant.withAlpha(70),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: OutlinedButton(
        onPressed: _logout,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 18),
            const SizedBox(width: 8),
            Text(
              'Keluar',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final siteSettings = productProvider.siteSettings;
        if (siteSettings == null) {
          return const SizedBox.shrink();
        }

        final phone = siteSettings['phone'] as String? ??
            siteSettings['whatsapp'] as String? ??
            '';
        final email = siteSettings['email'] as String? ?? '';
        final address = siteSettings['address'] as String? ?? '';
        final instagram = siteSettings['instagram'] as String? ?? '';
        final tiktok = siteSettings['tiktok'] as String? ?? '';

        final hasContact =
            phone.isNotEmpty || email.isNotEmpty || address.isNotEmpty;

        if (!hasContact) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Hubungi Kami',
                style: GoogleFonts.notoSerif(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (phone.isNotEmpty)
                      _buildContactRow(Icons.phone_android, 'WhatsApp', phone),
                    if (email.isNotEmpty)
                      _buildContactRow(Icons.email_outlined, 'Email', email),
                    if (address.isNotEmpty)
                      _buildContactRow(
                          Icons.location_on_outlined, 'Alamat', address),
                    if (instagram.isNotEmpty)
                      _buildContactRow(
                          Icons.camera_alt_outlined, 'Instagram', instagram),
                    if (tiktok.isNotEmpty)
                      _buildContactRow(Icons.music_note, 'TikTok', tiktok),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: AppColors.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengaturan',
              style: GoogleFonts.notoSerif(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: Text('Notifikasi', style: GoogleFonts.manrope()),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Pengaturan notifikasi akan segera hadir',
                      style: GoogleFonts.manrope(),
                    ),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.language_outlined),
              title: Text('Bahasa', style: GoogleFonts.manrope()),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Pengaturan bahasa akan segera hadir',
                      style: GoogleFonts.manrope(),
                    ),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text('Tentang Aplikasi', style: GoogleFonts.manrope()),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog(context);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Mitologi Clothing',
          style: GoogleFonts.notoSerif(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Versi 1.0.0\n\nAplikasi e-commerce resmi Mitologi Clothing.',
          style: GoogleFonts.manrope(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
