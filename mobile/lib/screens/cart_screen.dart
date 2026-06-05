import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_toast.dart';
import '../widgets/brand_logo.dart';
import 'ordering_flow_screen.dart';
import 'payment_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _items = [];

  double get _subtotal => _items.fold(0, (sum, item) {
    return sum + double.parse(item['total_price'].toString());
  });
  double get _total => _subtotal;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await ApiService.getCart();
      if (!mounted) return;
      setState(() {
        _items = data['items'] as List<dynamic>? ?? [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _setQuantity(dynamic item, int quantity) async {
    if (quantity < 1) {
      await _removeItem(item);
      return;
    }

    final previous = List<dynamic>.from(_items);
    setState(() {
      item['quantity'] = quantity;
      item['total_price'] =
          double.parse(item['unit_price'].toString()) * quantity;
    });

    try {
      await ApiService.updateCartItem(
        itemId: item['id'] as int,
        quantity: quantity,
      );
      await _loadCart();
    } catch (e) {
      if (!mounted) return;
      setState(() => _items = previous);
      showAppToast(context, message: e.toString(), type: AppToastType.error);
    }
  }

  Future<void> _removeItem(dynamic item) async {
    final previous = List<dynamic>.from(_items);
    setState(() => _items.remove(item));

    try {
      await ApiService.removeCartItem(item['id'] as int);
    } catch (e) {
      if (!mounted) return;
      setState(() => _items = previous);
      showAppToast(context, message: e.toString(), type: AppToastType.error);
    }
  }

  Future<void> _clearCart() async {
    if (_items.isEmpty) return;

    final previous = List<dynamic>.from(_items);
    setState(() => _items = []);

    try {
      await ApiService.clearCart();
    } catch (e) {
      if (!mounted) return;
      setState(() => _items = previous);
      showAppToast(context, message: e.toString(), type: AppToastType.error);
    }
  }

  void _addMore() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OrderingFlowScreen()),
    ).then((_) => _loadCart());
  }

  void _checkout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PaymentScreen(total: _total)),
    ).then((paid) {
      if (paid == true) {
        _loadCart();
      }
    });
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
            Expanded(
              child: Text(
                "DONATELLO'S PIZZA",
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.anybody(
                  color: AppColors.primaryFixed,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.primaryFixed,
            ),
            onPressed: _items.isEmpty ? null : _clearCart,
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          _buildCheckoutFooter(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _EmptyCartState(
        icon: Icons.error_outline,
        title: 'Could not load cart',
        message: _error!,
        actionLabel: 'Retry',
        onAction: _loadCart,
      );
    }

    if (_items.isEmpty) {
      return _EmptyCartState(
        icon: Icons.shopping_cart_outlined,
        title: 'Your cart is empty',
        message: 'Add products from the menu to start your order.',
        actionLabel: 'Go to Menu',
        onAction: _addMore,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCart,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Order Summary'),
            const SizedBox(height: 12),
            ..._items.map(_buildCartItem),
            const SizedBox(height: 8),
            _buildAddMoreButton(),
          ],
        ),
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

  Widget _buildCartItem(dynamic item) {
    final product = item['product'] as Map<String, dynamic>? ?? {};
    final image = (product['image_url'] ?? product['image'])?.toString();
    final unitPrice = double.parse(item['unit_price'].toString());
    final quantity = item['quantity'] as int;

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
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 80,
              height: 80,
              child: image != null && image.isNotEmpty
                  ? Image.network(
                      ApiService.productImage(image),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imageFallback(),
                    )
                  : _imageFallback(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product['name']?.toString() ?? 'Product',
                        style: GoogleFonts.hankenGrotesk(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.onSurfaceVariant,
                        size: 18,
                      ),
                      onPressed: () => _removeItem(item),
                    ),
                  ],
                ),
                Text(
                  product['description']?.toString() ?? '',
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
                      '\$${unitPrice.toStringAsFixed(2)}',
                      style: GoogleFonts.hankenGrotesk(
                        color: AppColors.primaryFixed,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    _buildQuantityControl(item, quantity),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: AppColors.surfaceContainerHigh,
      child: const Icon(
        Icons.local_pizza,
        color: AppColors.primaryFixed,
        size: 36,
      ),
    );
  }

  Widget _buildQuantityControl(dynamic item, int quantity) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QBtn(
            icon: Icons.remove,
            onPressed: () => _setQuantity(item, quantity - 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$quantity',
              style: GoogleFonts.hankenGrotesk(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          _QBtn(
            icon: Icons.add,
            onPressed: () => _setQuantity(item, quantity + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMoreButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _addMore,
        icon: const Icon(
          Icons.add,
          color: AppColors.onSurfaceVariant,
          size: 20,
        ),
        label: Text(
          'Add More Products',
          style: GoogleFonts.hankenGrotesk(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutFooter() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CostRow(label: 'Subtotal', amount: _subtotal),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(
              color: AppColors.outlineVariant.withValues(alpha: 0.2),
              thickness: 1,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.hankenGrotesk(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
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
          _CheckoutButton(enabled: _items.isNotEmpty, onPressed: _checkout),
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

class _CheckoutButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const _CheckoutButton({required this.enabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: const Icon(Icons.shopping_bag_outlined),
      label: const Text('BUY NOW'),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        backgroundColor: AppColors.primaryFixed,
        foregroundColor: AppColors.onPrimaryFixed,
        textStyle: GoogleFonts.hankenGrotesk(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _EmptyCartState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyCartState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primaryFixed, size: 50),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.anybody(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 22,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.hankenGrotesk(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
