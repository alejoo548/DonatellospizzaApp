import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/app_toast.dart';
import '../widgets/brand_logo.dart';

class ProductDetailScreen extends StatefulWidget {
  final int? productId;
  final String name;
  final String description;
  final double basePrice;
  final String? image;
  final int? categoryId;
  final List<dynamic> options;
  final int stock;

  const ProductDetailScreen({
    super.key,
    this.productId,
    this.name = "The Splinter Supreme",
    this.description =
        "A masterclass in flavor. Pepperoni, Italian sausage, mushrooms, olives, and a drizzle of secret ooze sauce.",
    this.basePrice = 24.00,
    this.image,
    this.categoryId,
    this.options = const [],
    this.stock = 99,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int? _selectedSize;
  int? _selectedCrust;
  int _quantity = 1;
  bool _isFavorite = false;
  bool _loadingFavorite = false;
  bool _savingFavorite = false;
  bool _addingToCart = false;
  bool get _isPizzaCategory => widget.categoryId == 2;

  List<dynamic> get _sizes =>
      widget.options.where((o) => o['type'] == 'size').toList();

  List<dynamic> get _crusts =>
      widget.options.where((o) => o['type'] == 'crust').toList();

  bool get _hasSizes => _sizes.isNotEmpty;
  bool get _hasCrusts => _crusts.isNotEmpty;

  double get _total {
    final sizeExtra = _selectedSize != null
        ? double.parse(_sizes[_selectedSize!]['extra_price'].toString())
        : 0.0;

    final crustExtra = _selectedCrust != null
        ? double.parse(_crusts[_selectedCrust!]['extra_price'].toString())
        : 0.0;

    return (widget.basePrice + sizeExtra + crustExtra) * _quantity;
  }

  @override
  void initState() {
    super.initState();
    _loadFavoriteState();
  }

  Future<void> _loadFavoriteState() async {
    if (widget.productId == null) return;

    setState(() => _loadingFavorite = true);

    try {
      final data = await ApiService.getFavorites();
      final favorites = data['favorites'] as List<dynamic>? ?? [];
      final isFavorite = favorites.any(
        (item) => item['id'] == widget.productId,
      );

      if (!mounted) return;
      setState(() {
        _isFavorite = isFavorite;
        _loadingFavorite = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingFavorite = false);
    }
  }

  Future<void> _toggleFavorite() async {
    if (widget.productId == null || _savingFavorite) return;

    final nextValue = !_isFavorite;
    setState(() {
      _isFavorite = nextValue;
      _savingFavorite = true;
    });

    try {
      if (nextValue) {
        await ApiService.addFavorite(widget.productId!);
      } else {
        await ApiService.removeFavorite(widget.productId!);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isFavorite = !nextValue);
      showAppToast(context, message: e.toString(), type: AppToastType.error);
    } finally {
      if (mounted) {
        setState(() => _savingFavorite = false);
      }
    }
  }

  Future<void> _addToCart() async {
    if (widget.productId == null || _addingToCart) return;

    setState(() => _addingToCart = true);

    try {
      await ApiService.addCartItem(
        productId: widget.productId!,
        quantity: _quantity,
        size: _isPizzaCategory && _selectedSize != null
            ? _sizes[_selectedSize!]['name']?.toString()
            : null,
        crust: _isPizzaCategory && _selectedCrust != null
            ? _crusts[_selectedCrust!]['name']?.toString()
            : null,
      );

      if (!mounted) return;
      showAppToast(
        context,
        message: 'Product added to cart.',
        type: AppToastType.success,
      );
    } catch (e) {
      if (!mounted) return;
      showAppToast(context, message: e.toString(), type: AppToastType.error);
    } finally {
      if (mounted) {
        setState(() => _addingToCart = false);
      }
    }
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
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: _loadingFavorite || _savingFavorite
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite
                        ? Colors.redAccent
                        : AppColors.onSurfaceVariant,
                  ),
            onPressed: _loadingFavorite || _savingFavorite
                ? null
                : _toggleFavorite,
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroImage(),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProductInfo(),
                        const SizedBox(height: 28),
                        if (_hasSizes) ...[
                          _buildSizeSelector(),
                          const SizedBox(height: 24),
                        ],

                        if (_hasCrusts) ...[
                          _buildCrustSelector(),
                          const SizedBox(height: 24),
                        ],
                        _buildQuantityControl(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildAddToMissionButton(),
        ],
      ),
    );
  }

