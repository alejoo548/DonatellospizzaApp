import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/password_validator.dart';
import '../widgets/ninja_button.dart';
import '../widgets/ninja_text_field.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _lastnameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _lastnameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await ApiService.register(
        name: _nameCtrl.text.trim(),
        lastname: _lastnameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created! Please sign in.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo conectar al servidor.'),
          backgroundColor: Colors.red,
        ),
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
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32),
                        _buildHeader(),
                        const SizedBox(height: 32),
                        NinjaTextField(
                          controller: _nameCtrl,
                          placeholder: 'First Name',
                          prefixIcon: Icons.person_outline,
                          keyboardType: TextInputType.name,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Enter your name'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        NinjaTextField(
                          controller: _lastnameCtrl,
                          placeholder: 'Last Name',
                          prefixIcon: Icons.person_outline,
                          keyboardType: TextInputType.name,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Enter your lastname'
                              : null,
                        ),
                        const SizedBox(height: 24),
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
                          validator: (value) => PasswordValidator.validate(
                            value,
                            emptyMessage: 'Enter your password',
                          ),
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
                        const SizedBox(height: 24),
                        NinjaTextField(
                          controller: _confirmPasswordCtrl,
                          placeholder: 'Confirm Password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscureConfirmPassword,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Confirm your password';
                            }

                            final passwordError = PasswordValidator.validate(
                              v,
                              emptyMessage: 'Confirm your password',
                            );
                            if (passwordError != null) {
                              return passwordError;
                            }

                            if (v != _passwordCtrl.text) {
                              return 'Passwords do not match';
                            }

                            return null;
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.onSurfaceVariant,
                              size: 20,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          PasswordValidator.requirementsMessage,
                          style: GoogleFonts.hankenGrotesk(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _loading
                            ? Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryFixed,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryFixed.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 20,
                                    ),
                                  ],
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
                                label: 'Create Account',
                                icon: Icons.arrow_forward,
                                onPressed: _onSubmit,
                              ),
                        const SizedBox(height: 24),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              }
                            },
                            child: RichText(
                              text: TextSpan(
                                text: 'Already have an account? ',
                                style: GoogleFonts.hankenGrotesk(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Log in',
                                    style: GoogleFonts.hankenGrotesk(
                                      color: AppColors.primaryFixed,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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
              color: AppColors.primaryFixed.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryFixed.withValues(alpha: 0.1),
                blurRadius: 20,
              ),
            ],
          ),
          child: const Icon(
            Icons.local_pizza,
            color: AppColors.primaryFixed,
            size: 30,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Join the Clan',
          textAlign: TextAlign.center,
          style: GoogleFonts.anybody(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Create your account to access exclusive\nmutant menus and fast delivery.',
          textAlign: TextAlign.center,
          style: GoogleFonts.hankenGrotesk(
            color: AppColors.onSurfaceVariant,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSecureNotice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primaryFixed,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryFixed.withValues(alpha: 0.75),
                blurRadius: 6,
              ),
            ],
          ),
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
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotPatternPainter old) => false;
}
