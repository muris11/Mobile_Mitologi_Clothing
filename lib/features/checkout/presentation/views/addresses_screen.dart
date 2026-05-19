import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/features/checkout/data/checkout_repository.dart';
import 'package:mitologi_clothing_mobile/features/checkout/domain/models/address_model.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<AddressModel> _addresses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = context.read<CheckoutRepository>();
      final addresses = await repo.getAddresses();
      if (mounted) setState(() => _addresses = addresses);
    } catch (e) {
      if (mounted) setState(() => _error = _formatError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatError(Object error) {
    return error.toString().replaceFirst(RegExp(r'^Exception: '), '');
  }

  Future<void> _deleteAddress(AddressModel address) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Alamat?'),
        content: const Text('Apakah Anda yakin ingin menghapus alamat ini?'),
        actions: [
          TextButton(onPressed: () => ctx.pop(false), child: const Text('Batal')),
          FilledButton(
            onPressed: () => ctx.pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await context.read<CheckoutRepository>().deleteAddress(address.id);
        _fetchAddresses();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus alamat: $e')),
          );
        }
      }
    }
  }

  void _showAddressForm([AddressModel? address]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddressFormSheet(
        address: address,
        onSave: () {
          _fetchAddresses();
          ctx.pop();
        },
      ),
    );
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
          'Alamat Pengiriman',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.8),
          child: Container(height: 0.8, color: AppColors.outlineVariant),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _addresses.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: _fetchAddresses,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _addresses.length,
                        itemBuilder: (context, index) {
                          return _buildAddressCard(_addresses[index]);
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddressForm(),
        backgroundColor: AppColors.primary,
        child: const Icon(PhosphorIconsRegular.plus, color: Colors.white),
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
              onPressed: _fetchAddresses,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                PhosphorIconsRegular.mapPin,
                size: 40,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const Gap(24),
            Text(
              'Belum Ada Alamat',
              style: GoogleFonts.notoSerif(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const Gap(8),
            Text(
              'Tambahkan alamat pengiriman untuk memudahkan proses checkout.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const Gap(32),
            FilledButton.icon(
              onPressed: () => _showAddressForm(),
              icon: const Icon(PhosphorIconsRegular.plus),
              label: const Text('Tambah Alamat'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(AddressModel address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: address.isDefault
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.outlineVariant,
          width: address.isDefault ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    address.label,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Utama',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                const Gap(8),
                PopupMenuButton<String>(
                  icon: const Icon(PhosphorIconsRegular.dotsThree, size: 20),
                  onSelected: (val) {
                    if (val == 'edit') _showAddressForm(address);
                    if (val == 'delete') _deleteAddress(address);
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                  ],
                ),
              ],
            ),
            const Gap(8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(PhosphorIconsRegular.user,
                    size: 14, color: AppColors.onSurfaceVariant),
                const Gap(6),
                Expanded(
                  child: Text(
                    '${address.recipientName} · ${address.phone}',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(PhosphorIconsRegular.mapPin,
                    size: 14, color: AppColors.onSurfaceVariant),
                const Gap(6),
                Expanded(
                  child: Text(
                    address.fullAddress,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressFormSheet extends StatefulWidget {
  final AddressModel? address;
  final VoidCallback onSave;

  const _AddressFormSheet({this.address, required this.onSave});

  @override
  State<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<_AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  late TextEditingController _recipientNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _provinceController;
  late TextEditingController _postalCodeController;
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    _labelController = TextEditingController(text: a?.label);
    _recipientNameController = TextEditingController(text: a?.recipientName);
    _phoneController = TextEditingController(text: a?.phone);
    _addressController = TextEditingController(text: a?.address);
    _cityController = TextEditingController(text: a?.city);
    _provinceController = TextEditingController(text: a?.province);
    _postalCodeController = TextEditingController(text: a?.postalCode);
    _isDefault = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _recipientNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final repo = context.read<CheckoutRepository>();
      final address = AddressModel(
        id: widget.address?.id ?? 0,
        label: _labelController.text.trim(),
        recipientName: _recipientNameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        province: _provinceController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        isDefault: _isDefault,
      );

      if (widget.address == null) {
        await repo.addAddress(address);
      } else {
        await repo.updateAddress(address);
      }
      widget.onSave();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan alamat: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Gap(24),
              Text(
                widget.address == null ? 'Tambah Alamat' : 'Edit Alamat',
                style: GoogleFonts.notoSerif(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const Gap(24),
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(labelText: 'Label Alamat (Rumah/Kantor)', border: OutlineInputBorder()),
                validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
              ),
              const Gap(16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _recipientNameController,
                      decoration: const InputDecoration(labelText: 'Nama Penerima', border: OutlineInputBorder()),
                      validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'No. Telepon', border: OutlineInputBorder()),
                      keyboardType: TextInputType.phone,
                      validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
                    ),
                  ),
                ],
              ),
              const Gap(16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Alamat Lengkap', border: OutlineInputBorder()),
                maxLines: 2,
                validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
              ),
              const Gap(16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: 'Kota', border: OutlineInputBorder()),
                      validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: TextFormField(
                      controller: _provinceController,
                      decoration: const InputDecoration(labelText: 'Provinsi', border: OutlineInputBorder()),
                      validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
                    ),
                  ),
                ],
              ),
              const Gap(16),
              TextFormField(
                controller: _postalCodeController,
                decoration: const InputDecoration(labelText: 'Kode Pos', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
              ),
              const Gap(16),
              SwitchListTile(
                title: const Text('Jadikan Alamat Utama'),
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v),
                contentPadding: EdgeInsets.zero,
              ),
              const Gap(24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Simpan Alamat'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
