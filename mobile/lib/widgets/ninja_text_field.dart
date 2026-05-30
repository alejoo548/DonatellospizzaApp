import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class NinjaTextField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const NinjaTextField({
    super.key,
    required this.controller,
    required this.placeholder,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.hankenGrotesk(
        color: AppColors.onSurface,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: GoogleFonts.hankenGrotesk(
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
          fontSize: 16,
        ),
        prefixIcon: Icon(prefixIcon, color: AppColors.onSurfaceVariant, size: 22),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
              color: AppColors.surfaceContainerHighest, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryFixed, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}
