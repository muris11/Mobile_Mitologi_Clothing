import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum MidtransPaymentResult { success, pending, failed, cancelled }

class MidtransPaymentScreen extends StatefulWidget {
  final String paymentUrl;
  final String orderNumber;

  const MidtransPaymentScreen({
    super.key,
    required this.paymentUrl,
    required this.orderNumber,
  });

  @override
  State<MidtransPaymentScreen> createState() => _MidtransPaymentScreenState();
}

class _MidtransPaymentScreenState extends State<MidtransPaymentScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  bool _finished = false;
  int _loadingProgress = 0;

  static const _midtransHosts = [
    'midtrans.com',
    'veritrans.co.id',
  ];

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _loadingProgress = progress);
          },
          onPageStarted: (url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            if (mounted) setState(() => _isLoading = false);
            _injectPaymentDetector(url);
          },
          onWebResourceError: (error) {
            if (mounted) setState(() => _hasError = true);
            final errUrl = error.url;
            if (errUrl != null && _isMidtransUrl(errUrl)) {
              _detectFromUrl(errUrl);
            }
          },
          onNavigationRequest: (request) {
            if (!_isMidtransUrl(request.url)) {
              _detectFromUrl(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  bool _isMidtransUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    final host = uri.host.toLowerCase();
    return _midtransHosts.any((h) => host.contains(h));
  }

  void _detectFromUrl(String url) {
    if (_finished) return;
    final lower = url.toLowerCase();

    if (lower.contains('/callback/success') ||
        lower.contains('transaction_status=settlement') ||
        lower.contains('transaction_status=capture') ||
        lower.contains('status_code=200') ||
        lower.contains('/finish/success') ||
        lower.contains('?success')) {
      _handleResult(MidtransPaymentResult.success);
      return;
    }
    if (lower.contains('/callback/failed') ||
        lower.contains('transaction_status=deny') ||
        lower.contains('transaction_status=cancel') ||
        lower.contains('transaction_status=expire') ||
        lower.contains('status_code=202') ||
        lower.contains('/error')) {
      _handleResult(MidtransPaymentResult.failed);
      return;
    }
    if (lower.contains('/callback/pending') ||
        lower.contains('transaction_status=pending') ||
        lower.contains('status_code=201') ||
        lower.contains('/finish/pending')) {
      _handleResult(MidtransPaymentResult.pending);
      return;
    }

    _handleResult(MidtransPaymentResult.pending);
  }

  void _injectPaymentDetector(String url) {
    _controller.runJavaScript('''
(function() {
  if (window.__mtMonitored) return;
  window.__mtMonitored = true;

  setInterval(function() {
    var u = (window.location.href || '').toLowerCase();
    var status = '';

    if (u.indexOf('status_code=200') > -1 ||
        u.indexOf('transaction_status=settlement') > -1 ||
        u.indexOf('transaction_status=capture') > -1) {
      status = 'success';
    } else if (u.indexOf('status_code=202') > -1 ||
        u.indexOf('transaction_status=deny') > -1 ||
        u.indexOf('transaction_status=expire') > -1 ||
        u.indexOf('transaction_status=cancel') > -1) {
      status = 'failed';
    }

    if (!status) {
      var body = document.body ? document.body.innerText.toLowerCase() : '';
      if (body.indexOf('berhasil') > -1 || body.indexOf('selamat') > -1) {
        status = 'success';
      } else if (body.indexOf('gagal') > -1 ||
          body.indexOf('ditolak') > -1 ||
          body.indexOf('denied') > -1) {
        status = 'failed';
      }
    }

    if (status) {
      window.location.href = 'https://payment-done.app/callback/' + status;
    }
  }, 500);
})();
''');
  }

  void _handleResult(MidtransPaymentResult result) {
    if (_finished) return;
    _finished = true;

    Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      Navigator.of(context).pop(result);
    });
  }

  Future<bool> _onWillPop() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Batalkan Pembayaran?',
          style: GoogleFonts.notoSerif(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Pesanan tetap tersimpan. Kamu bisa melanjutkan pembayaran nanti dari halaman Detail Pesanan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Lanjutkan Bayar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      Navigator.of(context).pop(MidtransPaymentResult.cancelled);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _onWillPop();
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(PhosphorIconsRegular.x, size: 20),
              onPressed: () => _onWillPop(),
              tooltip: 'Tutup',
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pembayaran',
                  style: GoogleFonts.notoSerif(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '#${widget.orderNumber}',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF6EE7B7), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(PhosphorIconsRegular.lockKey,
                        size: 12, color: Color(0xFF059669)),
                    const SizedBox(width: 4),
                    Text(
                      'Aman',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(3),
              child: _isLoading
                  ? LinearProgressIndicator(
                      value: _loadingProgress / 100,
                      backgroundColor:
                          AppColors.outlineVariant.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.secondary),
                      minHeight: 3,
                    )
                  : const SizedBox(height: 3),
            ),
          ),
          body: _hasError ? _buildErrorState() : _buildWebView(),
          bottomNavigationBar: _buildBottomBar(),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    if (_hasError) return const SizedBox.shrink();
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _handleResult(MidtransPaymentResult.pending),
            icon: const Icon(PhosphorIconsRegular.arrowLeft, size: 18),
            label: Text(
              'Kembali ke Aplikasi',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebView() {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading && _loadingProgress < 30)
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2.5,
                ),
                SizedBox(height: 16),
                Text(
                  'Memuat halaman pembayaran...',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                PhosphorIconsRegular.wifiSlash,
                size: 36,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Gagal Memuat Halaman',
              style: GoogleFonts.notoSerif(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Periksa koneksi internet kamu dan coba lagi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                  _loadingProgress = 0;
                  _finished = false;
                });
                _initWebView();
              },
              icon: const Icon(PhosphorIconsRegular.arrowClockwise, size: 18),
              label: const Text('Coba Lagi',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
