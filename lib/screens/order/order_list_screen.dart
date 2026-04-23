import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../utils/order_status.dart';
import '../../widgets/common/custom_pull_to_refresh.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/skeleton_loading.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _error;
  String _selectedStatus = 'all';

  final List<Map<String, dynamic>> _statusFilters = [
    {'label': 'Semua', 'value': 'all'},
    {'label': 'Pending', 'value': 'pending'},
    {'label': 'Processing', 'value': 'processing'},
    {'label': 'Shipped', 'value': 'shipped'},
    {'label': 'Completed', 'value': 'completed'},
    {'label': 'Cancelled', 'value': 'cancelled'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final orderService = context.read<OrderService>();
      final orders = await orderService.getOrders();

      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat pesanan: $e';
        _isLoading = false;
      });
    }
  }

  List<Order> get _filteredOrders {
    if (_selectedStatus == 'all') return _orders;
    return _orders
        .where((order) =>
            order.status?.toLowerCase() == _selectedStatus.toLowerCase())
        .toList();
  }

  // Status colors and icons now use shared OrderStatusUtils

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Pesanan Saya',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Status Filter
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _statusFilters.map((filter) {
                  final isSelected = _selectedStatus == filter['value'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(filter['label']),
                      onSelected: (selected) {
                        setState(() {
                          _selectedStatus = filter['value'];
                        });
                      },
                      backgroundColor: AppColors.background,
                      selectedColor: AppColors.primary.withValues(alpha: 0.1),
                      checkmarkColor: AppColors.primary,
                      labelStyle:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                      side: BorderSide(
                        color:
                            isSelected ? AppColors.primary : AppColors.outline,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const OrderListSkeleton(itemCount: 4)
                : _error != null
                    ? ErrorState(
                        message: _error!,
                        onRetry: _fetchOrders,
                      )
                    : _filteredOrders.isEmpty
                        ? AnimatedEmptyState(
                            icon: Icons.shopping_bag_outlined,
                            title: _selectedStatus == 'all'
                                ? 'Belum Ada Pesanan'
                                : 'Tidak Ada Pesanan',
                            subtitle: 'Pesanan Anda akan muncul di sini setelah Anda berbelanja',
                            actionLabel: 'Mulai Belanja',
                            onAction: () => context.go('/home'),
                          )
                        : CustomPullToRefresh(
                            onRefresh: _fetchOrders,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredOrders.length,
                              itemBuilder: (context, index) {
                                final order = _filteredOrders[index];
                                return _buildAnimatedOrderCard(
                                  order,
                                  currencyFormat,
                                  index,
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedOrderCard(
    Order order,
    NumberFormat currencyFormat,
    int index,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset((1 - value) * 50, 0),
            child: child,
          ),
        );
      },
      child: _buildOrderCard(order, currencyFormat),
    );
  }

  Widget _buildOrderCard(Order order, NumberFormat currencyFormat) {
    final statusColor = order.status.statusColor;
    final items = order.items ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.outline),
      ),
      child: InkWell(
        onTap: () => context.push('/orders/${order.orderNumber}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Number & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.receipt_outlined,
                        size: 16,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        order.orderNumber,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          order.status.statusIcon,
                          size: 12,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          order.displayStatus,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Product Preview
              Row(
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: items.isNotEmpty && items.first.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: items.first.imageUrl!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 60,
                              height: 60,
                              color: AppColors.background,
                              child: const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              width: 60,
                              height: 60,
                              color: AppColors.background,
                              child: const Icon(Icons.image,
                                  color: AppColors.outline),
                            ),
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: AppColors.background,
                            child: const Icon(Icons.shopping_bag,
                                color: AppColors.outline),
                          ),
                  ),
                  const SizedBox(width: 12),

                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          items.isNotEmpty ? items.first.title : 'Produk',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (items.length > 1)
                          Text(
                            '+${items.length - 1} produk lainnya',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          '${items.isNotEmpty ? items.first.quantity : 0} item',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Total & Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Pesanan',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.total != null
                            ? currencyFormat.format(order.total!.amount)
                            : '-',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  if (order.createdAt != null)
                    Text(
                      DateFormat('dd MMM yyyy', 'id_ID')
                          .format(order.createdAt!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.outline,
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
}
