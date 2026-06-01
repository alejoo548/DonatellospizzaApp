import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/password_validator.dart';
import '../widgets/ninja_button.dart';
import '../widgets/ninja_text_field.dart';

enum _RecoveryStep { email, token, password, done }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  _RecoveryStep _step = _RecoveryStep.email;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int? _expiresInMinutes;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _tokenCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onPrimaryAction() async {
    if (_step != _RecoveryStep.done &&
        !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_step == _RecoveryStep.done) {
      Navigator.pop(context);
      return;
    }

    setState(() => _loading = true);

    try {
      switch (_step) {
        case _RecoveryStep.email:
          final response = await ApiService.requestPasswordReset(
            email: _emailCtrl.text.trim(),
          );
          if (!mounted) return;
          setState(() {
            _step = _RecoveryStep.token;
            _expiresInMinutes = response['expires_in_minutes'] as int?;
          });
          _showSnackBar(
            'Check your email and enter the recovery token..',
            Colors.green.shade700,
          );
          break;
        case _RecoveryStep.token:
          await ApiService.validatePasswordResetToken(
            email: _emailCtrl.text.trim(),
            token: _tokenCtrl.text.trim(),
          );
          if (!mounted) return;
          setState(() => _step = _RecoveryStep.password);
          _showSnackBar(
            'Token validated. Now create a new password.',
            Colors.green.shade700,
          );
          break;
        case _RecoveryStep.password:
          await ApiService.resetPassword(
            email: _emailCtrl.text.trim(),
            token: _tokenCtrl.text.trim(),
            password: _passwordCtrl.text,
          );
          if (!mounted) return;
          _resetRecoveryFields();
          setState(() => _step = _RecoveryStep.done);
          _showSnackBar(
            'Your password was successfully updated.',
            Colors.green.shade700,
          );
          break;
        case _RecoveryStep.done:
          break;
      }
    } on ApiException catch (e) {
      _showSnackBar(e.message, Colors.red.shade700);
    } catch (_) {
      _showSnackBar(
        'Password recovery could not be completed.',
        Colors.red.shade700,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _resetRecoveryFields() {
    _emailCtrl.clear();
    _tokenCtrl.clear();
    _passwordCtrl.clear();
    _confirmPasswordCtrl.clear();
    _expiresInMinutes = null;
    _formKey.currentState?.reset();
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
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back),
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildHeader(),
                        const SizedBox(height: 36),
                        ..._buildStepFields(),
                        const SizedBox(height: 24),
                        _loading
                            ? _buildLoadingState()
                            : NinjaButton(
                                label: _primaryLabel(),
                                icon: _primaryIcon(),
                                onPressed: _onPrimaryAction,
                              ),
                        const SizedBox(height: 20),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: _buildStepNotice(),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Back to Login',
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
            Icons.lock_reset_outlined,
            color: AppColors.primaryFixed,
            size: 30,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _titleForStep(),
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
          _subtitleForStep(),
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

  List<Widget> _buildStepFields() {
    switch (_step) {
      case _RecoveryStep.email:
        return [_buildEmailField()];
      case _RecoveryStep.token:
        return [
          _buildEmailField(),
          const SizedBox(height: 20),
          _buildTokenField(),
        ];
      case _RecoveryStep.password:
        return [
          _buildEmailField(enabled: false),
          const SizedBox(height: 20),
          _buildTokenField(),
          const SizedBox(height: 20),
          _buildPasswordField(),
          const SizedBox(height: 20),
          _buildConfirmPasswordField(),
          const SizedBox(height: 12),
          _buildPasswordRequirements(),
        ];
      case _RecoveryStep.done:
        return [_buildCompletionCard()];
    }
  }

  Widget _buildEmailField({bool enabled = true}) {
    return NinjaTextField(
      controller: _emailCtrl,
      placeholder: 'Email Address',
      prefixIcon: Icons.mail_outline,
      keyboardType: TextInputType.emailAddress,
      enabled: enabled,
      validator: (value) {
        final email = value?.trim() ?? '';
        if (email.isEmpty || !email.contains('@')) {
          return 'Enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildTokenField() {
    return NinjaTextField(
      controller: _tokenCtrl,
      placeholder: 'Recovery Token',
      prefixIcon: Icons.pin_outlined,
      validator: (value) {
        if ((value?.trim().isEmpty ?? true)) {
          return 'Enter the token sent to your email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return NinjaTextField(
      controller: _passwordCtrl,
      placeholder: 'New Password',
      prefixIcon: Icons.lock_outline,
      obscureText: _obscurePassword,
      validator: (value) => PasswordValidator.validate(
        value,
        emptyMessage: 'Enter your new password',
      ),
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: AppColors.onSurfaceVariant,
          size: 20,
        ),
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return NinjaTextField(
      controller: _confirmPasswordCtrl,
      placeholder: 'Confirm New Password',
      prefixIcon: Icons.lock_outline,
      obscureText: _obscureConfirmPassword,
      validator: (value) {
        if ((value?.isEmpty ?? true)) {
          return 'Confirm your new password';
        }
        final passwordError = PasswordValidator.validate(
          value,
          emptyMessage: 'Confirm your new password',
        );
        if (passwordError != null) {
          return passwordError;
        }
        if (value != _passwordCtrl.text) {
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
          () => _obscureConfirmPassword = !_obscureConfirmPassword,
        ),
      ),
    );
  }

  Widget _buildStepNotice() {
    if (_step == _RecoveryStep.email) {
      return const SizedBox.shrink();
    }

    if (_step == _RecoveryStep.done) {
      return _buildNotice(
        keyValue: 'done-notice',
        message:
            'Password updated. You can return to login and access your account.',
      );
    }

    return _buildNotice(
      keyValue: _step == _RecoveryStep.token ? 'token-notice' : 'password-notice',
      message: _step == _RecoveryStep.token
          ? 'We sent a recovery token to your email. Enter it below to continue.'
          : 'Your token is valid. Choose a new password to finish recovery.',
    );
  }

  Widget _buildNotice({
    required String keyValue,
    required String message,
  }) {
    return Container(
      key: ValueKey(keyValue),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryFixed.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primaryFixed,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: AppColors.onPrimaryFixed,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.hankenGrotesk(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryFixed.withValues(alpha: 0.24),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.verified_user_outlined,
            color: AppColors.primaryFixed,
            size: 34,
          ),
          const SizedBox(height: 12),
          Text(
            'Your account is ready again.',
            textAlign: TextAlign.center,
            style: GoogleFonts.hankenGrotesk(
              color: AppColors.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryFixed,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
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
            'PROCESSING...',
            style: GoogleFonts.hankenGrotesk(
              color: AppColors.onPrimaryFixed,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    return Text(
      PasswordValidator.requirementsMessage,
      style: GoogleFonts.hankenGrotesk(
        color: AppColors.onSurfaceVariant,
        fontSize: 12,
        height: 1.4,
      ),
    );
  }

  String _titleForStep() {
    switch (_step) {
      case _RecoveryStep.email:
        return 'Reset Password';
      case _RecoveryStep.token:
        return 'Validate Token';
      case _RecoveryStep.password:
        return 'Choose New Password';
      case _RecoveryStep.done:
        return 'Recovery Complete';
    }
  }

  String _subtitleForStep() {
    switch (_step) {
      case _RecoveryStep.email:
        return 'Enter your email and we will send you\na recovery token.';
      case _RecoveryStep.token:
        final expiresLabel = _expiresInMinutes == null
            ? 'soon'
            : 'in $_expiresInMinutes minutes';
        return 'Open your email, copy the token and validate it\ninside the app. It expires $expiresLabel.';
      case _RecoveryStep.password:
        return 'Set a strong new password with 8+ characters,\nuppercase, lowercase and numbers.';
      case _RecoveryStep.done:
        return 'Your password was updated. Return to login\nwhen you are ready.';
    }
  }

  String _primaryLabel() {
    switch (_step) {
      case _RecoveryStep.email:
        return 'Send Token';
      case _RecoveryStep.token:
        return 'Validate Token';
      case _RecoveryStep.password:
        return 'Change Password';
      case _RecoveryStep.done:
        return 'Back to Login';
    }
  }

  IconData _primaryIcon() {
    switch (_step) {
      case _RecoveryStep.email:
        return Icons.outgoing_mail;
      case _RecoveryStep.token:
        return Icons.verified_outlined;
      case _RecoveryStep.password:
        return Icons.lock_reset;
      case _RecoveryStep.done:
        return Icons.arrow_forward;
    }
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
  bool shouldRepaint(_DotPatternPainter oldDelegate) => false;
}
