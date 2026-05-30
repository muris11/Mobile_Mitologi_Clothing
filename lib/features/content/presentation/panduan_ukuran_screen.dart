import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';
import 'package:mitologi_clothing_mobile/widgets/common/premium_back_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/* ──────────────────── Data matching nextjs-commerce ──────────────────── */

const _sizeChartKaos = [
  ['S', '69', '48'],
  ['M', '71', '51'],
  ['L', '74', '54'],
  ['XL', '77', '56'],
  ['XXL', '79', '59'],
  ['3XL', '82', '62'],
  ['4XL', '84', '64'],
];

const _kemejaCategories = [
  {
    'title': 'TK',
    'sizes': ['S', 'M', 'L', 'XL', 'XXL'],
    'lebar': ['41', '43', '45', '47', '49'],
    'tinggi': ['48', '50', '52', '54', '56'],
  },
  {
    'title': 'SD Kls 1-3',
    'sizes': ['S', 'M', 'L', 'XL', 'XXL'],
    'lebar': ['43', '45', '47', '49', '51'],
    'tinggi': ['52', '54', '56', '58', '60'],
  },
  {
    'title': 'SD Kls 4-6',
    'sizes': ['S', 'M', 'L', 'XL', 'XXL'],
    'lebar': ['45', '47', '49', '51', '53'],
    'tinggi': ['56', '58', '60', '62', '64'],
  },
  {
    'title': 'SMP',
    'sizes': ['S', 'M', 'L', 'XL', 'XXL'],
    'lebar': ['48', '51', '53', '55', '57'],
    'tinggi': ['66', '68', '70', '72', '74'],
  },
  {
    'title': 'Dewasa',
    'sizes': ['S', 'M', 'L', 'XL', 'XXL'],
    'lebar': ['51', '53', '55', '57', '60'],
    'tinggi': ['68', '70', '72', '74', '76'],
  },
];

const _measurementSteps = [
  {
    'no': '1',
    'title': 'Lebar Dada',
    'desc': 'Ukur bagian terlebar dari dada secara horizontal, dari sisi kiri ke kanan.',
    'icon': PhosphorIconsRegular.arrowsHorizontal,
  },
  {
    'no': '2',
    'title': 'Panjang Badan',
    'desc': 'Ukur dari bahu paling tinggi hingga ujung bawah pakaian.',
    'icon': PhosphorIconsRegular.arrowsVertical,
  },
  {
    'no': '3',
    'title': 'Lebar (Kemeja)',
    'desc': 'Ukur secara horizontal pada bagian terlebar badan kemeja.',
    'icon': PhosphorIconsRegular.ruler,
  },
  {
    'no': '4',
    'title': 'Tinggi (Kemeja)',
    'desc': 'Ukur dari bahu sampai ujung bawah kemeja secara vertikal.',
    'icon': PhosphorIconsRegular.navigationArrow,
  },
];

