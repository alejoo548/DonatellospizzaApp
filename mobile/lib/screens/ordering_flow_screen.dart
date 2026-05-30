import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';

class _MenuItem {
  final String name;
  final String description;
  final double price;
  final bool isBestSeller;
  final bool isSpicy;

  const _MenuItem({
    required this.name,
    required this.description,
    required this.price,
    this.isBestSeller = false,
    this.isSpicy = false,
  });
}

const _menuItems = [
  _MenuItem(
    name: 'Katana Pepperoni',
    description: 'Double-sliced pepperoni, aged mozzarella, signature tomato reduction',
    price: 24.00,
    isBestSeller: true,
  ),
  _MenuItem(
    name: "Splinter's Veggie",
    description: 'Roasted peppers, mushrooms, olives, basil',
    price: 22.00,
  ),
  _MenuItem(
    name: "Shredder's Heat",
    description: 'Spicy sausage, jalapeños, habanero honey, four cheeses',
    price: 26.00,
    isSpicy: true,
  ),
  _MenuItem(
    name: 'Technodrome Classic',
    description: 'Simple perfection. Buffalo mozzarella, heirloom tomatoes, olive oil',
    price: 19.00,
  ),
];

const _filterTabs = ['All Meat', 'Veggie', 'Spicy'];

class OrderingFlowScreen extends StatefulWidget {
  const OrderingFlowScreen({super.key});

  @override
  State<OrderingFlowScreen> createState() => _OrderingFlowScreenState();
}

class _OrderingFlowScreenState extends State<OrderingFlowScreen> {
  int _selectedFilter = 0;
  int _navIndex = 1;

  List<_MenuItem> get _filteredItems {
    switch (_selectedFilter) {
      case 1:
        return _menuItems.where((m) => !m.isSpicy && m.name.toLowerCase().contains('veggi')).toList();
      case 2:
        return _menuItems.where((m) => m.isSpicy).toList();
      default:
        return _menuItems;
    }
  }

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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildHeroHeader(),
                    const SizedBox(height: 20),
                    _buildFilterChips(),
                    const SizedBox(height: 20),
                    ..._filteredItems.map(_buildMenuItem),
                    const SizedBox(height: 24),
                    _buildDeliveryBanner(),
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
              color: Colors.white.withValues(alpha: 0.05), width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back,
                color: AppColors.onSurfaceVariant),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Text(
            "DONATELLO'S PIZZA",
            style: GoogleFonts.anybody(
              color: AppColors.primaryFixed,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              fontStyle: FontStyle.italic,
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
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "The Master's Menu",
          style: GoogleFonts.anybody(
            color: AppColors.primary,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Refined recipes from the sewers to the surface',
          style: GoogleFonts.hankenGrotesk(
            color: AppColors.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filterTabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final selected = _selectedFilter == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
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
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color:
                              AppColors.primaryFixed.withValues(alpha: 0.25),
                          blurRadius: 10,
                        )
                      ]
                    : null,
              ),
              child: Text(
                _filterTabs[i],
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

  Widget _buildMenuItem(_MenuItem item) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(
            name: item.name,
            description: item.description,
            basePrice: item.price,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryFixed.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.local_pizza,
                color: AppColors.primaryFixed.withValues(alpha: 0.4),
                size: 36,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: GoogleFonts.hankenGrotesk(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (item.isBestSeller)
                        _Chip(
                            label: 'Best Seller',
                            color: AppColors.secondary),
                      if (item.isSpicy)
                        _Chip(
                            label: '🌶 Spicy',
                            color: const Color(0xFFFF6B35)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.hankenGrotesk(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: GoogleFonts.anybody(
                          color: AppColors.primaryFixed,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(
                              name: item.name,
                              description: item.description,
                              basePrice: item.price,
                            ),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primaryFixed
                                  .withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.shopping_cart_outlined,
                                  color: AppColors.primaryFixed, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'Add to Order',
                                style: GoogleFonts.hankenGrotesk(
                                  color: AppColors.primaryFixed,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildDeliveryBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryFixed.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryFixed.withValues(alpha: 0.06),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Midnight Delivery?',
                  style: GoogleFonts.anybody(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Turtle Van available 24/7',
                  style: GoogleFonts.hankenGrotesk(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryFixed.withValues(alpha: 0.3),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '20-30',
                  style: GoogleFonts.anybody(
                    color: AppColors.onPrimaryFixed,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'MIN',
                  style: GoogleFonts.hankenGrotesk(
                    color: AppColors.onPrimaryFixed,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
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

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.hankenGrotesk(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
