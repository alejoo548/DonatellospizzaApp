import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/ninja_button.dart';
import '../widgets/ninja_text_field.dart';
import 'register_screen.dart';
import 'products_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDim,
      body: Stack(
        children: [
          // Dot pattern background
          Positioned.fill(child: _DotPattern()),
          SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32),
                        _buildHeader(),
                        const SizedBox(height: 40),
                        NinjaTextField(
                          controller: _emailCtrl,
                          placeholder: 'Email Address',
                          prefixIcon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => (v == null || !v.contains('@'))
                              ? 'Correo inválido'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        NinjaTextField(
                          controller: _passwordCtrl,
                          placeholder: 'Password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          validator: (v) => (v == null || v.length < 6)
                              ? 'Mínimo 6 caracteres'
                              : null,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.onSurfaceVariant,
                              size: 20,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              'Forgot Code?',
                              style: GoogleFonts.hankenGrotesk(
                                color: AppColors.primaryFixed,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        NinjaButton(
                          label: 'Access Network',
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ProductsScreen()),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(children: [
                          Expanded(
                              child: Divider(
                                  color: Colors.white.withValues(alpha: 0.05))),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'OR',
                              style: GoogleFonts.hankenGrotesk(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 12),
                            ),
                          ),
                          Expanded(
                              child: Divider(
                                  color: Colors.white.withValues(alpha: 0.05))),
                        ]),
                        const SizedBox(height: 24),
                        NinjaButton(
                          label: 'Create Account',
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          ),
                          variant: NinjaButtonVariant.ghost,
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              'Continue as Guest',
                              style: GoogleFonts.hankenGrotesk(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildSecureNotice(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            shape: BoxShape.circle,
            border: Border.all(
                color: AppColors.primaryFixed.withValues(alpha: 0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryFixed.withValues(alpha: 0.1),
                blurRadius: 20,
              ),
            ],
          ),
          child: const Icon(Icons.local_pizza,
              color: AppColors.primaryFixed, size: 30),
        ),
        const SizedBox(height: 24),
        Text(
          'Acceso Ninja',
          textAlign: TextAlign.center,
          style: GoogleFonts.anybody(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Access Network Login',
          style: GoogleFonts.hankenGrotesk(
            color: AppColors.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSecureNotice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primaryFixed.withValues(alpha: 0.75),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(width: 6),
        Text(
          'Secure connection established',
          style: GoogleFonts.hankenGrotesk(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _DotPattern extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DotPatternPainter(),
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
    const radius = 1.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotPatternPainter old) => false;
}