const _tips = [
  'Gunakan pita ukur (meteran kain) untuk hasil yang akurat.',
  'Ukurlah dalam posisi berdiri tegak dan rileks.',
  'Jika ukuran Anda berada di antara dua ukuran, pilih ukuran yang lebih besar.',
  'Bahan katun combed bisa menyusut ±2-3% setelah pencucian pertama.',
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
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leadingWidth: 64,
        leading: PremiumBackButton(onPressed: () => context.pop()),
        title: Text(
          'Panduan Ukuran',
          style: AppTextStyles.plusJakartaSans(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: AppColors.primary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: AppTextStyles.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          unselectedLabelStyle: AppTextStyles.plusJakartaSans(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
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
          const SizeCalculatorWidget(),
          const Gap(24),
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
    if (isKemeja) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(PhosphorIconsRegular.ruler, size: 18),
                Gap(8),
                Text(
                  'Size Chart — Kemeja',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ],
            ),
          ),
          const Text(
            'Ukuran untuk kemeja seragam dari TK hingga Dewasa.',
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
          ),
          const Gap(16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _kemejaCategories.length,
            separatorBuilder: (context, index) => const Gap(16),
            itemBuilder: (context, index) {
              final cat = _kemejaCategories[index];
              final sizes = cat['sizes'] as List<String>;
              final lebar = cat['lebar'] as List<String>;
              final tinggi = cat['tinggi'] as List<String>;

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Text(
                        cat['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Table(
                      border: TableBorder(
                        horizontalInside: BorderSide(
                          color: AppColors.outlineVariant.withValues(alpha: 0.2),
                        ),
                      ),
                      columnWidths: const {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.05),
                          ),
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                'Size',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 12),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                'Lebar',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                'Tinggi',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        ...List.generate(sizes.length, (i) {
                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  sizes[i],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  '${lebar[i]} cm',
                                  style: const TextStyle(fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  '${tinggi[i]} cm',
                                  style: const TextStyle(fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const Gap(8),
          const Text(
            '* Toleransi ukuran ±1-2 cm. Semua ukuran dalam centimeter (cm).',
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
          ),
        ],
      );
    }

    final headers = ['Size Chart', 'S', 'M', 'L', 'XL', 'XXL', '3XL', '4XL'];

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
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: [
                Icon(PhosphorIconsRegular.ruler, size: 18),
                Gap(8),
                Text(
                  'Size Chart — Kaos & Jersey',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              'Ukuran standar untuk kaos polos, kaos sablon, dan jersey olahraga.',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(
                  AppColors.primary.withValues(alpha: 0.05)),
              columnSpacing: 20,
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: 13,
              ),
              dataTextStyle: const TextStyle(fontSize: 13),
              columns: headers.map((h) => DataColumn(label: Text(h))).toList(),
              rows: [
                DataRow(
                  cells: [
                    const DataCell(
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.primaryContainer,
                            child: Text(
                              'P',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary),
                            ),
                          ),
                          Gap(8),
                          Text('Panjang (P)',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    ..._sizeChartKaos.map((row) => DataCell(Text('${row[1]} cm'))),
                  ],
                ),
                DataRow(
                  cells: [
                    const DataCell(
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.primaryContainer,
                            child: Text(
                              'LD',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary),
                            ),
                          ),
                          Gap(8),
                          Text('Lebar Dada (LD)',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    ..._sizeChartKaos.map((row) => DataCell(Text('${row[2]} cm'))),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              '* Toleransi ukuran ±1-2 cm. Semua ukuran dalam centimeter (cm).',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
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
            decoration: const BoxDecoration(
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

/* ──────────────────── Interactive Size Calculator Widget ──────────────────── */

class SizeCalculatorWidget extends StatefulWidget {
  const SizeCalculatorWidget({super.key});

  @override
  State<SizeCalculatorWidget> createState() => _SizeCalculatorWidgetState();
}

class _SizeCalculatorWidgetState extends State<SizeCalculatorWidget> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String? _recommendation;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  String _calculateSize(double w, double h) {
    String sizeByWeight = "S";
    if (w < 50) {
      sizeByWeight = "S";
    } else if (w >= 50 && w < 60) {
      sizeByWeight = "M";
    } else if (w >= 60 && w < 75) {
      sizeByWeight = "L";
    } else if (w >= 75 && w < 85) {
      sizeByWeight = "XL";
    } else if (w >= 85 && w < 95) {
      sizeByWeight = "XXL";
    } else if (w >= 95 && w < 105) {
      sizeByWeight = "3XL";
    } else {
      sizeByWeight = "4XL";
    }

    String sizeByHeight = "S";
    if (h < 155) {
      sizeByHeight = "S";
    } else if (h >= 155 && h < 165) {
      sizeByHeight = "M";
    } else if (h >= 165 && h < 175) {
      sizeByHeight = "L";
    } else if (h >= 175 && h < 180) {
      sizeByHeight = "XL";
    } else if (h >= 180 && h < 185) {
      sizeByHeight = "XXL";
    } else if (h >= 185 && h < 190) {
      sizeByHeight = "3XL";
    } else {
      sizeByHeight = "4XL";
    }

    const sizeRank = {
      'S': 1,
      'M': 2,
      'L': 3,
      'XL': 4,
      'XXL': 5,
      '3XL': 6,
      '4XL': 7,
    };

    final rankW = sizeRank[sizeByWeight] ?? 1;
    final rankH = sizeRank[sizeByHeight] ?? 1;

    final finalRank = rankW > rankH ? rankW : rankH;
    final finalSize = sizeRank.keys.firstWhere(
      (key) => sizeRank[key] == finalRank,
      orElse: () => "L",
    );

    return finalSize;
  }

  void _handleCalculate() {
    if (_formKey.currentState!.validate()) {
      final h = double.tryParse(_heightController.text);
      final w = double.tryParse(_weightController.text);
      if (h != null && w != null) {
        setState(() {
          _recommendation = _calculateSize(w, h);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    PhosphorIconsRegular.calculator,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const Gap(12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kalkulator Ukuran',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      Text(
                        'Dapatkan rekomendasi ukuran instan.',
                        style: TextStyle(
                            color: AppColors.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Tinggi Badan (cm)',
                      hintText: 'Contoh: 170',
                      labelStyle: const TextStyle(fontSize: 12),
                      hintStyle: const TextStyle(fontSize: 12),
                      suffixText: 'cm',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wajib diisi';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Angka tidak valid';
                      }
                      return null;
                    },
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Berat Badan (kg)',
                      hintText: 'Contoh: 65',
                      labelStyle: const TextStyle(fontSize: 12),
                      hintStyle: const TextStyle(fontSize: 12),
                      suffixText: 'kg',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wajib diisi';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Angka tidak valid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const Gap(16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleCalculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Hitung Rekomendasi',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ),
            if (_recommendation != null) ...[
              const Gap(20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Center(
                        child: Text(
                          _recommendation!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
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
                            'Rekomendasi: Ukuran $_recommendation',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            'Agar nyaman dan pas di badan Anda (${_heightController.text}cm, ${_weightController.text}kg).',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Gap(12),
            const Text(
              '* Ini adalah estimasi ukuran standar. Pastikan Anda mengecek tabel lengkap di bawah.',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
