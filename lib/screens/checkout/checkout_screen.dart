import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/shop_config.dart';
import '../../config/theme.dart';
import '../../models/address.dart';
import '../../models/shipping_rate.dart';
import '../../providers/cart_provider.dart';
import '../../services/order_service.dart';
import '../../services/profile_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  List<Address> _addresses = [];
  Address? _selectedAddress;
  ShippingRate? _shippingRate;
  final String _paymentMethod = 'midtrans';
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadData();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Capture providers before async operations
      final cartProvider = context.read<CartProvider>();
      final profileService = context.read<ProfileService>();
      final orderService = context.read<OrderService>();

      // Load cart
      await cartProvider.ensureInitialized();

      // Load addresses
      final addresses = await profileService.getAddresses();

      if (!mounted) return;

      Address? selectedAddress;
      if (addresses.isNotEmpty) {
        selectedAddress = addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => addresses.first,
        );
      }

      // Get shipping rates from API based on selected address
      ShippingRate? shippingRate;
      if (selectedAddress != null && selectedAddress.id != null) {
        try {
          final rates =
              await orderService.getShippingRates(selectedAddress.id!);
          if (rates.isNotEmpty) {
            // Use the first available shipping rate
            shippingRate = rates.first;
          } else {
            // Fallback to flat rate if no rates from API
            shippingRate = ShippingRate(
              cost: ShopConfig.flatShippingCost,
              method: 'Flat Rate',
            );
          }
        } catch (e) {
          // Fallback to flat rate if API fails
          shippingRate = ShippingRate(
            cost: ShopConfig.flatShippingCost,
            method: 'Flat Rate',
          );
        }
      }

      if (!mounted) return;

      setState(() {
        _addresses = addresses;
        _selectedAddress = selectedAddress;
        _shippingRate = shippingRate;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Gagal memuat data checkout. Silakan coba lagi.';
      });
    }
  }

  Future<void> _processCheckout() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pilih alamat pengiriman terlebih dahulu',
            style: GoogleFonts.manrope(),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final cartProvider = context.read<CartProvider>();
      final orderService = context.read<OrderService>();

      final result = await orderService.checkout(
        cartId: cartProvider.cart?.id ?? '',
        addressId: _selectedAddress!.id!,
        shippingCost: _shippingRate?.cost ?? ShopConfig.flatShippingCost,
        paymentMethod: _paymentMethod,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (mounted) {
        if (result.snapToken != null) {
          // Show Midtrans payment
          _showMidtransPayment(result.snapToken!);
        } else {
          // Go to order confirmation
          context.push('/orders/${result.orderNumber}');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Checkout gagal: $e',
              style: GoogleFonts.manrope(),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _updateShippingForAddress(Address address) async {
    setState(() => _selectedAddress = address);

    if (address.id == null) {
      Navigator.pop(context);
      return;
    }

    // Show loading for shipping calculation
    setState(() {
      _shippingRate = null;
    });

    try {
      final orderService = context.read<OrderService>();

      try {
        final rates = await orderService.getShippingRates(address.id!);
        if (rates.isNotEmpty && mounted) {
          setState(() {
            _shippingRate = rates.first;
          });
        } else if (mounted) {
          // Fallback to flat rate if no rates
          setState(() {
            _shippingRate = ShippingRate(
              cost: ShopConfig.flatShippingCost,
              method: 'Flat Rate',
            );
          });
        }
      } catch (e) {
        // Fallback to flat rate if API fails
        if (mounted) {
          setState(() {
            _shippingRate = ShippingRate(
              cost: ShopConfig.flatShippingCost,
              method: 'Flat Rate',
            );
          });
        }
      }
    } finally {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _showMidtransPayment(String paymentUrl) async {
    final uri = Uri.parse(paymentUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat membuka halaman pembayaran'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: AnimatedEmptyState(
            icon: Icons.error_outline,
            title: 'Gagal Memuat Checkout',
            subtitle: _loadError!,
            actionLabel: 'Coba Lagi',
            onAction: () {
              setState(() => _loadError = null);
              _loadData();
            },
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                pinned: true,
                elevation: 0,
                backgroundColor: AppColors.surface.withValues(alpha: 0.95),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  'Checkout',
                  style: GoogleFonts.notoSerif(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                centerTitle: true,
              ),

              // Title Section
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),

              // Address Section
              SliverToBoxAdapter(
                child: _buildAddressSection(),
              ),

              // Notes Section
              SliverToBoxAdapter(
                child: _buildNotesSection(),
              ),

              // Order Summary Section
              SliverToBoxAdapter(
                child: _buildSummarySection(),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 120),
              ),
            ],
          ),

          // Sticky CTA
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildCheckoutCTA(),
          ),

          // Loading overlay
          if (_isProcessing)
            Container(
              color: Colors.black.withAlpha(100),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Checkout',
            style: GoogleFonts.notoSerif(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pilih alamat untuk pengiriman pesanan',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w300,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alamat Pengiriman',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                  letterSpacing: 2,
                ),
              ),
              if (_addresses.isNotEmpty)
                TextButton(
                  onPressed: () {
                    context.push('/profile/addresses');
                  },
                  child: Text(
                    'Kelola Alamat',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_addresses.isNotEmpty) ...[
            Text(
              'Pilih alamat untuk pengiriman pesanan',
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            ..._addresses.map((address) {
              final isSelected = _selectedAddress?.id == address.id;
              return GestureDetector(
                onTap: () => _updateShippingForAddress(address),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.surfaceContainer
                        : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.secondary
                          : AppColors.outlineVariant,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              address.label?.isNotEmpty == true
                                  ? address.label!
                                  : 'Alamat',
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          if (address.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Utama',
                                style: GoogleFonts.manrope(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${address.recipientName} • ${address.phone}',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${address.city}, ${address.city}${address.postalCode.isNotEmpty ? ' ${address.postalCode}' : ''}',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Dipilih',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
            if (_selectedAddress != null) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alamat yang dipilih',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_selectedAddress!.recipientName} • ${_selectedAddress!.phone}',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_selectedAddress!.city}, ${_selectedAddress!.city}',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ] else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.outlineVariant,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.location_off,
                    color: AppColors.outline,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada alamat tersimpan',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.push('/profile/addresses');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                    ),
                    child: Text(
                      'Tambah Alamat',
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Catatan'.toUpperCase(),
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _notesController,
              maxLines: 3,
              style: GoogleFonts.manrope(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Tambah catatan untuk penjual...',
                hintStyle: GoogleFonts.manrope(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant.withAlpha(150),
                  fontWeight: FontWeight.w300,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(20),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Icon(
                    Icons.edit_note,
                    color: AppColors.onSurfaceVariant.withAlpha(100),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final cart = cartProvider.cart;
        final subtotal = cart?.subtotal?.amount ?? 0;
        final shippingCost = _shippingRate?.cost ?? ShopConfig.flatShippingCost;
        final total = subtotal + shippingCost;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ringkasan Pesanan',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (cart != null && cart.items.isNotEmpty) ...[
                      ...cart.items.map((item) {
                        final itemTitle = item.product?.title ??
                            item.variant?.title ??
                            'Produk';
                        final variantTitle = item.variant?.title ?? '';
                        final itemCost = item.cost?.formatted ?? 'Rp 0';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                itemTitle,
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item.quantity}${variantTitle.isNotEmpty ? ' • $variantTitle' : ''}',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                itemCost,
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1),
                      ),
                    ],
                    _buildSummaryRow(
                        'Subtotal', 'Rp ${subtotal.toStringAsFixed(0)}'),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      'Pengiriman',
                      (_shippingRate?.cost.amount ?? 0) > 0
                          ? 'Rp ${_shippingRate!.cost.amount!.toStringAsFixed(0)}'
                          : 'Gratis Ongkir',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Bayar',
                          style: GoogleFonts.notoSerif(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'Rp ${total.toStringAsFixed(0)}',
                          style: GoogleFonts.notoSerif(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutCTA() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background.withAlpha(0),
            AppColors.background.withAlpha(240),
          ],
        ),
      ),
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(60),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _processCheckout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Lanjut ke Pembayaran',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
