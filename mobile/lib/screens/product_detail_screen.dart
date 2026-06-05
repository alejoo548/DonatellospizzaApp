import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final String name;
  final String description;
  final double basePrice;
  final String? image;
  final int? categoryId;
  final List<dynamic> options;

  const ProductDetailScreen({
    super.key,
    this.name = "The Splinter Supreme",
    this.description =
        "A masterclass in flavor. Pepperoni, Italian sausage, mushrooms, olives, and a drizzle of secret ooze sauce.",
    this.basePrice = 24.00,
    this.image,
    this.categoryId,
    this.options = const [],
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedSize = 0; // 0=Personal, 1=Medium, 2=Turtle XL
  int _selectedCrust = 0; // 0=NYC Thin, 1=Sewer Deep Dish
  int _quantity = 1;
  bool _isFavorite = false;

  List<dynamic> get _sizes =>
    widget.options.where((o) => o['type'] == 'size').toList();

List<dynamic> get _crusts =>
    widget.options.where((o) => o['type'] == 'crust').toList();

bool get _hasSizes => _sizes.isNotEmpty;
bool get _hasCrusts => _crusts.isNotEmpty;

  double get _total {
  final sizeExtra = _hasSizes
      ? double.parse(_sizes[_selectedSize]['extra_price'].toString())
      : 0.0;

  final crustExtra = _hasCrusts
      ? double.parse(_crusts[_selectedCrust]['extra_price'].toString())
      : 0.0;

  return (widget.basePrice + sizeExtra + crustExtra) * _quantity;
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
        title: Text(
          "DONATELLO'S PIZZA",
          style: GoogleFonts.anybody(
            color: AppColors.primaryFixed,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite
                  ? Colors.redAccent
                  : AppColors.onSurfaceVariant,
            ),
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
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
      _sectionLabel('Size'),
      const SizedBox(height: 10),
      Row(
        children: List.generate(_sizes.length, (i) {
          final s = _sizes[i];
          final selected = _selectedSize == i;
          final extra = double.parse(s['extra_price'].toString());

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedSize = i),
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
      _sectionLabel('Crust Style'),
      const SizedBox(height: 10),
      ...List.generate(_crusts.length, (i) {
        final c = _crusts[i];
        final selected = _selectedCrust == i;
        final extra = double.parse(c['extra_price'].toString());

        return GestureDetector(
          onTap: () => setState(() => _selectedCrust = i),
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
                    color:
                        selected ? AppColors.primaryFixed : Colors.transparent,
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
                onPressed: () => setState(() => _quantity++),
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
        onTap: () => Navigator.pop(context),
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
                Icons.electric_moped,
                color: AppColors.onPrimaryFixed,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'ADD TO MISSION',
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
