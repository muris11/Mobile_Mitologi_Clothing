import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/product_pricing_model.dart';

class HomeCategoryPricelistSection extends StatefulWidget {
  final List<ProductPricingModel> pricings;

  const HomeCategoryPricelistSection({super.key, required this.pricings});

  @override
  State<HomeCategoryPricelistSection> createState() =>
      _HomeCategoryPricelistSectionState();
}

class _HomeCategoryPricelistSectionState
    extends State<HomeCategoryPricelistSection> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final active = widget.pricings.where((p) => p.isActive).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    if (active.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final selected = active[_selectedTab.clamp(0, active.length - 1)];

    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.surfaceContainerLow,
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 32, height: 2, color: AppColors.secondary),
                const Gap(10),
                const Text(
                  'HARGA PRODUK',
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
              'Daftar Harga per Kategori',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const Gap(8),
            Text(
              'Harga sudah termasuk jasa sablon dan bahan baku',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
            ),
            const Gap(24),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: active.length,
                itemBuilder: (ctx, i) {
                  final isSelected = i == _selectedTab;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTab = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.outlineVariant,
                        ),
                      ),
                      child: Text(
                        active[i].categoryName,
                        style: TextStyle(
                          color:
                              isSelected ? Colors.white : AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Gap(20),
            ...selected.items.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                      Text(
                        item.priceRange,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )),
            if (selected.minOrder != null && selected.minOrder!.isNotEmpty) ...[
              const Gap(8),
              Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 14, color: AppColors.primary),
                  const Gap(6),
                  Text(
                    'Min. order: ${selected.minOrder}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
