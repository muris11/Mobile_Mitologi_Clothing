import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';
import 'package:mitologi_clothing_mobile/core/widgets/app_button.dart';
import 'package:mitologi_clothing_mobile/core/widgets/animated_snackbar.dart';
import 'package:mitologi_clothing_mobile/features/auth/presentation/auth_view_model.dart';
import 'auth_scaffold.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final viewModel = context.read<AuthViewModel>();
    final success = await viewModel.forgotPassword(_emailController.text.trim());
    if (!mounted) {
      return;
    }

    if (success) {
      AnimatedSnackbar.success(
        context,
        'Tautan reset password telah dikirim ke email Anda. Silakan periksa kotak masuk.',
        title: 'Email Terkirim',
      );
      context.go('/login');
    } else if (viewModel.error != null) {
      AnimatedSnackbar.error(
        context,
        viewModel.error!,
        title: 'Proses Gagal',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();

    return AuthScaffold(
      eyebrow: 'Akun Toko',
      title: 'Lupa Password',
      description:
          'Masukkan email akun Anda and kami akan mengirimkan tautan untuk mengatur ulang password',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthLabel(text: 'Email'),
            AuthTextField(
              controller: _emailController,
              hintText: 'nama@email.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              prefixIcon: PhosphorIconsRegular.envelope,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email wajib diisi';
                }
                if (!value.contains('@')) {
                  return 'Format email tidak valid';
                }
                return null;
              },
            ),
            const Gap(32),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: AppButton(
                text: 'KIRIM TAUTAN RESET',
                onPressed: _handleSubmit,
                isLoading: viewModel.isLoading,
                height: 60,
              ),
            ),
            const Gap(24),
            Center(
              child: TextButton.icon(
                onPressed: () => context.go('/login'),
                icon: const Icon(PhosphorIconsRegular.caretLeft, size: 16),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                label: Text(
                  'Kembali ke Login',
                  style: AppTextStyles.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