  Widget _buildHeroImage() {
    final imageUrl = widget.image != null && widget.image!.isNotEmpty
        ? ApiService.productImage(widget.image!)
        : null;

    return Container(
      height: 240,
      width: double.infinity,
      color: AppColors.surfaceContainerHigh,
      child: imageUrl != null
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.image_not_supported,
                  size: 120,
                  color: AppColors.primaryFixed.withValues(alpha: 0.4),
                );
              },
            )
          : Icon(
              Icons.local_pizza,
              size: 120,
              color: AppColors.primaryFixed.withValues(alpha: 0.4),
            ),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                widget.name,
                style: GoogleFonts.anybody(
                  color: AppColors.primary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '\$${widget.basePrice.toStringAsFixed(2)}',
              style: GoogleFonts.anybody(
                color: AppColors.primaryFixed,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          widget.description,
          style: GoogleFonts.hankenGrotesk(
            color: AppColors.onSurfaceVariant,
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Complementary size'),
        const SizedBox(height: 10),
        Row(
          children: List.generate(_sizes.length, (i) {
            final s = _sizes[i];
            final selected = _selectedSize == i;
            final extra = double.parse(s['extra_price'].toString());

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _selectedSize = selected ? null : i;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: EdgeInsets.only(right: i < _sizes.length - 1 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryFixed.withValues(alpha: 0.15)
                        : AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? AppColors.primaryFixed
                          : AppColors.outlineVariant.withValues(alpha: 0.3),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.local_pizza,
                        color: selected
                            ? AppColors.primaryFixed
                            : AppColors.onSurfaceVariant,
                        size: 20 + i * 4.0,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s['name'].toString(),
                        style: GoogleFonts.hankenGrotesk(
                          color: selected
                              ? AppColors.primaryFixed
                              : AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (extra > 0)
                        Text(
                          '+\$${extra.toStringAsFixed(2)}',
                          style: GoogleFonts.hankenGrotesk(
                            color: AppColors.secondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCrustSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Complementary crust'),
        const SizedBox(height: 10),
        ...List.generate(_crusts.length, (i) {
          final c = _crusts[i];
          final selected = _selectedCrust == i;
          final extra = double.parse(c['extra_price'].toString());

          return GestureDetector(
            onTap: () => setState(() {
              _selectedCrust = selected ? null : i;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primaryFixed.withValues(alpha: 0.1)
                    : AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected
                      ? AppColors.primaryFixed
                      : AppColors.outlineVariant.withValues(alpha: 0.3),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? AppColors.primaryFixed
                            : AppColors.outline,
                        width: 1.5,
                      ),
                      color: selected
                          ? AppColors.primaryFixed
                          : Colors.transparent,
                    ),
                    child: selected
                        ? const Icon(
                            Icons.check,
                            color: AppColors.onPrimaryFixed,
                            size: 11,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      c['name'].toString(),
                      style: GoogleFonts.hankenGrotesk(
                        color: selected
                            ? AppColors.onSurface
                            : AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (extra > 0)
                    Text(
                      '+ \$${extra.toStringAsFixed(2)}',
                      style: GoogleFonts.hankenGrotesk(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuantityControl() {
    return Row(
      children: [
        _sectionLabel('Quantity'),
        const Spacer(),
        Container(
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
              IconButton(
                icon: const Icon(
                  Icons.remove,
                  color: AppColors.onSurfaceVariant,
                  size: 18,
                ),
                onPressed: () =>
                    setState(() => _quantity > 1 ? _quantity-- : null),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$_quantity',
                  style: GoogleFonts.anybody(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add,
                  color: AppColors.onSurfaceVariant,
                  size: 18,
                ),
                onPressed: () => setState(() { if (_quantity < widget.stock) _quantity++; }),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.hankenGrotesk(
        color: AppColors.onSurfaceVariant,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildAddToMissionButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: GestureDetector(
        onTap: _addingToCart ? null : _addToCart,
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
              const Icon(
                Icons.shopping_cart,
                color: AppColors.onPrimaryFixed,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                _addingToCart ? 'ADDING...' : 'ADD TO MISSION',
                style: GoogleFonts.hankenGrotesk(
                  color: AppColors.onPrimaryFixed,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.onPrimaryFixed.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '\$${_total.toStringAsFixed(2)}',
                  style: GoogleFonts.anybody(
                    color: AppColors.onPrimaryFixed,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
