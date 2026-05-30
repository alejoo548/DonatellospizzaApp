import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';
import 'ordering_flow_screen.dart';

class _Product {
  final String name;
  final String description;
  final double price;
  final bool isBestSeller;
  final bool isNew;

  const _Product({
    required this.name,
    required this.description,
    required this.price,
    this.isBestSeller = false,
    this.isNew = false,
  });
}

const _categories = ['All Missions', 'Classics', 'Ninja Specials', 'Sides & Drinks'];

const _products = [
  _Product(
    name: "Splinter's Margherita",
    description: 'Fresh basil, mozzarella, signature red sauce',
    price: 14.00,
  ),
  _Product(
    name: 'The Foot Clan Meat',
    description: 'Pepperoni, sausage, ham, bacon, beef',
    price: 18.00,
    isBestSeller: true,
  ),
  _Product(
    name: 'The Shredder Special',
    description: 'Extra jalapeños, spicy sausage, hot honey drizzle',
    price: 24.00,
    isNew: true,
  ),
  _Product(
    name: 'Mutagen Knots',
    description: 'Garlic butter, parmesan dust, ooze dip',
    price: 8.50,
  ),
  _Product(
    name: 'Classic Cowabunga',
    description: 'Double pepperoni, rich tomato sauce, cheese blend',
    price: 18.50,
  ),
  _Product(
    name: 'Leo\'s Veggie Slice',
    description: 'Mushrooms, bell peppers, spinach, artichoke',
    price: 13.00,
  ),
];

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  int _selectedCategory = 0;
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDim,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHero(),
                    _buildActiveOrderBanner(),
                    const SizedBox(height: 24),
                    _buildCategories(),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Recommended',
                        style: GoogleFonts.anybody(
                          color: AppColors.onSurface,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildProductGrid(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDim.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            "DONATELLO'S PIZZA",
            style: GoogleFonts.anybody(
              color: AppColors.primaryFixed,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              fontStyle: FontStyle.italic,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search_outlined,
                color: AppColors.onSurfaceVariant),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.onSurfaceVariant),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryFixed.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryFixed.withValues(alpha: 0.08),
            blurRadius: 20,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pizza icon (decorative)
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.local_pizza,
              size: 180,
              color: AppColors.primaryFixed.withValues(alpha: 0.06),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department,
                          color: AppColors.secondary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'New Arrival',
                        style: GoogleFonts.hankenGrotesk(
                          color: AppColors.secondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'The Sewer Supreme',
                  style: GoogleFonts.anybody(
                    color: AppColors.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pepperoni, sausage, green peppers,\nonions, and extra ooze cheese',
                  style: GoogleFonts.hankenGrotesk(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      '\$22.00',
                      style: GoogleFonts.anybody(
                        color: AppColors.primaryFixed,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.primaryFixed.withValues(alpha: 0.3),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Text(
                          'Order Now',
                          style: GoogleFonts.hankenGrotesk(
                            color: AppColors.onPrimaryFixed,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrderBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryFixed.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined,
              color: AppColors.primaryFixed, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mission Active — Est. 15 mins',
                  style: GoogleFonts.hankenGrotesk(
                    color: AppColors.primaryFixed,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Turtle Van is on the way',
                  style: GoogleFonts.hankenGrotesk(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right,
              color: AppColors.onSurfaceVariant, size: 20),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final selected = _selectedCategory == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primaryFixed
                    : AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected
                      ? AppColors.primaryFixed
                      : AppColors.outlineVariant.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryFixed.withValues(alpha: 0.25),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                _categories[i],
                style: GoogleFonts.hankenGrotesk(
                  color: selected
                      ? AppColors.onPrimaryFixed
                      : AppColors.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: _products.length,
      itemBuilder: (context, i) => GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              name: _products[i].name,
              description: _products[i].description,
              basePrice: _products[i].price,
            ),
          ),
        ),
        child: _ProductCard(product: _products[i]),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      (Icons.home_outlined, Icons.home, 'Home'),
      (Icons.restaurant_menu_outlined, Icons.restaurant_menu, 'Menu'),
      (Icons.shopping_cart_outlined, Icons.shopping_cart, 'Cart'),
      (Icons.person_outline, Icons.person, 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
              color: Colors.white.withValues(alpha: 0.05), width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = _navIndex == i;
              return GestureDetector(
                onTap: () {
                  if (i == 2) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CartScreen()));
                  } else if (i == 1) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const OrderingFlowScreen()));
                  } else {
                    setState(() => _navIndex = i);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      selected ? items[i].$2 : items[i].$1,
                      color: selected
                          ? AppColors.primaryFixed
                          : AppColors.onSurfaceVariant,
                      size: 24,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      items[i].$3,
                      style: GoogleFonts.hankenGrotesk(
                        color: selected
                            ? AppColors.primaryFixed
                            : AppColors.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final _Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryFixed.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12)),
                  ),
                  child: Icon(
                    Icons.local_pizza,
                    size: 60,
                    color: AppColors.primaryFixed.withValues(alpha: 0.3),
                  ),
                ),
                if (product.isBestSeller)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _Badge(
                        label: 'Best Seller', color: AppColors.secondary),
                  ),
                if (product.isNew)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _Badge(
                        label: 'New',
                        color: AppColors.primaryFixed,
                        textColor: AppColors.onPrimaryFixed),
                  ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest
                          .withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border,
                        color: AppColors.onSurfaceVariant, size: 16),
                  ),
                ),
              ],
            ),
          ),
          // Info area
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.hankenGrotesk(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.hankenGrotesk(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(0)}',
                      style: GoogleFonts.anybody(
                        color: AppColors.primaryFixed,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryFixed
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add,
                            color: AppColors.onPrimaryFixed, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  const _Badge({required this.label, required this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.hankenGrotesk(
          color: textColor ?? color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
