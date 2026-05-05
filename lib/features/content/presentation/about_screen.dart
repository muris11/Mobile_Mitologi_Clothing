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
            expandedHeight: 160,
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
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tentang Kami',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    settings?.siteName ?? 'Mitologi Clothing',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
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
            _buildBrandIntro(settings),
            _buildHistorySection(settings),
            _buildVisionMission(settings),
            _buildFacilitiesSection(vm),
            _buildTeamSection(vm),
          ],
          const SliverToBoxAdapter(child: Gap(80)),
        ],
      ),
    );
  }

  Widget _buildBrandIntro(SiteSettingsModel settings) {
    final headline = settings.aboutHeadline ?? settings.siteTagline ?? '';
    final desc1 = settings.aboutDescription1 ?? '';
    final desc2 = settings.aboutDescription2 ?? '';
    final year = settings.companyFoundedYear ?? '';
    final image = settings.aboutImage;

    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.primary,
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image != null && image.isNotEmpty)
              Container(
                height: 220,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.3)),
                ),
                clipBehavior: Clip.antiAlias,
                child: AppImage(
                  imageUrl: ApiConfig.buildImageUrl(image),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            if (year.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Berdiri sejak $year',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            if (headline.isNotEmpty)
              Text(
                headline,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1.3,
                ),
              ),
            if (desc1.isNotEmpty) ...[
              const Gap(16),
              Text(desc1,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 14, height: 1.6)),
            ],
            if (desc2.isNotEmpty) ...[
              const Gap(12),
              Text(desc2,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 14, height: 1.6)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection(SiteSettingsModel settings) {
    final history = settings.aboutShortHistory;
    if (history == null || history.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final paragraphs =
        history.split('\n').where((p) => p.trim().isNotEmpty).toList();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('SEJARAH KAMI'),
            const Gap(8),
            const Text('Perjalanan Mitologi',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const Gap(20),
            ...paragraphs.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    p,
                    style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.6),
                  ),
                )),
          ],
        ),
      ),
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('VISI & MISI'),
            const Gap(8),
            const Text('Arah & Tujuan Kami',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const Gap(20),
            if (vision != null && vision.isNotEmpty)
              _vmCard(
                icon: PhosphorIconsRegular.eye,
                label: 'VISI',
                text: vision,
                bgColor: AppColors.primary,
                textColor: Colors.white,
              ),
            if (mission != null && mission.isNotEmpty) ...[
              const Gap(16),
              _vmCard(
                icon: PhosphorIconsRegular.target,
                label: 'MISI',
                text: mission,
                bgColor: AppColors.surfaceContainerLowest,
                textColor: AppColors.onSurface,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _vmCard({
    required IconData icon,
    required String label,
    required String text,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
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
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const Gap(12),
              Text(
                label,
                style: TextStyle(
                  color: bgColor == AppColors.primary
                      ? AppColors.secondary
                      : AppColors.secondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const Gap(14),
          Text(
            text,
            style: TextStyle(
              color: bgColor == AppColors.primary
                  ? Colors.white.withValues(alpha: 0.9)
                  : AppColors.onSurfaceVariant,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitiesSection(HomeViewModel vm) {
    final facilities = vm.facilities;
    if (facilities.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('FASILITAS PRODUKSI'),
            const Gap(8),
            const Text('Dilengkapi Infrastruktur Modern',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const Gap(20),
            ...facilities.map((f) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      if (f.image.isNotEmpty)
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: AppImage(
                            imageUrl: ApiConfig.buildImageUrl(f.image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(f.name,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900)),
                              if (f.description.isNotEmpty) ...[
                                const Gap(4),
                                Text(f.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: AppColors.onSurfaceVariant,
                                        fontSize: 12,
                                        height: 1.4)),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSection(HomeViewModel vm) {
    final team = vm.teamMembers;
    if (team.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('TIM KAMI'),
            const Gap(8),
            const Text('Orang-Orang di Balik Mitologi',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const Gap(20),
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
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: member.photoUrl.isNotEmpty
                            ? AppImage(
                                imageUrl:
                                    ApiConfig.buildImageUrl(member.photoUrl),
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: AppColors.surfaceContainerLow,
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
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w900)),
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

  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(width: 28, height: 2, color: AppColors.secondary),
        const Gap(8),
        Text(
          text,
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
