import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum NinjaButtonVariant { primary, ghost }

class NinjaButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final NinjaButtonVariant variant;
  final IconData? icon;
  final bool fullWidth;

  const NinjaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = NinjaButtonVariant.primary,
    this.icon,
    this.fullWidth = true,
  });

  @override
  State<NinjaButton> createState() => _NinjaButtonState();
}

class _NinjaButtonState extends State<NinjaButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.variant == NinjaButtonVariant.primary;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: widget.fullWidth ? double.infinity : null,
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.primaryFixed : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isPrimary
                ? null
                : Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                    width: 1),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: AppColors.primaryFixed.withValues(alpha: 0.2),
                      blurRadius: 20,
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize:
                widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Text(
                widget.label.toUpperCase(),
                style: GoogleFonts.hankenGrotesk(
                  color: isPrimary
                      ? AppColors.onPrimaryFixed
                      : AppColors.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              if (widget.icon != null) ...[
                const SizedBox(width: 8),
                Icon(
                  widget.icon,
                  color: isPrimary
                      ? AppColors.onPrimaryFixed
                      : AppColors.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
