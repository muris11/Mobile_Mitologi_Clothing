import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/widgets/app_button.dart';
import 'package:mitologi_clothing_mobile/core/widgets/animated_snackbar.dart';
import 'package:mitologi_clothing_mobile/features/auth/presentation/auth_view_model.dart';
import 'auth_scaffold.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscurePasswordConfirmation = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_passwordController.text != _passwordConfirmationController.text) {
        AnimatedSnackbar.error(
          context,
          'Konfirmasi password tidak cocok.',
          title: 'Validasi Gagal',
        );
        return;
      }

      final viewModel = context.read<AuthViewModel>();
      final success = await viewModel.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
      );
      if (success && mounted) {
        AnimatedSnackbar.success(
          context,
          'Akun berhasil dibuat. Silakan login dengan akun baru Anda.',
          title: 'Registrasi Berhasil',
        );
        context.go('/login');
      } else if (mounted && viewModel.error != null) {
        AnimatedSnackbar.error(
          context,
          viewModel.error!,
          title: 'Registrasi Gagal',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();

    return AuthScaffold(
      eyebrow: 'Akun Toko',
      title: 'Buat Akun Baru',
      description:
          'Daftar untuk menyimpan pesanan, melacak status belanja, dan menikmati pengalaman toko yang lebih personal',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthLabel(text: 'Nama Lengkap'),
            AuthTextField(
              controller: _nameController,
              hintText: 'Nama lengkap Anda',
              prefixIcon: PhosphorIconsRegular.user,
              textInputAction: TextInputAction.next,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Nama lengkap wajib diisi'
                  : null,
            ),
            const Gap(16),
            const AuthLabel(text: 'Alamat Email'),
            AuthTextField(
              controller: _emailController,
              hintText: 'name@email.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: PhosphorIconsRegular.envelope,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
                if (!value.contains('@')) return 'Format email tidak valid';
                return null;
              },
            ),
            const Gap(16),
            const AuthLabel(text: 'Nomor Telepon'),
            AuthTextField(
              controller: _phoneController,
              hintText: '08xxxxxxxxxx',
              keyboardType: TextInputType.phone,
              prefixIcon: PhosphorIconsRegular.phone,
              textInputAction: TextInputAction.next,
            ),
            const Gap(16),
            const AuthLabel(text: 'Password'),
            AuthTextField(
              controller: _passwordController,
              hintText: '••••••••',
              obscureText: _obscurePassword,
              prefixIcon: PhosphorIconsRegular.lock,
              textInputAction: TextInputAction.next,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? PhosphorIconsRegular.eyeSlash
                      : PhosphorIconsRegular.eye,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Password wajib diisi';
                if (value.length < 8) return 'Minimum 8 karakter';
                return null;
              },
            ),
            const Gap(16),
            const AuthLabel(text: 'Konfirmasi Password'),
            AuthTextField(
              controller: _passwordConfirmationController,
              hintText: '••••••••',
              obscureText: _obscurePasswordConfirmation,
              prefixIcon: PhosphorIconsRegular.lock,
              textInputAction: TextInputAction.done,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePasswordConfirmation
                      ? PhosphorIconsRegular.eyeSlash
                      : PhosphorIconsRegular.eye,
                ),
                onPressed: () => setState(
                  () => _obscurePasswordConfirmation = !_obscurePasswordConfirmation,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Konfirmasi password wajib diisi';
                }
                return null;
              },
            ),
            const Gap(24),
            AppButton(
              text: 'Buat Akun',
              onPressed: _handleRegister,
              isLoading: viewModel.isLoading,
              height: 58,
            ),
            const Gap(18),
            Center(
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                  children: [
                    const TextSpan(text: 'Sudah punya akun? '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: GestureDetector(
                        onTap: () => context.go('/login'),
                        child: Text(
                          'Masuk di sini',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
