import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/site_settings_model.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/home_view_model.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class KontakScreen extends StatefulWidget {
  const KontakScreen({super.key});

  @override
  State<KontakScreen> createState() => _KontakScreenState();
}

class _KontakScreenState extends State<KontakScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<HomeViewModel>();
      if (vm.siteSettings == null && !vm.isLoading) {
        vm.fetchHomeData();
      }
    });
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _copyToClipboard(BuildContext ctx, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text('Disalin: $text'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final settings = vm.siteSettings;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: false,
            pinned: true,
            expandedHeight: 140,
            backgroundColor: AppColors.primary,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(PhosphorIconsRegular.arrowLeft,
                  color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 56, bottom: 16, right: 16),
              title: const Text(
                'Hubungi Kami',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          if (vm.isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderText(),
                    const Gap(28),
                    _buildContactCards(context, settings),
                    const Gap(24),
                    _buildOperatingHours(settings),
                    const Gap(24),
                    _buildSocialMedia(settings),
                    const Gap(24),
                    _buildWhatsAppCTA(context, settings),
                  ],
                ),
              ),
            ),
          const SliverToBoxAdapter(child: Gap(80)),
        ],
      ),
    );
  }

  Widget _buildHeaderText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(width: 28, height: 2, color: AppColors.secondary),
          const Gap(8),
          Text(
            'LAYANAN PELANGGAN',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ]),
        const Gap(10),
        RichText(
          text: TextSpan(
            style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                height: 1.2),
            children: [
              const TextSpan(text: 'Mari '),
              TextSpan(
                text: 'Terhubung',
                style: TextStyle(color: AppColors.secondary),
              ),
            ],
          ),
        ),
        const Gap(10),
        Text(
          'Konsultasi, pemesanan, atau sekadar bertanya — tim kami siap membantu.',
          style:
              TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildContactCards(BuildContext ctx, SiteSettingsModel? settings) {
    final address = settings?.contactAddress ?? 'Jl. Raya Lelea, Indramayu, Jawa Barat';
    final phone = settings?.contactPhone ?? settings?.contactWhatsapp ?? '-';
    final email = settings?.contactEmail ?? 'mitologiclothing@gmail.com';

    final items = [
      _ContactItem(
        icon: PhosphorIconsRegular.mapPin,
        label: 'Alamat Workshop',
        value: address,
        onTap: address.isNotEmpty
            ? () => _launch(
                'https://www.google.com/maps/search/${Uri.encodeComponent(address)}')
            : null,
      ),
      _ContactItem(
        icon: PhosphorIconsRegular.phone,
        label: 'Telepon / WhatsApp',
        value: phone,
        onTap: phone != '-'
            ? () => _launch('tel:${phone.replaceAll(RegExp(r'[^0-9+]'), '')}')
            : null,
        onLongPress: phone != '-'
            ? () => _copyToClipboard(ctx, phone)
            : null,
      ),
      _ContactItem(
        icon: PhosphorIconsRegular.envelope,
        label: 'Email',
        value: email,
        onTap: () => _launch('mailto:$email'),
        onLongPress: () => _copyToClipboard(ctx, email),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              InkWell(
                onTap: item.onTap,
                onLongPress: item.onLongPress,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item.icon,
                            size: 20, color: Colors.white),
                      ),
                      const Gap(14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.label,
                              style: TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1),
                            ),
                            const Gap(2),
                            Text(
                              item.value,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                      if (item.onTap != null)
                        Icon(PhosphorIconsRegular.arrowRight,
                            size: 16,
                            color: AppColors.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
              if (i < items.length - 1)
                Divider(
                    height: 1,
                    indent: 78,
                    color: AppColors.outlineVariant),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOperatingHours(SiteSettingsModel? settings) {
    final weekdayLabel =
        settings?.operatingHoursWeekdayLabel ?? 'Senin - Sabtu';
    final weekdayHours = settings?.operatingHoursWeekday ?? '08.00 - 16.00 WIB';
    final weekendLabel = settings?.operatingHoursWeekendLabel ?? 'Minggu';
    final weekendHours =
        settings?.operatingHoursWeekend ?? 'Tutup (Online Chat Only)';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(PhosphorIconsRegular.clock,
                    size: 20, color: AppColors.primary),
              ),
              const Gap(12),
              const Text(
                'Jam Operasional',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const Gap(20),
          _hourRow(weekdayLabel, weekdayHours, Colors.white70, Colors.white),
          const Gap(12),
          _hourRow(weekendLabel, weekendHours, Colors.white60,
              AppColors.secondary),
        ],
      ),
    );
  }

  Widget _hourRow(String label, String hours, Color labelColor,
      Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                    color: labelColor, shape: BoxShape.circle)),
            const Gap(10),
            Text(label,
                style: TextStyle(
                    color: labelColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        Text(hours,
            style: TextStyle(
                color: valueColor,
                fontSize: 13,
                fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildSocialMedia(SiteSettingsModel? settings) {
    final socials = <_SocialItem>[
      if (settings?.socialInstagram != null &&
          settings!.socialInstagram!.isNotEmpty)
        _SocialItem(
          label: 'Instagram',
          icon: PhosphorIconsRegular.instagramLogo,
          url: settings.socialInstagram!,
        ),
      if (settings?.socialTiktok != null &&
          settings!.socialTiktok!.isNotEmpty)
        _SocialItem(
          label: 'TikTok',
          icon: PhosphorIconsRegular.tiktokLogo,
          url: settings.socialTiktok!,
        ),
      if (settings?.socialFacebook != null &&
          settings!.socialFacebook!.isNotEmpty)
        _SocialItem(
          label: 'Facebook',
          icon: PhosphorIconsRegular.facebookLogo,
          url: settings.socialFacebook!,
        ),
      if (settings?.socialShopee != null &&
          settings!.socialShopee!.isNotEmpty)
        _SocialItem(
          label: 'Shopee',
          icon: PhosphorIconsRegular.shoppingBag,
          url: settings.socialShopee!,
        ),
    ];

    if (socials.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Media Sosial',
            style:
                TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
        const Gap(12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: socials
              .map((s) => InkWell(
                    onTap: () => _launch(s.url),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(s.icon,
                              size: 24, color: AppColors.primary),
                          const Gap(4),
                          Text(s.label,
                              style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildWhatsAppCTA(BuildContext ctx, SiteSettingsModel? settings) {
    final wa = settings?.contactWhatsapp ?? settings?.contactPhone;
    if (wa == null || wa.isEmpty) return const SizedBox.shrink();

    final waNumber = wa.replaceAll(RegExp(r'[^0-9]'), '');
    final waUrl =
        'https://wa.me/$waNumber?text=${Uri.encodeComponent('Halo, saya ingin konsultasi tentang pemesanan clothing.')}';

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _launch(waUrl),
        icon: const Icon(PhosphorIconsRegular.whatsappLogo, size: 20),
        label: const Text('Chat WhatsApp Sekarang',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF25D366),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }
}

class _ContactItem {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.onLongPress,
  });
}

class _SocialItem {
  final String label;
  final IconData icon;
  final String url;

  const _SocialItem(
      {required this.label, required this.icon, required this.url});
}
