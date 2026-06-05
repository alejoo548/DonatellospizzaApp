import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BrandLogo extends StatelessWidget {
  final double size;
  final bool framed;
  final bool compact;

  const BrandLogo({
    super.key,
    this.size = 64,
    this.framed = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!framed) {
      return SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          'assets/images/donatellos_logo.png',
          fit: BoxFit.contain,
        ),
      );
    }

    final outerPadding = compact ? 2.0 : 7.0;
    final innerPadding = compact ? 1.5 : 6.0;
    final outerRadius = compact ? 10.0 : 22.0;
    final innerRadius = compact ? 8.0 : 18.0;

    return Container(
      width: size + outerPadding * 2,
      height: size + outerPadding * 2,
      padding: EdgeInsets.all(outerPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(outerRadius),
        border: Border.all(
          color: AppColors.primaryFixed.withValues(
            alpha: compact ? 0.25 : 0.45,
          ),
          width: compact ? 1 : 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryFixed.withValues(
              alpha: compact ? 0.1 : 0.22,
            ),
            blurRadius: compact ? 12 : 34,
            spreadRadius: compact ? 0 : 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: compact ? 0.25 : 0.4),
            blurRadius: compact ? 10 : 28,
            offset: Offset(0, compact ? 4 : 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(innerRadius),
        child: Container(
          color: const Color(0xFFE7E0C3),
          padding: EdgeInsets.all(innerPadding),
          child: Image.asset(
            'assets/images/donatellos_logo.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
