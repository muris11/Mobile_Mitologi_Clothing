import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';
import 'package:mitologi_clothing_mobile/features/checkout/data/shipping_service.dart';
import 'package:mitologi_clothing_mobile/features/checkout/domain/models/address_model.dart';
import 'package:mitologi_clothing_mobile/core/widgets/animated_snackbar.dart';
import 'package:mitologi_clothing_mobile/features/checkout/presentation/checkout_view_model.dart';
import 'package:mitologi_clothing_mobile/widgets/common/premium_back_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:mitologi_clothing_mobile/core/widgets/luxury_button.dart';
import 'package:mitologi_clothing_mobile/core/widgets/premium_section_header.dart';

class ManageAddressScreen extends StatefulWidget {
  final AddressModel? address;

  const ManageAddressScreen({super.key, this.address});

  @override
  State<ManageAddressScreen> createState() => _ManageAddressScreenState();
}

class _ManageAddressScreenState extends State<ManageAddressScreen> {
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

  bool get _isEditing => widget.address != null;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.address?.label ?? '');
    _recipientNameController = TextEditingController(text: widget.address?.recipientName ?? '');
    _phoneController = TextEditingController(text: widget.address?.phone ?? '');
    _addressLine1Controller = TextEditingController(text: widget.address?.addressLine1 ?? '');
    _addressLine2Controller = TextEditingController(text: widget.address?.addressLine2 ?? '');
    _postalCodeController = TextEditingController(text: widget.address?.postalCode ?? '');
    _isDefault = widget.address?.isDefault ?? false;
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
      // Silently fail, user can still type manually
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
      if (mounted) setState(() => _isLoadingLocations = false);
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
      if (mounted) setState(() => _isLoadingLocations = false);
    }
  }

  void _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      final viewModel = context.read<CheckoutViewModel>();
      
      final address = AddressModel(
        id: widget.address?.id ?? 0,
        label: _labelController.text.trim(),
        recipientName: _recipientNameController.text.trim(),
        phone: _phoneController.text.trim(),
        addressLine1: _addressLine1Controller.text.trim(),
        addressLine2: _addressLine2Controller.text.trim().isEmpty ? null : _addressLine2Controller.text.trim(),
        city: _selectedCity?.displayName ?? '',
        cityId: _selectedCity?.cityId ?? '',
        province: _selectedProvince?.province ?? '',
        provinceId: _selectedProvince?.provinceId ?? '',
        subdistrict: _selectedSubdistrict?.subdistrictName,
        subdistrictId: _selectedSubdistrict?.subdistrictId,
        postalCode: _postalCodeController.text.trim(),
        isDefault: _isDefault,
      );

      final success = _isEditing
          ? await viewModel.updateAddress(address)
          : await viewModel.addAddress(address);

      if (success && mounted) {
        Navigator.of(context).pop();
        AnimatedSnackbar.success(
          context,
          _isEditing
              ? 'Alamat "${address.label}" berhasil diperbarui.'
              : 'Alamat "${address.label}" berhasil ditambahkan.',
          title: 'Berhasil',
        );
      } else if (mounted) {
        AnimatedSnackbar.error(
          context,
          viewModel.error ?? 'Gagal menyimpan alamat',
          title: 'Gagal',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CheckoutViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            automaticallyImplyLeading: false,
            leadingWidth: 64,
            leading: PremiumBackButton(onPressed: () => Navigator.of(context).pop()),
            title: Text(
              _isEditing ? 'Edit Alamat' : 'Tambah Alamat',
              style: AppTextStyles.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w900,
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
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PremiumSectionHeader(
                      eyebrow: 'Contact Info',
                      title: 'Informasi Penerima',
                      subtitle: 'Siapa yang akan menerima paket fashion dari Mitologi?',
                      padding: EdgeInsets.zero,
                    ),
                    const Gap(24),
                    _buildTextField(
                      controller: _recipientNameController,
                      label: 'NAMA PENERIMA',
                      hint: 'Contoh: Budi Santoso',
                      validator: (v) => v?.isEmpty ?? true ? 'Nama wajib diisi' : null,
                    ),
                    const Gap(20),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'NOMOR TELEPON',
                      hint: 'Contoh: 08123456789',
                      keyboardType: TextInputType.phone,
                      validator: (v) => v?.isEmpty ?? true ? 'Nomor telepon wajib diisi' : null,
                    ),
                    const Gap(40),
                    const PremiumSectionHeader(
                      eyebrow: 'Location',
                      title: 'Detail Lokasi',
                      subtitle: 'Pastikan alamat lengkap agar kurir dapat menemukanmu.',
                      padding: EdgeInsets.zero,
                    ),
                    const Gap(24),
                    _buildTextField(
                      controller: _labelController,
                      label: 'LABEL ALAMAT',
                      hint: 'Contoh: Rumah, Kantor, Kost',
                      validator: (v) => v?.isEmpty ?? true ? 'Label wajib diisi' : null,
                    ),
                    const Gap(20),
                    _buildTextField(
                      controller: _addressLine1Controller,
                      label: 'ALAMAT LENGKAP',
                      hint: 'Nama jalan, No. Rumah, Blok, dll.',
                      maxLines: 3,
                      validator: (v) => v?.isEmpty ?? true ? 'Alamat wajib diisi' : null,
                    ),
                    const Gap(20),
                    _buildTextField(
                      controller: _addressLine2Controller,
                      label: 'ALAMAT TAMBAHAN (Opsional)',
                      hint: 'Gedung, Lantai, Patokan, dll.',
                      maxLines: 2,
                    ),
                    const Gap(20),
                    _buildDropdown<ProvinceData>(
                      label: 'PROVINSI',
                      hint: 'Pilih Provinsi',
                      value: _selectedProvince,
                      items: _provinces,
                      itemLabel: (ProvinceData p) => p.province,
                      onChanged: (ProvinceData? province) {
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
                      validator: (ProvinceData? v) => v == null ? 'Provinsi wajib dipilih' : null,
                    ),
                    const Gap(20),
                    _buildDropdown<CityData>(
                      label: 'KOTA / KABUPATEN',
                      hint: _selectedProvince == null ? 'Pilih provinsi terlebih dahulu' : 'Pilih Kota',
                      value: _selectedCity,
                      items: _cities,
                      itemLabel: (CityData c) => c.displayName,
                      onChanged: _selectedProvince == null ? null : (CityData? city) {
                        setState(() {
                          _selectedCity = city;
                          _selectedSubdistrict = null;
                          _subdistricts = [];
                        });
                        if (city != null) {
                          _loadSubdistricts(int.parse(city.cityId));
                        }
                      },
                      validator: (CityData? v) => v == null ? 'Kota wajib dipilih' : null,
                      enabled: _selectedProvince != null,
                    ),
                    const Gap(20),
                    _buildDropdown<SubdistrictData>(
                      label: 'KECAMATAN',
                      hint: _selectedCity == null ? 'Pilih kota terlebih dahulu' : 'Pilih Kecamatan',
                      value: _selectedSubdistrict,
                      items: _subdistricts,
                      itemLabel: (SubdistrictData s) => s.subdistrictName,
                      onChanged: _selectedCity == null ? null : (SubdistrictData? subdistrict) {
                        setState(() => _selectedSubdistrict = subdistrict);
                      },
                      enabled: _selectedCity != null,
                    ),
                    const Gap(20),
                    _buildTextField(
                      controller: _postalCodeController,
                      label: 'KODE POS',
                      hint: '45271',
                      keyboardType: TextInputType.number,
                      validator: (v) => v?.isEmpty ?? true ? 'Kode pos wajib diisi' : null,
                    ),
                    const Gap(32),
                    SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      title: Text(
                        'Atur sebagai alamat utama',
                        style: AppTextStyles.manrope(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primary),
                      ),
                      value: _isDefault,
                      onChanged: (v) => setState(() => _isDefault = v),
                      activeThumbColor: AppColors.primary,
                      activeTrackColor: AppColors.secondarySoft,
                    ),
                    const Gap(48),
                    LuxuryButton(
                      onPressed: viewModel.isLoading ? null : _handleSave,
                      label: viewModel.isLoading ? 'Menyimpan...' : 'Simpan Alamat',
                      icon: PhosphorIconsRegular.floppyDisk,
                      isLoading: viewModel.isLoading,
                      expand: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            label,
            style: AppTextStyles.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.secondary,
              letterSpacing: 1.8,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTextStyles.manrope(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
          decoration: InputDecoration(
            hintText: hint,
          ),
        ),
      ],
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
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            label,
            style: AppTextStyles.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.secondary,
              letterSpacing: 1.8,
            ),
          ),
        ),
        DropdownButtonFormField<T>(
          initialValue: value,
          hint: Text(hint, style: AppTextStyles.manrope(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.secondary)),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabel(item), style: AppTextStyles.manrope(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
          validator: validator,
          decoration: InputDecoration(
            suffixIcon: _isLoadingLocations && (onChanged != null)
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : null,
          ),
          style: AppTextStyles.manrope(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
        ),
      ],
    );
  }
}
