import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../utils/order_status.dart';
import '../../widgets/common/loading_indicator.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderNumber;

  const OrderDetailScreen({super.key, required this.orderNumber});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Order? _order;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetail();
  }

  Future<void> _fetchOrderDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final orderService = context.read<OrderService>();
      final order = await orderService.getOrderDetail(widget.orderNumber);

      setState(() {
        _order = order;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat detail pesanan: $e';
        _isLoading = false;
      });
    }
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
          'Detail Pesanan',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _error != null
              ? _buildErrorState()
              : _order == null
                  ? const Center(child: Text('Pesanan tidak ditemukan'))
                  : RefreshIndicator(
                      onRefresh: _fetchOrderDetail,
                      color: AppColors.primary,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatusCard(),
                            const SizedBox(height: 16),
                            _buildOrderInfoCard(),
                            const SizedBox(height: 16),
                            _buildProductsCard(currencyFormat),
                            const SizedBox(height: 16),
                            if (_order!.shippingAddress != null)
                              _buildAddressCard(),
                            const SizedBox(height: 16),
                            _buildPaymentCard(currencyFormat),
                            const SizedBox(height: 24),
                            _buildActionButtons(),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchOrderDetail,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final statusColor = _order!.status.statusColor;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          Icon(_order!.status.statusIcon, size: 48, color: statusColor),
          const SizedBox(height: 12),
          Text(
            _order!.displayStatus,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            _getStatusDescription(_order!.status),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getStatusDescription(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Silakan selesaikan pembayaran';
      case 'processing':
        return 'Pesanan sedang diproses';
      case 'shipped':
        return 'Pesanan dalam perjalanan';
      case 'completed':
        return 'Pesanan selesai. Terima kasih!';
      case 'cancelled':
        return 'Pesanan dibatalkan';
      default:
        return '';
    }
  }

  Widget _buildOrderInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Pesanan',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('No. Pesanan', _order!.orderNumber),
          if (_order!.createdAt != null)
            _buildInfoRow('Tanggal',
                DateFormat('dd MMM yyyy').format(_order!.createdAt!)),
          if (_order!.trackingNumber != null)
            _buildInfoRow('No. Resi', _order!.trackingNumber!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    )),
          ),
          Expanded(
            child: Text(value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    )),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsCard(NumberFormat currencyFormat) {
    final items = _order!.items ?? [];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Produk Dipesan',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => _buildProductItem(item, currencyFormat)),
        ],
      ),
    );
  }

  Widget _buildProductItem(OrderItem item, NumberFormat currencyFormat) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: item.imageUrl!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 80,
                      height: 80,
                      color: AppColors.background,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 80,
                      height: 80,
                      color: AppColors.background,
                      child: const Icon(Icons.image, color: AppColors.outline),
                    ),
                  )
                : Container(
                    width: 80,
                    height: 80,
                    color: AppColors.background,
                    child: const Icon(Icons.shopping_bag,
                        color: AppColors.outline),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.variantTitle != null)
                  Text(item.variantTitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          )),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.quantity}x ${item.price != null ? currencyFormat.format(item.price!.amount) : '-'}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    Text(
                      item.total != null
                          ? currencyFormat.format(item.total!.amount)
                          : '-',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
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

  Widget _buildAddressCard() {
    final address = _order!.shippingAddress!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Alamat Pengiriman',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(address.recipientName,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          Text(address.phone,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text(address.formattedAddress,
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(NumberFormat currencyFormat) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rincian Pembayaran',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildPriceRow(
              'Subtotal',
              _order!.subtotal != null
                  ? currencyFormat.format(_order!.subtotal!.amount)
                  : '-'),
          _buildPriceRow(
              'Ongkir',
              _order!.shipping != null
                  ? currencyFormat.format(_order!.shipping!.amount)
                  : '-'),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text(
                _order!.total != null
                    ? currencyFormat.format(_order!.total!.amount)
                    : '-',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.onSurfaceVariant)),
          Text(price,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_order!.status?.toLowerCase() == 'pending')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _payOrder,
              icon: const Icon(Icons.payment),
              label: const Text('Bayar Sekarang'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push('/cart'),
                icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                label: const Text('Beli Lagi'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push('/chatbot'),
                icon: const Icon(Icons.headset_mic_outlined, size: 18),
                label: const Text('Bantuan'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _payOrder() async {
    try {
      final orderService = context.read<OrderService>();
      final paymentInfo = await orderService.payOrder(widget.orderNumber);
      if (!mounted) return;

      // Use redirectUrl/paymentUrl (for bank transfer) or snapToken (for Midtrans web)
      final url = paymentInfo.redirectUrl ?? paymentInfo.paymentUrl;
      if (url != null && url.isNotEmpty) {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } else if (paymentInfo.snapToken != null && paymentInfo.snapToken!.isNotEmpty) {
        // For Midtrans Snap, open payment in external browser
        final snapUrl = 'https://app.midtrans.com/snap/v2/vtweb/${paymentInfo.snapToken}';
        final uri = Uri.parse(snapUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak dapat membuka halaman pembayaran'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    }
  }
}
