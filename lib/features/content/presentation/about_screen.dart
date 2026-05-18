import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/widgets/app_image.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/site_settings_model.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/home_view_model.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
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
            expandedHeight: 0,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(PhosphorIconsRegular.arrowLeft,
                  color: AppColors.primary),
              onPressed: () => context.pop(),
            ),
          ),
          if (vm.isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (settings == null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text('Gagal memuat data.',
                      style: TextStyle(color: AppColors.onSurfaceVariant)),
                ),
              ),
            )
          else ...[
            _buildHeroSection(settings),
            _buildMainContent(settings),
            _buildVisionMission(settings),
            _buildTeamSection(vm),
          ],
          const SliverToBoxAdapter(child: Gap(80)),
        ],
      ),
    );
  }

  Widget _buildHeroSection(SiteSettingsModel settings) {
    final siteName = settings.siteName ?? 'Mitologi Clothing';
    final tagline = settings.aboutHeadline ?? settings.siteTagline ?? '';

    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
        child: Column(
          children: [
            Text(
              'Tentang Kami',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
                letterSpacing: 0.2,
              ),
            ),
            const Gap(12),
            Text(
              siteName,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(12),
            if (tagline.isNotEmpty)
              Text(
                tagline,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(SiteSettingsModel settings) {
    final siteName = settings.siteName ?? 'Mitologi Clothing';
    final desc1 = settings.aboutDescription1 ?? '';
    final desc2 = settings.aboutDescription2 ?? '';
    final year = settings.companyFoundedYear ?? '2022';
    final image = settings.aboutImage;

    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (image != null && image.isNotEmpty) ...[
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 280,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow.withValues(alpha: 0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: AppImage(
                            imageUrl: ApiConfig.buildImageUrl(image),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        Positioned(
                          bottom: -12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadow.withValues(alpha: 0.12),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Berdiri',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurfaceVariant,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                Text(
                                  year,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  'Indramayu',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const Gap(32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 2,
                      color: AppColors.secondary,
                    ),
                    const Gap(8),
                    Text(
                      'Tentang Kami',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                        letterSpacing: 0.25,
                      ),
                    ),
                  ],
                ),
                const Gap(12),
                Text(
                  siteName,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    height: 1.15,
                  ),
                ),
                const Gap(16),
                if (desc1.isNotEmpty)
                  Text(
                    desc1,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                if (desc2.isNotEmpty) ...[
                  const Gap(12),
                  Text(
                    desc2,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                ],
              ],
            ),
            const Gap(24),
            _buildValuesGrid(),
            const Gap(24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      Text(
                        'Pelajari lebih lanjut',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const Gap(6),
                      Icon(
                        PhosphorIconsRegular.arrowRight,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValuesGrid() {
    final values = [
      {'icon': PhosphorIconsRegular.shieldCheck, 'title': 'Kejujuran', 'desc': 'Integritas dalam setiap transaksi'},
      {'icon': PhosphorIconsRegular.star, 'title': 'Kualitas', 'desc': 'Standar kualitas tinggi'},
      {'icon': PhosphorIconsRegular.clock, 'title': 'Tepat Waktu', 'desc': 'Menghormati deadline'},
      {'icon': PhosphorIconsRegular.globeHemisphereEast, 'title': 'Budaya', 'desc': 'Mengangkat budaya lokal'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: values.length,
      itemBuilder: (context, index) {
        final item = values[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const Gap(12),
              Text(
                item['title'] as String,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const Gap(4),
              Text(
                item['desc'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVisionMission(SiteSettingsModel settings) {
    final vision = settings.visionStatement;
    final mission = settings.missionStatement;
    if ((vision == null || vision.isEmpty) &&
        (mission == null || mission.isEmpty)) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 2,
                  color: AppColors.secondary,
                ),
                const Gap(8),
                Text(
                  'VISI & MISI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                    letterSpacing: 0.25,
                  ),
                ),
              ],
            ),
            const Gap(12),
            Text(
              'Arah & Tujuan Kami',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                height: 1.15,
              ),
            ),
            const Gap(24),
            if (vision != null && vision.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            PhosphorIconsRegular.eye,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                        const Gap(12),
                        Text(
                          'VISI',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: AppColors.secondary,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    const Gap(14),
                    Text(
                      vision,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            if (mission != null && mission.isNotEmpty) ...[
              const Gap(16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            PhosphorIconsRegular.target,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                        const Gap(12),
                        Text(
                          'MISI',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    const Gap(14),
                    Text(
                      mission,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSection(HomeViewModel vm) {
    final team = vm.teamMembers;
    if (team.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 2,
                  color: AppColors.secondary,
                ),
                const Gap(8),
                Text(
                  'TIM KAMI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                    letterSpacing: 0.25,
                  ),
                ),
              ],
            ),
            const Gap(12),
            Text(
              'Orang-Orang di Balik Mitologi',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                height: 1.15,
              ),
            ),
            const Gap(24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: team.length,
              itemBuilder: (ctx, i) {
                final member = team[i];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: member.photoUrl.isNotEmpty
                            ? AppImage(
                                imageUrl: ApiConfig.buildImageUrl(member.photoUrl),
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: AppColors.surfaceContainer,
                                child: Icon(
                                  PhosphorIconsRegular.user,
                                  size: 48,
                                  color: AppColors.outlineVariant,
                                ),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(member.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primary)),
                            if (member.position.isNotEmpty)
                              Text(member.position,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: AppColors.secondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}