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
            _buildHistoryAndMakna(settings),
            _buildFounderStory(settings),
            _buildVisionMission(settings),
            _buildProductionFacilities(vm),
            _buildCompanyLegality(settings),
            _buildTeamSection(vm),
          ],
          const SliverToBoxAdapter(child: Gap(80)),
        ],
      ),
    );
  }

  // 1. Hero Section
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

  // 2. History Section + Makna Logo
  Widget _buildHistoryAndMakna(SiteSettingsModel settings) {
    final history = settings.aboutShortHistory ?? '';
    final maknaLogo = settings.aboutLogoMeaningDetailed;
    final year = settings.companyFoundedYear ?? '2022';
    final image = settings.aboutImage;

    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image != null && image.isNotEmpty) ...[
              Stack(
                children: [
                  Container(
                    height: 280,
                    width: double.infinity,
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
              const Gap(32),
            ],
            Row(
              children: [
                Container(
                  width: 28,
                  height: 2,
                  color: AppColors.secondary,
                ),
                const Gap(8),
                Text(
                  'SEJARAH SINGKAT',
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
              'Perjalanan Kami',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                height: 1.15,
              ),
            ),
            const Gap(16),
            if (history.isNotEmpty)
              Text(
                history,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
            if (maknaLogo.isNotEmpty) ...[
              const Gap(32),
              Text(
                'Makna Logo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const Gap(16),
              ...maknaLogo.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.letter,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: Text(
                            item.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  // 3. Founder Story
  Widget _buildFounderStory(SiteSettingsModel settings) {
    final name = settings.founderName;
    final role = settings.founderRole;
    final story = settings.founderStory;
    final photo = settings.founderPhoto;

    if ((name == null || name.isEmpty) && (story == null || story.isEmpty)) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.surfaceContainerLow,
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 48),
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
                  'KATA PENDIRI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                    letterSpacing: 0.25,
                  ),
                ),
              ],
            ),
            const Gap(24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (photo != null && photo.isNotEmpty)
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(ApiConfig.buildImageUrl(photo)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  if (story != null && story.isNotEmpty) ...[
                    Icon(
                      PhosphorIconsFill.quotes,
                      size: 32,
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                    const Gap(12),
                    Text(
                      story,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: AppColors.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                    const Gap(16),
                  ],
                  Text(
                    name ?? '',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  if (role != null && role.isNotEmpty)
                    Text(
                      role,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Vision Mission + Values
  Widget _buildVisionMission(SiteSettingsModel settings) {
    final vision = settings.visionStatement;
    final mission = settings.missionStatement;
    final valuesText = settings.valuesText;

    if ((vision == null || vision.isEmpty) &&
        (mission == null || mission.isEmpty)) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 48),
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
                  border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.3)),
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
                  border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.3)),
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
            const Gap(32),
            if (valuesText != null && valuesText.isNotEmpty) ...[
              Text(
                'Nilai-Nilai Kami',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const Gap(12),
              Text(
                valuesText,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              const Gap(24),
            ],
            _buildValuesGrid(),
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

  // 5. Production Facilities
  Widget _buildProductionFacilities(HomeViewModel vm) {
    final facilities = vm.facilities;
    if (facilities.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.surfaceContainerLow,
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 48),
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
                  'FASILITAS PRODUKSI',
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
              'Peralatan Terbaik',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                height: 1.15,
              ),
            ),
            const Gap(24),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: facilities.length,
              separatorBuilder: (context, index) => const Gap(16),
              itemBuilder: (context, index) {
                final facility = facilities[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (facility.imageUrl.isNotEmpty)
                        AppImage(
                          imageUrl: ApiConfig.buildImageUrl(facility.imageUrl),
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              facility.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            if (facility.description.isNotEmpty) ...[
                              const Gap(8),
                              Text(
                                facility.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                            ],
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

  // 6. Company Legality
  Widget _buildCompanyLegality(SiteSettingsModel settings) {
    final companyName = settings.legalCompanyName;
    final npwp = settings.legalNpwp;
    final nib = settings.legalNib;
    final nmid = settings.legalNmid;

    if ((companyName == null || companyName.isEmpty) &&
        (npwp == null || npwp.isEmpty) &&
        (nib == null || nib.isEmpty)) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 48),
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
                  'LEGALITAS',
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
              'Perusahaan Terdaftar',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                height: 1.15,
              ),
            ),
            const Gap(24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  _buildLegalityRow('Nama Perusahaan', companyName),
                  if (npwp != null && npwp.isNotEmpty) ...[
                    const Divider(height: 24),
                    _buildLegalityRow('NPWP', npwp),
                  ],
                  if (nib != null && nib.isNotEmpty) ...[
                    const Divider(height: 24),
                    _buildLegalityRow('NIB', nib),
                  ],
                  if (nmid != null && nmid.isNotEmpty) ...[
                    const Divider(height: 24),
                    _buildLegalityRow('NMID', nmid),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalityRow(String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value ?? '-',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  // 7. Team Section
  Widget _buildTeamSection(HomeViewModel vm) {
    final team = vm.teamMembers;
    if (team.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.surfaceContainerLow,
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 48),
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
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: team.length,
              itemBuilder: (ctx, i) {
                final member = team[i];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary)),
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