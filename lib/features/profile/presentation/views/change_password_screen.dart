import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/features/profile/presentation/profile_view_model.dart';
import 'package:mitologi_clothing_mobile/widgets/shared/mitologi_sliver_app_bar.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<ProfileViewModel>();
    final success = await viewModel.changePassword(
      currentPassword: _currentController.text,
      newPassword: _newController.text,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Password berhasil diperbarui'
            : (viewModel.error ?? 'Gagal mengganti password')),
        backgroundColor: success ? AppColors.primary : AppColors.error,
      ),
    );
    if (success) {
      Navigator.of(context).pop();
    }
  }

  InputDecoration _decoration(String label,
      {required VoidCallback onToggle, required bool obscured}) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      suffixIcon: IconButton(
        icon: Icon(obscured ? Icons.visibility_off : Icons.visibility),
        onPressed: onToggle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, _) {
          return CustomScrollView(
            slivers: [
              const MitologiSliverAppBar(
                pageTitle: 'Ganti Password',
                showBackButton: true,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _currentController,
                          obscureText: _obscureCurrent,
                          decoration: _decoration(
                            'Password Saat Ini',
                            obscured: _obscureCurrent,
                            onToggle: () => setState(
                                () => _obscureCurrent = !_obscureCurrent),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Password saat ini wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _newController,
                          obscureText: _obscureNew,
                          decoration: _decoration(
                            'Password Baru',
                            obscured: _obscureNew,
                            onToggle: () =>
                                setState(() => _obscureNew = !_obscureNew),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Password baru wajib diisi';
                            }
                            if (v.length < 8) {
                              return 'Password minimal 8 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmController,
                          obscureText: _obscureConfirm,
                          decoration: _decoration(
                            'Konfirmasi Password Baru',
                            obscured: _obscureConfirm,
                            onToggle: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Konfirmasi password wajib diisi';
                            }
                            if (v != _newController.text) {
                              return 'Konfirmasi tidak sesuai';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 48,
                          child: FilledButton(
                            onPressed:
                                viewModel.isSaving ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            child: viewModel.isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Simpan Password Baru'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
