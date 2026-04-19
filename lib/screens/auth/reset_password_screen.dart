import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/loading_overlay.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? token;
  final String? email;

  const ResetPasswordScreen({super.key, this.token, this.email});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _hasValidToken => widget.token != null && widget.email != null;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasValidToken) {
      setState(() {
        _errorMessage =
            'Token tidak valid. Silakan klik tautan dari email Anda.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<AuthService>();
      await authService.resetPassword(
        token: widget.token!,
        email: widget.email!,
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      );
      setState(() {
        _isSuccess = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Gagal reset password. Tautan mungkin sudah kedaluwarsa.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
            onPressed: () => context.go('/login'),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _isSuccess
                                ? Icons.check_circle_outline
                                : Icons.lock_outline,
                            size: 48,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _isSuccess
                              ? 'Password Berhasil Diubah'
                              : 'Reset Password',
                          style: GoogleFonts.notoSerif(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isSuccess
                              ? 'Password Anda telah berhasil direset. Silakan masuk dengan password baru.'
                              : 'Masukkan password baru untuk akun Anda',
                          style: GoogleFonts.manrope(
                              fontSize: 14, color: AppColors.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                          color: AppColors.errorContainer,
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(_errorMessage!,
                          style: TextStyle(color: AppColors.onErrorContainer)),
                    ),
                  if (_isSuccess) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: AppColors.secondary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Password berhasil direset. Silakan login dengan password baru.',
                              style: GoogleFonts.manrope(
                                  fontSize: 14, color: AppColors.secondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => context.go('/login'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 18)),
                      child: Text('Masuk dengan Password Baru',
                          style: GoogleFonts.manrope(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ] else ...[
                    if (!_hasValidToken)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                            color: AppColors.errorContainer,
                            borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber,
                                color: AppColors.error),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Tautan reset password tidak valid. Silakan minta tautan baru.',
                                style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    color: AppColors.onErrorContainer),
                              ),
                            ),
                          ],
                        ),
                      ),
                    _buildPasswordField(
                      'Password Baru',
                      _passwordController,
                      _obscurePassword,
                      (v) {
                        if (v == null || v.length < 8) {
                          return 'Password minimal 8 karakter';
                        }
                        return null;
                      },
                      () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    const SizedBox(height: 20),
                    _buildPasswordField(
                      'Konfirmasi Password',
                      _confirmPasswordController,
                      _obscureConfirmPassword,
                      (v) {
                        if (v != _passwordController.text) {
                          return 'Password tidak cocok';
                        }
                        return null;
                      },
                      () => setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _hasValidToken ? _resetPassword : null,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 18)),
                      child: Text('Reset Password',
                          style: GoogleFonts.manrope(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Ingat password?',
                          style: GoogleFonts.manrope(
                              fontSize: 14, color: AppColors.onSurfaceVariant)),
                      TextButton(
                          onPressed: () => context.go('/login'),
                          child: Text('Masuk',
                              style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondary))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool obscure,
    String? Function(String?) validator,
    VoidCallback toggleObscure,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
                icon: Icon(obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: toggleObscure),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: AppColors.secondary, width: 2)),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
