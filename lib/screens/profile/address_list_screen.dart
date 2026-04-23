import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/address.dart';
import '../../services/profile_service.dart';
import '../../widgets/common/loading_indicator.dart';

class AddressListScreen extends StatefulWidget {
  final bool isSelectionMode;

  const AddressListScreen({super.key, this.isSelectionMode = false});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  List<Address> _addresses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final profileService = context.read<ProfileService>();
      final addresses = await profileService.getAddresses();

      setState(() {
        _addresses = addresses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat alamat: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAddress(int? id) async {
    if (id == null) return;

    try {
      setState(() => _isLoading = true);
      final profileService = context.read<ProfileService>();
      await profileService.deleteAddress(id);
      await _fetchAddresses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alamat berhasil dihapus')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text('Alamat Saya',
            style: Theme.of(context).textTheme.headlineSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _error != null
              ? _buildErrorState()
              : _addresses.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _fetchAddresses,
                      color: AppColors.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _addresses.length,
                        itemBuilder: (context, index) {
                          final address = _addresses[index];
                          return _buildAddressCard(address);
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddressForm,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
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
            onPressed: _fetchAddresses,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined,
              size: 80, color: AppColors.outline.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('Belum ada alamat',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Tambahkan alamat pengiriman Anda',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddressForm,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Alamat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Address address) {
    final isDefault = address.isDefault;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDefault ? AppColors.primary : AppColors.outline,
          width: isDefault ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: widget.isSelectionMode ? () => context.pop(address) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 20,
                        color: isDefault
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        address.label ?? 'Alamat',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Utama',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteConfirmation(address);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 18),
                            SizedBox(width: 8),
                            Text('Hapus', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                address.recipientName,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                address.phone,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Text(
                address.formattedAddress,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Address address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Alamat'),
        content: Text('Hapus "${address.label ?? address.formattedAddress}"?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              _deleteAddress(address.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showAddressForm([Address? address]) {
    final isEdit = address != null;
    final labelController = TextEditingController(text: address?.label ?? '');
    final recipientController =
        TextEditingController(text: address?.recipientName ?? '');
    final phoneController = TextEditingController(text: address?.phone ?? '');
    final addressController =
        TextEditingController(text: address?.address ?? '');
    final cityController = TextEditingController(text: address?.city ?? '');
    final postalController =
        TextEditingController(text: address?.postalCode ?? '');
    bool isPrimary = address?.isDefault ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isEdit ? 'Edit Alamat' : 'Tambah Alamat',
                  style: GoogleFonts.manrope(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: labelController,
                  decoration: InputDecoration(
                    labelText: 'Label Alamat (Rumah/Kantor)',
                    filled: true,
                    fillColor: AppColors.surfaceContainerLowest,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: recipientController,
                  decoration: InputDecoration(
                    labelText: 'Nama Penerima',
                    filled: true,
                    fillColor: AppColors.surfaceContainerLowest,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Nomor Telepon',
                    filled: true,
                    fillColor: AppColors.surfaceContainerLowest,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Alamat Lengkap',
                    filled: true,
                    fillColor: AppColors.surfaceContainerLowest,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: cityController,
                        decoration: InputDecoration(
                          labelText: 'Kota',
                          filled: true,
                          fillColor: AppColors.surfaceContainerLowest,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: postalController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Kode Pos',
                          filled: true,
                          fillColor: AppColors.surfaceContainerLowest,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Jadikan Alamat Utama',
                      style: GoogleFonts.manrope()),
                  value: isPrimary,
                  onChanged: (value) => setSheetState(() => isPrimary = value),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);
                      final profileService = context.read<ProfileService>();
                      final label = labelController.text.trim();
                      final recipientName = recipientController.text.trim();
                      final phone = phoneController.text.trim();
                      final fullAddress = addressController.text.trim();
                      final city = cityController.text.trim();
                      final postalCode = postalController.text.trim();

                      if (label.isEmpty ||
                          recipientName.isEmpty ||
                          phone.isEmpty ||
                          fullAddress.isEmpty ||
                          city.isEmpty ||
                          postalCode.isEmpty) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Mohon lengkapi semua field'),
                          ),
                        );
                        return;
                      }

                      try {
                        if (isEdit && address.id != null) {
                          await profileService.updateAddress(
                            address.id!,
                            label: label,
                            recipientName: recipientName,
                            phone: phone,
                            address: fullAddress,
                            city: city,
                            postalCode: postalCode,
                            isDefault: isPrimary,
                          );
                        } else {
                          await profileService.addAddress(
                            label: label,
                            recipientName: recipientName,
                            phone: phone,
                            address: fullAddress,
                            city: city,
                            postalCode: postalCode,
                            isDefault: isPrimary,
                          );
                        }

                        if (!mounted) return;
                        navigator.pop();
                        _fetchAddresses();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              isEdit
                                  ? 'Alamat berhasil diperbarui'
                                  : 'Alamat berhasil ditambahkan',
                            ),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(content: Text('Gagal menyimpan: $e')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      isEdit ? 'Simpan Perubahan' : 'Tambah Alamat',
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
