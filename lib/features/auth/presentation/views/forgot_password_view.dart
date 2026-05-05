import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'package:mitologi_clothing_mobile/core/widgets/app_button.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tautan reset password telah dikirim ke email Anda.'),
        ),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();

    return AuthScaffold(
      eyebrow: 'Akun Toko',
      title: 'Lupa Password',
      description:
          'Masukkan email akun Anda dan kami akan mengirimkan tautan untuk mengatur ulang password',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (viewModel.error != null) ...[
              AuthAlert(message: viewModel.error!),
              const Gap(16),
            ],
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
            const Gap(24),
            AppButton(
              text: 'Kirim Tautan Reset',
              onPressed: _handleSubmit,
              isLoading: viewModel.isLoading,
              height: 58,
            ),
            const Gap(20),
            Center(
              child: TextButton.icon(
                onPressed: () => context.go('/login'),
                icon: const Icon(PhosphorIconsRegular.arrowLeft, size: 18),
                label: const Text('Kembali ke Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
