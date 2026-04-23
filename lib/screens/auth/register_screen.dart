import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_overlay.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await context.read<AuthProvider>().register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          passwordConfirmation: _passwordConfirmController.text,
        );
    if (success && mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return LoadingOverlay(
      isLoading: authProvider.isLoading,
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop())),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.texture,
                                  size: 32, color: Colors.white),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Text('Mitologi Clothing',
                            style: GoogleFonts.notoSerif(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary)),
                        const SizedBox(height: 4),
                        Text('Buat Akun Baru',
                            style: GoogleFonts.notoSerif(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (authProvider.error != null)
                    Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                            color: AppColors.errorContainer,
                            borderRadius: BorderRadius.circular(12)),
                        child: Text(authProvider.error!,
                            style:
                                TextStyle(color: AppColors.onErrorContainer))),
                  _buildTextField('Nama Lengkap', _nameController, 'John Doe',
                      validator: (v) =>
                          v?.isNotEmpty == true ? null : 'Nama harus diisi'),
                  const SizedBox(height: 20),
                  _buildTextField('Email', _emailController, 'nama@email.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v?.contains('@') == true
                          ? null
                          : 'Email tidak valid'),
                  const SizedBox(height: 20),
                  _buildPasswordField(
                      'Password',
                      _passwordController,
                      _obscurePassword,
                      () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      (v) {
                        if (v == null || v.isEmpty) return 'Password wajib diisi';
                        if (v.length < 8) return 'Password minimal 8 karakter';
                        if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Password harus mengandung huruf besar';
                        if (!RegExp(r'[a-z]').hasMatch(v)) return 'Password harus mengandung huruf kecil';
                        if (!RegExp(r'[0-9]').hasMatch(v)) return 'Password harus mengandung angka';
                        return null;
                      }),
                  const SizedBox(height: 20),
                  _buildPasswordField(
                      'Konfirmasi Password',
                      _passwordConfirmController,
                      _obscureConfirm,
                      () => setState(() => _obscureConfirm = !_obscureConfirm),
                      (v) => v == _passwordController.text
                          ? null
                          : 'Password tidak cocok'),
                  const SizedBox(height: 32),
                  ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 18)),
                      child: Text('Daftar',
                          style: GoogleFonts.manrope(
                              fontSize: 16, fontWeight: FontWeight.w600))),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Sudah punya akun?',
                          style: GoogleFonts.manrope(
                              fontSize: 14, color: AppColors.onSurfaceVariant)),
                      TextButton(
                          onPressed: () => context.pop(),
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

  Widget _buildTextField(
      String label, TextEditingController controller, String hint,
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
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
          keyboardType: keyboardType,
          decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: AppColors.secondary, width: 2))),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPasswordField(
      String label,
      TextEditingController controller,
      bool obscure,
      VoidCallback onToggle,
      String? Function(String?)? validator) {
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
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: AppColors.secondary, width: 2)),
              suffixIcon: IconButton(
                  icon: Icon(
                      obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.onSurfaceVariant),
                  onPressed: onToggle)),
          validator: validator,
        ),
      ],
    );
  }
}
