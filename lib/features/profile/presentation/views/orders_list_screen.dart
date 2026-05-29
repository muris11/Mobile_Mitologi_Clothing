import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/widgets/common/empty_state.dart';
import 'package:mitologi_clothing_mobile/features/checkout/domain/models/order_model.dart';
import 'package:mitologi_clothing_mobile/features/profile/data/profile_repository.dart';
import 'package:mitologi_clothing_mobile/widgets/common/skeleton_loading.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  List<OrderModel> _orders = [];
  List<OrderModel> _allOrders = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'all';

  final List<Map<String, dynamic>> _filters = [
    {'value': 'all', 'label': 'Semua'},
    {'value': 'ongoing', 'label': 'Berjalan'},
    {'value': 'completed', 'label': 'Selesai'},
    {'value': 'cancelled', 'label': 'Dibatalkan'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = context.read<ProfileRepository>();
      final orders = await repo.getOrders();
      if (mounted) {
        setState(() {
          _allOrders = orders;
          _applyFilter();
        });
      }
    } catch (e) {
      String msg = e.toString();
      if (msg.startsWith('Exception: ')) {
        msg = msg.substring('Exception: '.length);
      }
      if (mounted) setState(() => _error = msg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    switch (_selectedFilter) {
      case 'ongoing':
        _orders = _allOrders.where((o) =>
            ['pending', 'paid', 'processing', 'shipped', 'delivered'].contains(o.status)).toList();
        break;
      case 'completed':
        _orders = _allOrders.where((o) => o.status == 'completed').toList();
        break;
      case 'cancelled':
        _orders = _allOrders.where((o) => o.status == 'cancelled' || o.status == 'refunded').toList();
        break;
      default:
        _orders = List.from(_allOrders);
    }
  }

  void _setFilter(String value) {
    setState(() {
      _selectedFilter = value;
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Pesanan Saya',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.8),
          child: Container(height: 0.8, color: AppColors.outlineVariant),
        ),
      ),
      body: _isLoading
          ? const OrderListSkeleton()
          : _error != null
              ? _buildError()
              : Column(
                  children: [
                    _buildFilterBar(),
                    Expanded(
                      child: _orders.isEmpty
                          ? _buildEmpty()
                          : RefreshIndicator(
                              onRefresh: _fetchOrders,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _orders.length,
                                itemBuilder: (context, index) {
                                  return _buildOrderCard(_orders[index]);
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter['value'];
          return Expanded(
            child: GestureDetector(
              onTap: () => _setFilter(filter['value'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  filter['label'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIconsRegular.warning, size: 48, color: AppColors.error),
            const Gap(16),
            Text(_error!, textAlign: TextAlign.center),
            const Gap(16),
            FilledButton(
              onPressed: _fetchOrders,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return AnimatedEmptyState(
      icon: PhosphorIconsRegular.shoppingBag,
      title: 'Belum Ada Pesanan',
      subtitle: 'Mulai belanja dan buat pesanan pertama Anda.',
      actionLabel: 'Lihat Katalog',
      onAction: () => context.push('/products'),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
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
    final formattedDate = _formatDate(order.createdAt);
    final formattedTotal = _formatCurrency(order.totalAmount);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [AppShadows.cardSoft],
      ),
      child: InkWell(
        onTap: () => context.push('/orders/${order.orderNumber}'),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '#${order.orderNumber}',
                      style: AppTextStyles.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Gap(8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              const Gap(10),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 4,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(PhosphorIconsRegular.calendarBlank,
                          size: 13, color: AppColors.onSurfaceVariant),
                      const Gap(4),
                      Text(
                        formattedDate,
                        style: AppTextStyles.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(PhosphorIconsRegular.package,
                          size: 13, color: AppColors.onSurfaceVariant),
                      const Gap(4),
                      Text(
                        '${order.itemsCount > 0 ? order.itemsCount : order.items.length} item',
                        style: AppTextStyles.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Gap(12),
              const Divider(height: 1),
              const Gap(12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Total Pembayaran',
                      style: AppTextStyles.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    formattedTotal,
                    style: AppTextStyles.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }
}
