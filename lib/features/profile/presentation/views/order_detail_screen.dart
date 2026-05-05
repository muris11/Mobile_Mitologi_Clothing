import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/widgets/app_image.dart';
import 'package:mitologi_clothing_mobile/features/checkout/domain/models/order_model.dart';
import 'package:mitologi_clothing_mobile/features/checkout/presentation/views/midtrans_payment_screen.dart';
import 'package:mitologi_clothing_mobile/features/profile/data/profile_repository.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderNumber;

  const OrderDetailScreen({super.key, required this.orderNumber});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  OrderModel? _order;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchOrder();
  }

  Future<void> _fetchOrder() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = context.read<ProfileRepository>();
      final order = await repo.getOrderDetail(widget.orderNumber);
      if (mounted) setState(() => _order = order);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
        title: Text(
          'Order #${widget.orderNumber}',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _order == null
                  ? const Center(child: Text('Pesanan tidak ditemukan.'))
                  : RefreshIndicator(
                      onRefresh: _fetchOrder,
                      child: _buildContent(_order!),
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
            Icon(PhosphorIconsRegular.warning,
                size: 48, color: AppColors.error),
            const Gap(16),
            Text(_error!, textAlign: TextAlign.center),
            const Gap(16),
            FilledButton(
                onPressed: _fetchOrder, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(OrderModel order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusBadge(order),
          const Gap(16),
          if (!['cancelled', 'refunded'].contains(order.status)) ...[
            _buildProgressStepper(order),
            const Gap(16),
          ],
          _buildItemsCard(order),
          const Gap(12),
          _buildShippingCard(order),
          const Gap(12),
          _buildPaymentSummary(order),
          const Gap(12),
          _buildActions(order),
          const Gap(32),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OrderModel order) {
    final config = _statusConfig(order.status);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: config['bg'] as Color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: (config['color'] as Color).withValues(alpha: 0.3)),
          ),
          child: Text(
            config['label'] as String,
            style: TextStyle(
              color: config['color'] as Color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
        const Spacer(),
        Text(
          _formatDate(order.createdAt),
          style:
              const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildProgressStepper(OrderModel order) {
    final steps = [
      {'key': 'pending', 'label': 'Dipesan'},
      {'key': 'paid', 'label': 'Dibayar'},
      {'key': 'processing', 'label': 'Diproses'},
      {'key': 'shipped', 'label': 'Dikirim'},
      {'key': 'delivered', 'label': 'Sampai'},
    ];
    final statusOrder = [
      'pending',
      'paid',
      'processing',
      'shipped',
      'delivered',
      'completed'
    ];
    final currentIdx = statusOrder.indexOf(order.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepIdx = i ~/ 2;
            final done = currentIdx > stepIdx || order.status == 'completed';
            return Expanded(
              child: Container(
                height: 2,
                color: done ? AppColors.primary : AppColors.outlineVariant,
              ),
            );
          }
          final stepIdx = i ~/ 2;
          final done = currentIdx > stepIdx || order.status == 'completed';
          final active = currentIdx == stepIdx;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: done || active
                      ? AppColors.primary
                      : AppColors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: active
                      ? Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 3)
                      : null,
                ),
                child: done
                    ? const Icon(PhosphorIconsFill.check,
                        size: 14, color: Colors.white)
                    : Center(
                        child: Text(
                          '${stepIdx + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: active
                                ? Colors.white
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
              ),
              const Gap(6),
              Text(
                steps[stepIdx]['label']!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: done || active
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildItemsCard(OrderModel order) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(PhosphorIconsRegular.shoppingBag, size: 18),
              const Gap(8),
              Text(
                'Produk (${order.items.length} item)',
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
          const Gap(12),
          ...order.items.map((item) => _buildItemRow(item)),
        ],
      ),
    );
  }

  Widget _buildItemRow(OrderItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.productImage != null && item.productImage!.isNotEmpty
                ? AppImage(
                    imageUrl: ApiConfig.buildImageUrl(item.productImage!),
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  )
                : _imagePlaceholder(),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productTitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.variantTitle != null)
                  Text(
                    item.variantTitle!,
                    style: const TextStyle(
                        color: AppColors.onSurfaceVariant, fontSize: 12),
                  ),
                const Gap(4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.quantity}x ${_formatCurrency(item.price)}',
                      style: const TextStyle(
                          color: AppColors.onSurfaceVariant, fontSize: 12),
                    ),
                    Text(
                      _formatCurrency(item.total),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 64,
      height: 64,
      color: AppColors.surfaceContainerHighest,
      child: const Icon(PhosphorIconsRegular.image,
          color: AppColors.onSurfaceVariant),
    );
  }

  Widget _buildShippingCard(OrderModel order) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(PhosphorIconsRegular.mapPin, size: 18),
              const Gap(8),
              const Text('Informasi Pengiriman',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
          const Gap(12),
          if (order.shippingAddress != null) ...[
            Text(order.shippingAddress!.recipientName,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            if (order.shippingAddress!.phone.isNotEmpty)
              Text(order.shippingAddress!.phone,
                  style: const TextStyle(
                      color: AppColors.onSurfaceVariant, fontSize: 13)),
            const Gap(4),
            Text(
              order.shippingAddress!.fullAddress,
              style: const TextStyle(
                  color: AppColors.onSurfaceVariant, fontSize: 13, height: 1.5),
            ),
          ] else
            const Text('Alamat tidak tersedia.',
                style: TextStyle(color: AppColors.onSurfaceVariant)),
          if (order.trackingNumber != null) ...[
            const Gap(12),
            _buildTrackingBadge(order.trackingNumber!),
          ],
        ],
      ),
    );
  }

  Widget _buildTrackingBadge(String trackingNumber) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(PhosphorIconsRegular.truck,
              color: Color(0xFF92400E), size: 20),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nomor Resi',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Color(0xFF92400E))),
                Text(trackingNumber,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Color(0xFF78350F))),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(PhosphorIconsRegular.copy,
                size: 18, color: Color(0xFF92400E)),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: trackingNumber));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nomor resi disalin')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(OrderModel order) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(PhosphorIconsRegular.creditCard, size: 18),
              const Gap(8),
              const Text('Ringkasan Pembayaran',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
          const Gap(12),
          _paymentRow('Subtotal Produk', _formatCurrency(order.subtotal)),
          const Gap(6),
          _paymentRow('Biaya Pengiriman', _formatCurrency(order.shippingCost)),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Pembayaran',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              Text(
                _formatCurrency(order.totalAmount),
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.onSurfaceVariant, fontSize: 13)),
        Text(value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildActions(OrderModel order) {
    final buttons = <Widget>[];

    if (order.status == 'pending' && order.paymentUrl != null) {
      buttons.add(SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () => _openPayment(order.paymentUrl!),
          icon: const Icon(PhosphorIconsRegular.creditCard),
          label: const Text('Bayar Sekarang',
              style: TextStyle(fontWeight: FontWeight.w700)),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ));
    }

    if (order.status == 'processing' && order.refundRequestedAt == null) {
      buttons.add(const Gap(8));
      buttons.add(SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _showRefundDialog(order),
          icon: const Icon(PhosphorIconsRegular.arrowUDownLeft),
          label: const Text('Ajukan Pengembalian Dana',
              style: TextStyle(fontWeight: FontWeight.w700)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.outline),
            padding: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ));
    }

    if (order.refundRequestedAt != null && order.status != 'refunded') {
      buttons.add(const Gap(8));
      buttons.add(_buildRefundPendingBadge(order));
    }

    if (order.status == 'refunded') {
      buttons.add(const Gap(8));
      buttons.add(_buildRefundCompletedBadge());
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, children: buttons);
  }

  Widget _buildRefundPendingBadge(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(PhosphorIconsRegular.clock,
              color: Color(0xFF92400E), size: 18),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pengajuan Refund Diproses',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF92400E))),
                Text(
                  'Diajukan pada ${_formatDate(order.refundRequestedAt!)}',
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF78350F)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefundCompletedBadge() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        children: [
          const Icon(PhosphorIconsFill.checkCircle,
              color: Color(0xFF10B981), size: 18),
          const Gap(10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Refund Selesai',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF065F46))),
                Text('Dana telah dikembalikan ke metode pembayaran asal.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF047857))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPayment(String url) async {
    final orderNum = widget.orderNumber;
    final result = await Navigator.of(context).push<MidtransPaymentResult>(
      MaterialPageRoute(
        builder: (_) => MidtransPaymentScreen(
          paymentUrl: url,
          orderNumber: orderNum,
        ),
      ),
    );

    if (!mounted) return;

    if (result == MidtransPaymentResult.success) {
      context.go('/checkout/success?order=$orderNum');
    } else if (result == MidtransPaymentResult.pending) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Pembayaran menunggu konfirmasi. Pesanan Anda sedang diproses.'),
          backgroundColor: Color(0xFF92400E),
        ),
      );
      setState(() {});
    }
  }

  void _showRefundDialog(OrderModel order) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ajukan Pengembalian Dana',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Jelaskan alasan pengembalian dana...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Pengajuan refund dikirim. Menunggu konfirmasi admin.'),
                ),
              );
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: child,
    );
  }

  Map<String, dynamic> _statusConfig(String status) {
    switch (status) {
      case 'paid':
        return {
          'label': 'Lunas',
          'color': const Color(0xFF047857),
          'bg': const Color(0xFFECFDF5)
        };
      case 'processing':
        return {
          'label': 'Diproses',
          'color': const Color(0xFF1D4ED8),
          'bg': const Color(0xFFEFF6FF)
        };
      case 'shipped':
        return {
          'label': 'Dikirim',
          'color': const Color(0xFF7C3AED),
          'bg': const Color(0xFFF5F3FF)
        };
      case 'delivered':
        return {
          'label': 'Terkirim',
          'color': const Color(0xFF0F766E),
          'bg': const Color(0xFFF0FDFA)
        };
      case 'completed':
        return {
          'label': 'Selesai',
          'color': const Color(0xFF15803D),
          'bg': const Color(0xFFF0FDF4)
        };
      case 'pending':
        return {
          'label': 'Menunggu Pembayaran',
          'color': const Color(0xFFB45309),
          'bg': const Color(0xFFFFFBEB)
        };
      case 'refunded':
        return {
          'label': 'Dikembalikan',
          'color': const Color(0xFF475569),
          'bg': const Color(0xFFF8FAFC)
        };
      case 'cancelled':
        return {
          'label': 'Dibatalkan',
          'color': const Color(0xFFDC2626),
          'bg': const Color(0xFFFEF2F2)
        };
      default:
        return {
          'label': status,
          'color': AppColors.onSurfaceVariant,
          'bg': AppColors.surfaceContainerHighest
        };
    }
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  String _formatDate(DateTime date) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }
}
