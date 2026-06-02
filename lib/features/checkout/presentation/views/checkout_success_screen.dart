import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/features/checkout/data/checkout_repository.dart';
import 'package:mitologi_clothing_mobile/widgets/common/confetti_celebration.dart' as confetti;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class CheckoutSuccessScreen extends StatefulWidget {
  final String? orderNumber;

  const CheckoutSuccessScreen({super.key, this.orderNumber});

  @override
  State<CheckoutSuccessScreen> createState() => _CheckoutSuccessScreenState();
}

class _CheckoutSuccessScreenState extends State<CheckoutSuccessScreen> {
  bool _syncing = true;
  String _syncStatus = 'checking'; // checking, paid, pending
  bool _copied = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    if (widget.orderNumber != null) {
      _startPolling();
    } else {
      setState(() => _syncing = false);
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _startPolling() async {
    final orderNum = widget.orderNumber!;
    const paidStatuses = ['processing', 'paid', 'completed'];

    final repo = context.read<CheckoutRepository>();

    // Check immediately
    await _checkStatus(repo, orderNum, paidStatuses);

    // Poll every 3 seconds, max 10 attempts (30 seconds)
    int attempts = 0;
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      attempts++;
      if (attempts >= 10 || !mounted) {
        timer.cancel();
        if (mounted && _syncing) {
          setState(() {
            _syncStatus = 'pending';
            _syncing = false;
          });
        }
        return;
      }
      await _checkStatus(repo, orderNum, paidStatuses);
    });
  }

  Future<void> _checkStatus(
      CheckoutRepository repo, String orderNum, List<String> paidStatuses) async {
    try {
      final order = await repo.confirmPayment(orderNum);
      if (!mounted) return;
      if (order != null && paidStatuses.contains(order.status)) {
        setState(() {
          _syncStatus = 'paid';
          _syncing = false;
        });
        _pollTimer?.cancel();
        confetti.showConfetti(context);
      }
    } catch (_) {
      // Keep polling on error
    }
  }

  Future<void> _handleCopy() async {
    if (widget.orderNumber == null) return;
    await Clipboard.setData(ClipboardData(text: widget.orderNumber!));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Gap(32),
              _buildSuccessIcon(),
              const Gap(32),
              _buildTitle(context),
              const Gap(16),
              _buildSubtitle(context),
              if (_syncing || _syncStatus == 'paid') ...[
                const Gap(16),
                _buildSyncStatus(),
              ],
              if (widget.orderNumber != null) ...[
                const Gap(16),
                _buildOrderNumber(context),
              ],
              const Gap(48),
              _buildActions(context),
              const Gap(24),
              _buildEmailNote(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFBBF7D0), width: 4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: _syncStatus == 'paid'
          ? const Icon(
              PhosphorIconsFill.checkCircle,
              color: Color(0xFF10B981),
              size: 48,
            )
          : _syncing
              ? const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Color(0xFF10B981),
                  ),
                )
              : const Icon(
                  PhosphorIconsFill.checkCircle,
                  color: Color(0xFF10B981),
                  size: 48,
                ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'Pesanan Berhasil!',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(
      'Terima kasih telah berbelanja di Mitologi Clothing.\nPesanan Anda sedang diproses.',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.6,
          ),
    );
  }

  Widget _buildSyncStatus() {
    if (_syncing) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const Gap(8),
          Text(
            'Memeriksa status pembayaran...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ],
      );
    }

    if (_syncStatus == 'paid') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFF6EE7B7)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(PhosphorIconsFill.checkCircle,
                color: Color(0xFF059669), size: 18),
            const Gap(8),
            Text(
              'Pembayaran terkonfirmasi!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF047857),
                  ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.warningAmber.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(PhosphorIconsRegular.clock,
              color: AppColors.warningAmber, size: 18),
          const Gap(8),
          Text(
            'Menunggu konfirmasi pembayaran...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.warningAmber,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderNumber(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondaryContainer.withValues(alpha: 0.8), width: 1.5),
        boxShadow: [AppShadows.cardSoft],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Order ID',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
          ),
          const Gap(12),
          Flexible(
            child: Text(
              '#${widget.orderNumber}',
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.secondary,
                    fontSize: 15,
                  ),
            ),
          ),
          const Gap(8),
          InkWell(
            onTap: _handleCopy,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _copied
                    ? AppColors.successSoft
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                _copied
                    ? PhosphorIconsFill.checkCircle
                    : PhosphorIconsRegular.copy,
                size: 16,
                color: _copied
                    ? AppColors.successGreen
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              if (widget.orderNumber != null) {
                context.go('/orders/${widget.orderNumber}');
              } else {
                context.go('/profile');
              }
            },
            icon: const Icon(PhosphorIconsRegular.package),
            label: const Text(
              'Lihat Pesanan Saya',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const Gap(12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.go('/products'),
            icon: const Icon(PhosphorIconsRegular.shoppingBag),
            label: const Text(
              'Lanjut Belanja',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailNote(BuildContext context) {
    return Text(
      'Konfirmasi pesanan telah dikirim ke email Anda.',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
    );
  }
}
