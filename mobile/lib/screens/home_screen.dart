import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import '../widgets/ninja_button.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDim,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _DotPatternPainter())),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      _buildHero(),
                      const SizedBox(height: 42),
                      NinjaButton(
                        label: 'Sign In',
                        icon: Icons.login,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      NinjaButton(
                        label: 'Create Account',
                        icon: Icons.person_add_outlined,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        ),
                        variant: NinjaButtonVariant.ghost,
                      ),
                      const SizedBox(height: 48),
                      Center(
                        child: Text(
                          'By continuing you agree to our Terms of Service.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.hankenGrotesk(
                            color: AppColors.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            ),
                            fontSize: 11,
                          ),
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
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        const BrandLogo(size: 168),
        const SizedBox(height: 22),
        Text(
          "DONATELLO'S",
          textAlign: TextAlign.center,
          style: GoogleFonts.anybody(
            fontSize: 38,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: 1,
            height: 1,
            fontStyle: FontStyle.italic,
          ),
        ),
        Text(
          'PIZZA',
          textAlign: TextAlign.center,
          style: GoogleFonts.anybody(
            fontSize: 38,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryFixed,
            letterSpacing: 1,
            height: 1.1,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Vigilante Hospitality',
          textAlign: TextAlign.center,
          style: GoogleFonts.hankenGrotesk(
            color: AppColors.onSurfaceVariant,
            fontSize: 14,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.primaryFixed.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Text(
            'Order fast. Stay in the shadows.',
            style: GoogleFonts.hankenGrotesk(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9FFB00).withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    const spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotPatternPainter old) => false;
}
