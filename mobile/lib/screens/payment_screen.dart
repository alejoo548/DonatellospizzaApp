import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_toast.dart';
import '../widgets/brand_logo.dart';

class PaymentScreen extends StatefulWidget {
  final double total;

  const PaymentScreen({super.key, required this.total});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _processing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  String get _digitsOnly =>
      _numberController.text.replaceAll(RegExp(r'\D'), '');

  String get _brand {
    final digits = _digitsOnly;
    if (digits.startsWith('4')) return 'Visa';
    if (RegExp(r'^5[1-5]').hasMatch(digits)) return 'Mastercard';
    if (RegExp(r'^3[47]').hasMatch(digits)) return 'Amex';
    return 'Card';
  }

  String get _previewNumber {
    final digits = _digitsOnly.padRight(16, '•');
    final groups = <String>[];
    for (var i = 0; i < 16; i += 4) {
      groups.add(digits.substring(i, i + 4));
    }
    return groups.join(' ');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _processing) return;

    setState(() => _processing = true);

    try {
      final data = await ApiService.checkout(
        cardholderName: _nameController.text.trim(),
        cardNumber: _numberController.text,
        expMonth: int.parse(_monthController.text),
        expYear: int.parse(_yearController.text),
        cvv: _cvvController.text,
      );

      if (!mounted) return;
      final order = data['order'] as Map<String, dynamic>? ?? {};
      await _showSuccessDialog(order);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      showAppToast(context, message: e.toString(), type: AppToastType.error);
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _showSuccessDialog(Map<String, dynamic> order) async {
    final items = (order['items'] as List<dynamic>?) ?? [];
    final payment = order['payment'] as Map<String, dynamic>?;
    final total = (order['total'] as num?)?.toDouble() ?? widget.total;
    final orderNumber = order['order_number'] as String? ?? '';

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryFixed.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.primaryFixed,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Payment Approved',
                style: GoogleFonts.anybody(
                  color: AppColors.primaryFixed,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (orderNumber.isNotEmpty) ...[
                _invoiceRow('Order', orderNumber),
                const SizedBox(height: 4),
              ],
              if (payment != null) ...[
                _invoiceRow(
                  'Payment',
                  '${payment['card_brand'] ?? ''} •••• ${payment['card_last_four'] ?? ''}',
                ),
                const SizedBox(height: 4),
                _invoiceRow(
                  'Auth',
                  payment['authorization_code'] as String? ?? '',
                ),
              ],
              const SizedBox(height: 12),
              Divider(
                color: AppColors.outlineVariant.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 8),
              if (items.isNotEmpty) ...[
                Text(
                  'Items',
                  style: GoogleFonts.hankenGrotesk(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                ...items.take(5).map<Widget>((item) {
                  final name = item['product_name'] as String? ?? 'Item';
                  final qty = item['quantity'] as int? ?? 1;
                  final price = (item['total_price'] as num?)?.toDouble() ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Text(
                          '$qty×',
                          style: GoogleFonts.hankenGrotesk(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.hankenGrotesk(
                              color: AppColors.onSurface,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          '\$${price.toStringAsFixed(2)}',
                          style: GoogleFonts.hankenGrotesk(
                            color: AppColors.onSurface,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                Divider(
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                ),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: GoogleFonts.hankenGrotesk(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: GoogleFonts.anybody(
                      color: AppColors.primaryFixed,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'An invoice was sent to your email.',
                style: GoogleFonts.hankenGrotesk(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryFixed,
              foregroundColor: AppColors.onPrimaryFixed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Done',
              style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _invoiceRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.hankenGrotesk(
            color: AppColors.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.hankenGrotesk(
              color: AppColors.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDim,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDim.withValues(alpha: 0.8),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const BrandLogo(size: 30, compact: true),
            const SizedBox(width: 8),
            Text(
              'Secure Payment',
              style: GoogleFonts.anybody(
                color: AppColors.primaryFixed,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCardPreview(),
                const SizedBox(height: 22),
                _field(
                  controller: _nameController,
                  label: 'Cardholder name',
                  icon: Icons.person_outline,
                  validator: (value) => value == null || value.trim().length < 3
                      ? 'Enter the cardholder name.'
                      : null,
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _numberController,
                  label: 'Card number',
                  icon: Icons.credit_card,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(19),
                  ],
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    final digits = value?.replaceAll(RegExp(r'\D'), '') ?? '';
                    return digits.length < 13
                        ? 'Enter a valid card number.'
                        : null;
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        controller: _monthController,
                        label: 'MM',
                        icon: Icons.calendar_month,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        validator: (value) {
                          final month = int.tryParse(value ?? '');
                          if (month == null || month < 1 || month > 12) {
                            return 'Invalid month.';
                          }
                          final year =
                              int.tryParse(_yearController.text);
                          final now = DateTime.now();
                          if (year != null &&
                              year == now.year &&
                              month < now.month) {
                            return 'Card has expired.';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                        controller: _yearController,
                        label: 'YYYY',
                        icon: Icons.event_available,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        validator: (value) {
                          final year = int.tryParse(value ?? '');
                          final now = DateTime.now();
                          if (year == null || year < now.year) {
                            return 'Invalid year.';
                          }
                          if (year == now.year) {
                            final month =
                                int.tryParse(_monthController.text);
                            if (month != null && month < now.month) {
                              return 'Card has expired.';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                        controller: _cvvController,
                        label: 'CVV',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        validator: (value) {
                          final length = value?.length ?? 0;
                          return length < 3 ? 'Invalid CVV.' : null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _securityNote(),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: _processing ? null : _submit,
                  icon: _processing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.verified_user_outlined),
                  label: Text(
                    _processing
                        ? 'PROCESSING...'
                        : 'PAY \$${widget.total.toStringAsFixed(2)}',
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.primaryFixed,
                    foregroundColor: AppColors.onPrimaryFixed,
                    textStyle: GoogleFonts.hankenGrotesk(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardPreview() {
    return Container(
      height: 190,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryFixed.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryFixed.withValues(alpha: 0.12),
            blurRadius: 22,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security, color: AppColors.primaryFixed),
              const Spacer(),
              Text(
                _brand,
                style: GoogleFonts.anybody(
                  color: AppColors.primaryFixed,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            _previewNumber,
            style: GoogleFonts.hankenGrotesk(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  _nameController.text.trim().isEmpty
                      ? 'CARDHOLDER'
                      : _nameController.text.trim().toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.hankenGrotesk(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                '${_monthController.text.padLeft(2, '0')}/${_yearController.text.isEmpty ? 'YYYY' : _yearController.text}',
                style: GoogleFonts.hankenGrotesk(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _securityNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock, color: AppColors.primaryFixed, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Simulation only. Full card number and CVV are never stored. Database keeps last four digits and a one-way fingerprint.',
              style: GoogleFonts.hankenGrotesk(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      onChanged: (value) {
        onChanged?.call(value);
        setState(() {});
      },
      style: GoogleFonts.hankenGrotesk(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryFixed),
        filled: true,
        fillColor: AppColors.surfaceContainer,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.25),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryFixed),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}
