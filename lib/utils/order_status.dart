import 'package:flutter/material.dart';

/// Order status utilities for consistent display across the app
class OrderStatusUtils {
  static Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.indigo;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static IconData getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Icons.access_time;
      case 'processing':
        return Icons.inventory_2_outlined;
      case 'shipped':
        return Icons.local_shipping_outlined;
      case 'completed':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.shopping_bag_outlined;
    }
  }

  static String getStatusLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'processing':
        return 'Diproses';
      case 'shipped':
        return 'Dikirim';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status ?? 'Unknown';
    }
  }
}

/// Extension on String? for convenient order status access
extension OrderStatusExtension on String? {
  Color get statusColor => OrderStatusUtils.getStatusColor(this);
  IconData get statusIcon => OrderStatusUtils.getStatusIcon(this);
  String get statusLabel => OrderStatusUtils.getStatusLabel(this);
}
