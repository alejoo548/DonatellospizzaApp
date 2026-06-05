import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';
import '../theme/app_theme.dart';
import '../widgets/app_toast.dart';
import '../widgets/brand_logo.dart';
import '../widgets/ninja_button.dart';
import '../widgets/ninja_text_field.dart';
import 'email_verification_screen.dart';
import 'forgot_password_screen.dart';
import 'ordering_flow_screen.dart';
import 'register_screen.dart';

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
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      final data = await ApiService.login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      await SessionManager.save(
        token: data['token'] as String,
        user: data['user'] as Map<String, dynamic>,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OrderingFlowScreen()),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.errors?['email_unverified'] == true) {
        final unverifiedEmail =
            e.errors?['email'] as String? ?? _emailCtrl.text.trim();
        showAppToast(
          context,
          message: 'Please verify your email to sign in.',
          type: AppToastType.info,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                EmailVerificationScreen(email: unverifiedEmail),
          ),
        );
      } else {
        showAppToast(context, message: e.message, type: AppToastType.error);
      }
    } catch (_) {
      if (!mounted) return;
      showAppToast(
        context,
        message: 'Could not connect to the server.',
        type: AppToastType.error,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDim,
      body: Stack(
        children: [
          Positioned.fill(child: _DotPattern()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
                        _buildHeader(),
                        const SizedBox(height: 28),
                        NinjaTextField(
                          controller: _emailCtrl,
                          placeholder: 'Email Address',
                          prefixIcon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => (v == null || !v.contains('@'))
                              ? 'Invalid email'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        NinjaTextField(
                          controller: _passwordCtrl,
                          placeholder: 'Password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter your password';
                            }
                            return null;
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.onSurfaceVariant,
                              size: 20,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen(),
                              ),
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.hankenGrotesk(
                                color: AppColors.primaryFixed,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _loading
                            ? Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryFixed,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.onPrimaryFixed,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'CONNECTING...',
                                      style: GoogleFonts.hankenGrotesk(
                                        color: AppColors.onPrimaryFixed,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : NinjaButton(
                                label: 'Access Network',
                                onPressed: _onLogin,
                              ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.white.withValues(alpha: 0.05),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'OR',
                                style: GoogleFonts.hankenGrotesk(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.white.withValues(alpha: 0.05),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        NinjaButton(
                          label: 'Create Account',
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
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
        const BrandLogo(size: 132),
        const SizedBox(height: 18),
        Text(
          'Ninja Access',
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
    return CustomPaint(painter: _DotPatternPainter());
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
