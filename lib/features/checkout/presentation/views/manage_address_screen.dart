import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';
import 'package:mitologi_clothing_mobile/features/checkout/domain/models/address_model.dart';
import 'package:mitologi_clothing_mobile/features/checkout/presentation/checkout_view_model.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:mitologi_clothing_mobile/core/widgets/glass_container.dart';
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
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _provinceController;
  late TextEditingController _postalCodeController;
  bool _isDefault = false;

  bool get _isEditing => widget.address != null;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.address?.label ?? '');
    _recipientNameController = TextEditingController(text: widget.address?.recipientName ?? '');
    _phoneController = TextEditingController(text: widget.address?.phone ?? '');
    _addressController = TextEditingController(text: widget.address?.address ?? '');
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _provinceController = TextEditingController(text: widget.address?.province ?? '');
    _postalCodeController = TextEditingController(text: widget.address?.postalCode ?? '');
    _isDefault = widget.address?.isDefault ?? false;
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

  void _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      final viewModel = context.read<CheckoutViewModel>();
      
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

      final success = _isEditing
          ? await viewModel.updateAddress(address)
          : await viewModel.addAddress(address);

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? 'Alamat diperbarui' : 'Alamat ditambahkan')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.error ?? 'Gagal menyimpan alamat'), backgroundColor: AppColors.error),
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
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GlassContainer(
                padding: EdgeInsets.zero,
                blur: 12,
                borderRadius: AppBorderRadius.circular,
                child: IconButton(
                  icon: const Icon(PhosphorIconsRegular.arrowLeft, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            title: Text(
              _isEditing ? 'Edit Alamat' : 'Tambah Alamat',
              style: AppTextStyles.notoSerif(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
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
                      controller: _addressController,
                      label: 'ALAMAT LENGKAP',
                      hint: 'Nama jalan, No. Rumah, Blok, dll.',
                      maxLines: 3,
                      validator: (v) => v?.isEmpty ?? true ? 'Alamat wajib diisi' : null,
                    ),
                    const Gap(20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _cityController,
                            label: 'KOTA',
                            hint: 'Indramayu',
                            validator: (v) => v?.isEmpty ?? true ? 'Kota wajib diisi' : null,
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: _buildTextField(
                            controller: _provinceController,
                            label: 'PROVINSI',
                            hint: 'Jawa Barat',
                            validator: (v) => v?.isEmpty ?? true ? 'Provinsi wajib diisi' : null,
                          ),
                        ),
                      ],
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
}
