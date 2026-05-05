import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

const _sizeChartKaos = [
  ['S', '66', '48', '19'],
  ['M', '69', '51', '20'],
  ['L', '72', '54', '21'],
  ['XL', '75', '57', '22'],
  ['XXL', '78', '60', '23'],
  ['3XL', '81', '63', '24'],
];

const _sizeChartKemeja = [
  ['S', '68', '50', '42', '20'],
  ['M', '71', '53', '44', '21'],
  ['L', '74', '56', '46', '22'],
  ['XL', '77', '59', '48', '23'],
  ['XXL', '80', '62', '50', '24'],
  ['3XL', '83', '65', '52', '25'],
];

const _measurementSteps = [
  {
    'no': '1',
    'title': 'Panjang Badan',
    'desc': 'Ukur dari titik tertinggi bahu hingga ujung bawah pakaian.',
    'icon': PhosphorIconsRegular.arrowsVertical,
  },
  {
    'no': '2',
    'title': 'Lebar Bahu',
    'desc': 'Ukur dari ujung bahu kiri ke ujung bahu kanan.',
    'icon': PhosphorIconsRegular.arrowsHorizontal,
  },
  {
    'no': '3',
    'title': 'Lingkar Dada',
    'desc':
        'Ukur bagian terlebar dada. Bagi 2 untuk mendapat ukuran lebar dada.',
    'icon': PhosphorIconsRegular.arrowsCounterClockwise,
  },
  {
    'no': '4',
    'title': 'Lingkar Perut',
    'desc':
        'Ukur bagian terlebar perut/pinggang. Bagi 2 untuk ukuran lebar perut.',
    'icon': PhosphorIconsRegular.arrowsCounterClockwise,
  },
];

const _tips = [
  'Selalu ukur dengan posisi berdiri tegak dan rileks',
  'Tambah 2–3 cm dari hasil pengukuran untuk kenyamanan gerak',
  'Jika berada di antara dua ukuran, pilih ukuran yang lebih besar',
  'Untuk Reguler Fit, ukuran sesuai tabel; untuk Oversized, naik 1–2 ukuran',
  'Tipe kain mempengaruhi ukuran — bahan stretch lebih fleksibel',
];

class PanduanUkuranScreen extends StatefulWidget {
  const PanduanUkuranScreen({super.key});

  @override
  State<PanduanUkuranScreen> createState() => _PanduanUkuranScreenState();
}

class _PanduanUkuranScreenState extends State<PanduanUkuranScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Panduan Ukuran',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          tabs: const [
            Tab(text: 'Kaos & Jersey'),
            Tab(text: 'Kemeja'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContent(isKemeja: false),
          _buildContent(isKemeja: true),
        ],
      ),
    );
  }

  Widget _buildContent({required bool isKemeja}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(8),
          _buildSizeChart(isKemeja: isKemeja),
          const Gap(24),
          _buildMeasurementGuide(),
          const Gap(24),
          _buildTips(),
          const Gap(24),
          _buildCta(),
          const Gap(32),
        ],
      ),
    );
  }

  Widget _buildSizeChart({required bool isKemeja}) {
    final headers = isKemeja
        ? ['Ukuran', 'Panjang', 'Dada', 'Perut', 'Bahu']
        : ['Ukuran', 'Panjang', 'Dada', 'Bahu'];
    final rows = isKemeja ? _sizeChartKemeja : _sizeChartKaos;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(PhosphorIconsRegular.ruler, size: 18),
                const Gap(8),
                Text(
                  'Tabel Ukuran ${isKemeja ? "Kemeja" : "Kaos & Jersey"} (cm)',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(
                  AppColors.primary.withValues(alpha: 0.05)),
              columnSpacing: 24,
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: 13,
              ),
              dataTextStyle: const TextStyle(fontSize: 13),
              columns: headers.map((h) => DataColumn(label: Text(h))).toList(),
              rows: rows.map((row) {
                return DataRow(
                  cells: row.map((cell) => DataCell(Text(cell))).toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cara Mengukur',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const Gap(12),
        ..._measurementSteps.map((step) => _buildStepCard(step)),
      ],
    );
  }

  Widget _buildStepCard(Map<String, dynamic> step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step['no'] as String,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14),
              ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step['title'] as String,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                const Gap(4),
                Text(step['desc'] as String,
                    style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 13,
                        height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(PhosphorIconsFill.lightbulb,
                  color: Color(0xFFD97706), size: 20),
              Gap(8),
              Text('Tips Memilih Ukuran',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Color(0xFF92400E))),
            ],
          ),
          const Gap(12),
          ..._tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(PhosphorIconsFill.checkCircle,
                      size: 16, color: Color(0xFFD97706)),
                  const Gap(8),
                  Expanded(
                    child: Text(tip,
                        style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF78350F),
                            height: 1.4)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCta() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          const Text('Masih bingung pilih ukuran?',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              textAlign: TextAlign.center),
          const Gap(8),
          const Text('Tim kami siap membantu.',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
              textAlign: TextAlign.center),
          const Gap(14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                final uri = Uri.parse('https://wa.me/6281322170902');
                if (await canLaunchUrl(uri)) {
                  launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(PhosphorIconsRegular.whatsappLogo, size: 18),
              label: const Text('Konsultasi via WhatsApp',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                padding: const EdgeInsets.all(14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
