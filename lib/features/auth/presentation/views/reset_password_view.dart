import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/widgets/app_button.dart';
import 'package:mitologi_clothing_mobile/features/auth/presentation/auth_view_model.dart';

import 'auth_scaffold.dart';

class ResetPasswordView extends StatefulWidget {
  final String token;
  final String email;

  const ResetPasswordView({
    super.key,
    required this.token,
    required this.email,
  });

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateLocal() {
    _passwordError = null;
    _confirmPasswordError = null;

    var isValid = true;
    if (_passwordController.text.length < 8) {
      _passwordError = 'Password minimal 8 karakter';
      isValid = false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _confirmPasswordError = 'Konfirmasi password tidak cocok';
      isValid = false;
    }

    setState(() {});
    return isValid;
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (!_validateLocal()) {
      return;
    }

    final viewModel = context.read<AuthViewModel>();
    final success = await viewModel.resetPassword(
      token: widget.token,
      email: widget.email,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password Anda berhasil direset. Silakan login dengan password baru.',
          ),
        ),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();

    return AuthScaffold(
      eyebrow: 'Keamanan Akun',
      title: 'Reset Password',
      description:
          'Masukkan password baru Anda yang aman untuk memulihkan akses ke akun Anda',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => context.go('/login'),
                icon: const Icon(PhosphorIconsRegular.arrowLeft),
                tooltip: 'Kembali ke login',
              ),
            ),
            if (viewModel.error != null) ...[
              AuthAlert(message: viewModel.error!),
              const Gap(16),
            ],
            const AuthLabel(text: 'Alamat Email'),
            TextFormField(
              initialValue: widget.email,
              readOnly: true,
              decoration: const InputDecoration(
                hintText: 'email',
                prefixIcon: Icon(PhosphorIconsRegular.envelope),
              ),
            ),
            const Gap(16),
            const AuthLabel(text: 'Password Baru'),
            AuthTextField(
              controller: _passwordController,
              hintText: 'Masukkan minimal 8 karakter',
              obscureText: !_showPassword,
              prefixIcon: PhosphorIconsRegular.lock,
              textInputAction: TextInputAction.next,
              suffixIcon: IconButton(
                icon: Icon(
                  _showPassword
                      ? PhosphorIconsRegular.eyeSlash
                      : PhosphorIconsRegular.eye,
                ),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password baru wajib diisi';
                }
                return null;
              },
            ),
            if (_passwordError != null) ...[
              const Gap(6),
              Text(
                _passwordError!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
              ),
            ],
            const Gap(16),
            const AuthLabel(text: 'Konfirmasi Password'),
            AuthTextField(
              controller: _confirmPasswordController,
              hintText: 'Ulangi password Anda',
              obscureText: !_showPassword,
              prefixIcon: PhosphorIconsRegular.lock,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Konfirmasi password wajib diisi';
                }
                return null;
              },
            ),
            if (_confirmPasswordError != null) ...[
              const Gap(6),
              Text(
                _confirmPasswordError!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
              ),
            ],
            const Gap(24),
            AppButton(
              text: 'Perbarui Password',
              onPressed: _handleSubmit,
              isLoading: viewModel.isLoading,
              height: 58,
            ),
          ],
        ),
      ),
    );
  }
}
