import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';
import '../theme/app_theme.dart';
import '../widgets/app_toast.dart';
import '../widgets/brand_logo.dart';
import '../widgets/ninja_button.dart';
import 'products_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _codeController = TextEditingController();
  bool _loading = false;
  bool _resending = false;
  int _resendCooldown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendCooldown() {
    setState(() => _resendCooldown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCooldown <= 1) {
        t.cancel();
        if (mounted) setState(() => _resendCooldown = 0);
      } else {
        if (mounted) setState(() => _resendCooldown--);
      }
    });
  }

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      showAppToast(
        context,
        message: 'Enter the 6-digit code from your email.',
        type: AppToastType.error,
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final data = await ApiService.verifyEmail(
        email: widget.email,
        code: code,
      );

      final token = data['token'] as String?;
      final user = data['user'] as Map<String, dynamic>?;

      if (token == null || user == null) {
        throw ApiException('Unexpected server response.');
      }

      await SessionManager.save(token: token, user: user);

      if (!mounted) return;
      showAppToast(
        context,
        message: 'Email verified! Welcome to Donatello\'s Pizza.',
        type: AppToastType.success,
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ProductsScreen()),
        (_) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      showAppToast(context, message: e.message, type: AppToastType.error);
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

  Future<void> _resend() async {
    if (_resendCooldown > 0 || _resending) return;

    setState(() => _resending = true);
    try {
      await ApiService.resendVerification(email: widget.email);
      if (!mounted) return;
      showAppToast(
        context,
        message: 'Verification code resent. Check your inbox.',
        type: AppToastType.success,
      );
      _startResendCooldown();
    } on ApiException catch (e) {
      if (!mounted) return;
      showAppToast(context, message: e.message, type: AppToastType.error);
    } catch (_) {
      if (!mounted) return;
      showAppToast(
        context,
        message: 'Could not resend the code.',
        type: AppToastType.error,
      );
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDim,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: BrandLogo(size: 96)),
                  const SizedBox(height: 28),
                  Text(
                    'Check your inbox',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.anybody(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'We sent a 6-digit code to',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.hankenGrotesk(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.email,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.hankenGrotesk(
                      color: AppColors.primaryFixed,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 36),
                  _buildCodeField(),
                  const SizedBox(height: 24),
                  _loading
                      ? Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onPrimaryFixed,
                              ),
                            ),
                          ),
                        )
                      : NinjaButton(
                          label: 'Verify Email',
                          icon: Icons.verified_outlined,
                          onPressed: _verify,
                        ),
                  const SizedBox(height: 24),
                  Center(
                    child: _resendCooldown > 0
                        ? Text(
                            'Resend in ${_resendCooldown}s',
                            style: GoogleFonts.hankenGrotesk(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          )
                        : TextButton(
                            onPressed: _resending ? null : _resend,
                            child: Text(
                              "Didn't receive it? Resend code",
                              style: GoogleFonts.hankenGrotesk(
                                color: AppColors.primaryFixed,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verification Code',
          style: GoogleFonts.hankenGrotesk(
            color: AppColors.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          onChanged: (_) => setState(() {}),
          style: GoogleFonts.hankenGrotesk(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 28,
            letterSpacing: 8,
          ),
          decoration: InputDecoration(
            hintText: '------',
            hintStyle: GoogleFonts.hankenGrotesk(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
              fontSize: 28,
              letterSpacing: 8,
            ),
            filled: true,
            fillColor: AppColors.surfaceContainer,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryFixed,
                width: 2,
              ),
            ),
          ),
        ),
        if (_codeController.text.isNotEmpty &&
            _codeController.text.length < 6)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '${6 - _codeController.text.length} digits remaining',
              style: GoogleFonts.hankenGrotesk(
                color: AppColors.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }
}
