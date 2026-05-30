import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/widgets/animated_snackbar.dart';
import 'package:mitologi_clothing_mobile/features/checkout/data/checkout_repository.dart';
import 'package:mitologi_clothing_mobile/features/checkout/data/shipping_service.dart';
import 'package:mitologi_clothing_mobile/features/checkout/domain/models/address_model.dart';
import 'package:mitologi_clothing_mobile/features/checkout/presentation/checkout_view_model.dart';
import 'package:mitologi_clothing_mobile/widgets/common/premium_back_button.dart';
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
        if (mounted) {
          AnimatedSnackbar.success(
            context,
            'Alamat "${address.label}" berhasil dihapus.',
            title: 'Berhasil',
          );
        }
      } catch (e) {
        if (mounted) {
          AnimatedSnackbar.error(
            context,
            'Gagal menghapus alamat: $e',
            title: 'Gagal',
          );
        }
      }
    }
  }

  Future<void> _setPrimaryAddress(AddressModel address) async {
    try {
      final updated = AddressModel(
        id: address.id,
        label: address.label,
        recipientName: address.recipientName,
        phone: address.phone,
        addressLine1: address.addressLine1,
        addressLine2: address.addressLine2,
        city: address.city,
        cityId: address.cityId,
        province: address.province,
        provinceId: address.provinceId,
        subdistrict: address.subdistrict,
        subdistrictId: address.subdistrictId,
        postalCode: address.postalCode,
        isDefault: true,
      );
      await context.read<CheckoutRepository>().updateAddress(updated);
      _fetchAddresses();
      if (mounted) {
        AnimatedSnackbar.success(
          context,
          'Alamat "${address.label}" sekarang menjadi alamat utama.',
          title: 'Berhasil',
        );
      }
    } catch (e) {
      if (mounted) {
        AnimatedSnackbar.error(
          context,
          'Gagal mengatur alamat utama: $e',
          title: 'Gagal',
        );
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
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leadingWidth: 64,
        leading: PremiumBackButton(onPressed: () => context.pop()),
        title: Text(
          'Alamat Pengiriman',
          style: AppTextStyles.plusJakartaSans(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: AppColors.primary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            height: 0.5,
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
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
              style: AppTextStyles.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const Gap(8),
            Text(
              'Tambahkan alamat pengiriman untuk memudahkan proses checkout.',
              textAlign: TextAlign.center,
              style: AppTextStyles.plusJakartaSans(
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
                    style: AppTextStyles.plusJakartaSans(
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
                    if (val == 'primary') _setPrimaryAddress(address);
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                    if (!address.isDefault)
                      const PopupMenuItem(value: 'primary', child: Text('Jadikan Utama')),
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
                    style: AppTextStyles.plusJakartaSans(
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
                    style: AppTextStyles.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            if (!address.isDefault)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: OutlinedButton.icon(
                  onPressed: () => _setPrimaryAddress(address),
                  icon: const Icon(PhosphorIconsRegular.star, size: 16),
                  label: const Text('Jadikan Alamat Utama'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                ),
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
  late TextEditingController _addressLine1Controller;
  late TextEditingController _addressLine2Controller;
  late TextEditingController _postalCodeController;

  ProvinceData? _selectedProvince;
  CityData? _selectedCity;
  SubdistrictData? _selectedSubdistrict;

  List<ProvinceData> _provinces = [];
  List<CityData> _cities = [];
  List<SubdistrictData> _subdistricts = [];

  bool _isLoadingLocations = false;
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    _labelController = TextEditingController(text: a?.label ?? '');
    _recipientNameController = TextEditingController(text: a?.recipientName ?? '');
    _phoneController = TextEditingController(text: a?.phone ?? '');
    _addressLine1Controller = TextEditingController(text: a?.addressLine1 ?? '');
    _addressLine2Controller = TextEditingController(text: a?.addressLine2 ?? '');
    _postalCodeController = TextEditingController(text: a?.postalCode ?? '');
    _isDefault = a?.isDefault ?? false;
    _loadProvinces();
  }

  @override
  void dispose() {
    _labelController.dispose();
    _recipientNameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadProvinces() async {
    try {
      final viewModel = context.read<CheckoutViewModel>();
      final provinces = await viewModel.shippingService.getProvinces();
      if (mounted) {
        setState(() => _provinces = provinces);
      }
    } catch (e) {
      if (mounted) {
        AnimatedSnackbar.show(
          context,
          message: 'Gagal memuat daftar provinsi: $e',
          type: SnackbarType.error,
        );
      }
    }
  }

  Future<void> _loadCities(int provinceId) async {
    setState(() {
      _isLoadingLocations = true;
      _cities = [];
      _selectedCity = null;
      _subdistricts = [];
      _selectedSubdistrict = null;
    });
    try {
      final viewModel = context.read<CheckoutViewModel>();
      final cities = await viewModel.shippingService.getCities(provinceId);
      if (mounted) {
        setState(() {
          _cities = cities;
          _isLoadingLocations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLocations = false);
        AnimatedSnackbar.show(
          context,
          message: 'Gagal memuat kota/kabupaten: $e',
          type: SnackbarType.error,
        );
      }
    }
  }

  Future<void> _loadSubdistricts(int cityId) async {
    setState(() {
      _isLoadingLocations = true;
      _subdistricts = [];
      _selectedSubdistrict = null;
    });
    try {
      final viewModel = context.read<CheckoutViewModel>();
      final subdistricts = await viewModel.shippingService.getSubdistricts(cityId);
      if (mounted) {
        setState(() {
          _subdistricts = subdistricts;
          _isLoadingLocations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLocations = false);
        AnimatedSnackbar.show(
          context,
          message: 'Gagal memuat kecamatan: $e',
          type: SnackbarType.error,
        );
      }
    }
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
        addressLine1: _addressLine1Controller.text.trim(),
        addressLine2: _addressLine2Controller.text.trim().isEmpty ? null : _addressLine2Controller.text.trim(),
        city: _selectedCity?.displayName ?? _selectedCity?.cityName ?? '',
        cityId: _selectedCity?.cityId ?? '',
        province: _selectedProvince?.province ?? '',
        provinceId: _selectedProvince?.provinceId ?? '',
        subdistrict: _selectedSubdistrict?.subdistrictName,
        subdistrictId: _selectedSubdistrict?.subdistrictId,
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
        AnimatedSnackbar.error(
          context,
          'Gagal menyimpan alamat: $e',
          title: 'Gagal',
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
                style: AppTextStyles.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800),
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
                controller: _addressLine1Controller,
                decoration: const InputDecoration(labelText: 'Alamat Lengkap', border: OutlineInputBorder()),
                maxLines: 2,
                validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
              ),
              const Gap(16),
              TextFormField(
                controller: _addressLine2Controller,
                decoration: const InputDecoration(labelText: 'Alamat Tambahan (Opsional)', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const Gap(16),
              _buildDropdown<ProvinceData>(
                label: 'Provinsi',
                hint: 'Pilih Provinsi',
                value: _selectedProvince,
                items: _provinces,
                itemLabel: (p) => p.province,
                onChanged: (province) {
                  setState(() {
                    _selectedProvince = province;
                    _selectedCity = null;
                    _selectedSubdistrict = null;
                    _cities = [];
                    _subdistricts = [];
                  });
                  if (province != null) {
                    _loadCities(int.parse(province.provinceId));
                  }
                },
                validator: (v) => v == null ? 'Wajib dipilih' : null,
              ),
              const Gap(16),
              _buildDropdown<CityData>(
                label: 'Kota / Kabupaten',
                hint: _selectedProvince == null ? 'Pilih provinsi terlebih dahulu' : 'Pilih Kota',
                value: _selectedCity,
                items: _cities,
                itemLabel: (c) => c.displayName,
                onChanged: _selectedProvince == null ? null : (city) {
                  setState(() {
                    _selectedCity = city;
                    _selectedSubdistrict = null;
                    _subdistricts = [];
                  });
                  if (city != null) {
                    _loadSubdistricts(int.parse(city.cityId));
                  }
                },
                validator: (v) => v == null ? 'Wajib dipilih' : null,
                enabled: _selectedProvince != null,
              ),
              const Gap(16),
              _buildDropdown<SubdistrictData>(
                label: 'Kecamatan (Opsional)',
                hint: _selectedCity == null ? 'Pilih kota terlebih dahulu' : 'Pilih Kecamatan',
                value: _selectedSubdistrict,
                items: _subdistricts,
                itemLabel: (s) => s.subdistrictName,
                onChanged: _selectedCity == null ? null : (subdistrict) {
                  setState(() => _selectedSubdistrict = subdistrict);
                },
                enabled: _selectedCity != null,
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

  Widget _buildDropdown<T>({
    required String label,
    required String hint,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?)? onChanged,
    String? Function(T?)? validator,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ),
        DropdownButtonFormField<T>(
          isExpanded: true,
          initialValue: value,
          hint: Text(hint, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabel(item), overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
          validator: validator,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            suffixIcon: _isLoadingLocations && (onChanged != null)
                ? const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
