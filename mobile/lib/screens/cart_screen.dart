import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class _CartItem {
  final String name;
  final String description;
  final double price;
  int quantity;

  _CartItem({
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
  });
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<_CartItem> _items = [
    _CartItem(
      name: 'The Shredder Special',
      description: 'Extra pepperoni, spicy honey, jalapeños.',
      price: 24.00,
      quantity: 1,
    ),
    _CartItem(
      name: 'Mutagen Knots',
      description: 'Garlic butter, parmesan dust.',
      price: 8.50,
      quantity: 2,
    ),
  ];

  double get _subtotal =>
      _items.fold(0, (s, i) => s + i.price * i.quantity);
  double get _tax => 4.50;
  double get _tip => 5.00;
  double get _total => _subtotal + _tax + _tip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDim,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor:
            AppColors.surfaceDim.withValues(alpha: 0.8),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: AppColors.onSurfaceVariant),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "DONATELLO'S PIZZA",
          style: GoogleFonts.anybody(
            color: AppColors.primaryFixed,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline,
                color: AppColors.primaryFixed),
            onPressed: () {},
          ),
        ],
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Order Summary'),
                  const SizedBox(height: 12),
                  ..._items.map(_buildCartItem),
                  const SizedBox(height: 8),
                  _buildAddMoreButton(),
                  const SizedBox(height: 24),
                  _buildDivider(),
                  const SizedBox(height: 24),
                  _sectionTitle('Delivery HQ'),
                  const SizedBox(height: 12),
                  _buildDeliveryCard(),
                  const SizedBox(height: 24),
                  _buildDivider(),
                  const SizedBox(height: 24),
                  _sectionTitle('Funding Source'),
                  const SizedBox(height: 12),
                  _buildPaymentOptions(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _buildCheckoutFooter(),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.hankenGrotesk(
        color: AppColors.secondary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
        color: Colors.white.withValues(alpha: 0.05), thickness: 1, height: 1);
  }

  Widget _buildCartItem(_CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryFixed.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryFixed.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: const Icon(Icons.local_pizza,
                color: AppColors.primaryFixed, size: 36),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.hankenGrotesk(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: GoogleFonts.hankenGrotesk(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: GoogleFonts.hankenGrotesk(
                        color: AppColors.primaryFixed,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    _buildQuantityControl(item),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControl(_CartItem item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QBtn(
            icon: Icons.remove,
            onPressed: () =>
                setState(() => item.quantity > 1 ? item.quantity-- : null),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${item.quantity}',
              style: GoogleFonts.hankenGrotesk(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          _QBtn(
            icon: Icons.add,
            onPressed: () => setState(() => item.quantity++),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMoreButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: TextButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add,
            color: AppColors.onSurfaceVariant, size: 20),
        label: Text(
          'Add More Supplies',
          style: GoogleFonts.hankenGrotesk(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
        style: TextButton.styleFrom(padding: const EdgeInsets.all(12)),
      ),
    );
  }

  Widget _buildDeliveryCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Map placeholder
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryFixed.withValues(alpha: 0.6),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: const Icon(Icons.location_on,
                    color: AppColors.onPrimaryFixed, size: 20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.home,
                    color: AppColors.secondary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sewer Lair Entry #4',
                        style: GoogleFonts.hankenGrotesk(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '122nd St & Broadway, Manhole Cover B',
                        style: GoogleFonts.hankenGrotesk(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Edit',
                    style: GoogleFonts.hankenGrotesk(
                      color: AppColors.primaryFixed,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryContainer.withValues(alpha: 0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryFixed.withValues(alpha: 0.1),
                  blurRadius: 20,
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.credit_card,
                    color: AppColors.primaryContainer, size: 32),
                const SizedBox(height: 6),
                Text(
                  'Shell Card',
                  style: GoogleFonts.hankenGrotesk(
                    color: AppColors.primaryContainer,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Active',
                  style: GoogleFonts.hankenGrotesk(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.monetization_on,
                    color: AppColors.secondary, size: 32),
                const SizedBox(height: 6),
                Text(
                  'Pizza Coins',
                  style: GoogleFonts.hankenGrotesk(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '420 pts',
                  style: GoogleFonts.hankenGrotesk(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutFooter() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
              color: Colors.white.withValues(alpha: 0.05), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding:
          const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CostRow(label: 'Subtotal', amount: _subtotal),
          const SizedBox(height: 6),
          _CostRow(label: 'Hazard Delivery Fee', amount: _tax),
          const SizedBox(height: 6),
          _CostRow(label: 'Ooze Tax', amount: _tip),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(
                color: AppColors.outlineVariant.withValues(alpha: 0.2),
                thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Extraction',
                style: GoogleFonts.hankenGrotesk(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '\$${_total.toStringAsFixed(2)}',
                style: GoogleFonts.anybody(
                  color: AppColors.primaryFixed,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _CheckoutButton(onPressed: () {}),
        ],
      ),
    );
  }
}

class _QBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _QBtn({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: AppColors.onSurfaceVariant, size: 16),
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final double amount;
  const _CostRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.hankenGrotesk(
              color: AppColors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: GoogleFonts.hankenGrotesk(
            color: AppColors.onSurface,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _CheckoutButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _CheckoutButton({required this.onPressed});

  @override
  State<_CheckoutButton> createState() => _CheckoutButtonState();
}

class _CheckoutButtonState extends State<_CheckoutButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
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
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primaryFixed,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryFixed.withValues(alpha: 0.3),
                blurRadius: 20,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SEND TO THE SEWERS',
                style: GoogleFonts.hankenGrotesk(
                  color: AppColors.onPrimaryFixed,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.rocket_launch,
                  color: AppColors.onPrimaryFixed, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
