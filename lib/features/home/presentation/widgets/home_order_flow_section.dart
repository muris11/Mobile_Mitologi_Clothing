import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/order_step_model.dart';

class HomeOrderFlowSection extends StatefulWidget {
  final List<OrderStepModel> orderSteps;

  const HomeOrderFlowSection({super.key, required this.orderSteps});

  @override
  State<HomeOrderFlowSection> createState() => _HomeOrderFlowSectionState();
}

class _HomeOrderFlowSectionState extends State<HomeOrderFlowSection> {
  String _activeType = 'langsung';

  @override
  Widget build(BuildContext context) {
    final types = widget.orderSteps.map((s) => s.type).toSet().toList();
    final filtered = widget.orderSteps
        .where((s) => s.type == _activeType)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    if (types.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    if (!types.contains(_activeType)) {
      _activeType = types.first;
    }

    final tabLabels = {
      'langsung': 'Order Langsung',
      'ecommerce': 'Via E-Commerce',
    };

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 32, height: 2, color: AppColors.secondary),
                const Gap(10),
                const Text(
                  'CARA PEMESANAN',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const Gap(12),
            const Text(
              'Alur Pemesanan',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const Gap(20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: types.map((type) {
                  final isSelected = type == _activeType;
                  return GestureDetector(
                    onTap: () => setState(() => _activeType = type),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tabLabels[type] ?? type.toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.onSurface,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Gap(24),
            ...filtered.asMap().entries.map((entry) {
              final i = entry.key;
              final step = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (i < filtered.length - 1)
                          Container(
                            width: 2,
                            height: 40,
                            color: AppColors.outlineVariant,
                          ),
                      ],
                    ),
                    const Gap(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            step.description,
                            style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
