// Removed dart:ui
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';

class AuthScaffold extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String description;
  final Widget child;

  const AuthScaffold({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFAF8F5),
              Colors.white,
              Color(0xFFF8FAFC),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Top ambient glow - very soft warm gold
            Positioned(
              top: -150,
              left: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondary.withValues(alpha: 0.15),
                      AppColors.secondary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom right ambient glow - soft primary navy
            Positioned(
              bottom: -200,
              right: -150,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.08),
                      AppColors.primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                  child: Container(
                    width: 560,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: AppBorderRadius.xxlRadius,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.9),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 32),
                              child: Column(
                                children: [
                                  // Streetwear styled eyebrow
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: AppColors.secondary.withValues(alpha: 0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      eyebrow.toUpperCase(),
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 4.0,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                  const Gap(24),
                                  Text(
                                    title,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.headingLarge.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -1.0,
                                      fontSize: 34,
                                    ),
                                  ),
                                  const Gap(12),
                                  Text(
                                    description,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      height: 1.6,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Gap(32),
                                  const Divider(color: AppColors.outlineVariant, thickness: 1.0),
                                ],
                              ),
                            ),
                            child,
                            const Gap(32),
                            const Divider(color: AppColors.outlineVariant, thickness: 1.0),
                            const Gap(20),
                            Text(
                              '© Mitologi Clothing. Hak cipta dilindungi.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.outline,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
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

class AuthAlert extends StatelessWidget {
  final String message;

  const AuthAlert({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: AppBorderRadius.lgRadius,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            PhosphorIconsRegular.warningCircle,
            color: AppColors.error,
            size: 20,
          ),
          const Gap(12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthLabel extends StatelessWidget {
  final String text;

  const AuthLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          fontSize: 11,
        ),
      ),
    );
  }
}

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.validator,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: AppColors.outline.withValues(alpha: 0.8),
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          widget.prefixIcon,
          color: _isFocused ? AppColors.secondary : AppColors.outline,
          size: 22,
        ),
        suffixIcon: widget.suffixIcon,
        filled: true,
        fillColor: _isFocused ? Colors.white : AppColors.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.6),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.secondary,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2.0,
          ),
        ),
      ),
    );
  }
}
