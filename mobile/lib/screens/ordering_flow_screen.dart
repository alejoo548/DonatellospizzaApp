import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'favorites_screen.dart';
import 'products_screen.dart';
import 'profile_screen.dart';
import '../services/api_service.dart';

class OrderingFlowScreen extends StatefulWidget {
  const OrderingFlowScreen({super.key});

  @override
  State<OrderingFlowScreen> createState() => _OrderingFlowScreenState();
}

class _OrderingFlowScreenState extends State<OrderingFlowScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilter = 0;
  int _navIndex = 1;
  String _searchQuery = '';
  bool _isSearching = false;

  bool _loading = true;
  String? _error;
  List<dynamic> _categories = [];
  List<dynamic> _products = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  List<dynamic> get _filteredProducts {
    if (_selectedFilter == 0) return _products;

    final selectedCategory = _categories[_selectedFilter - 1];

    return _products.where((product) {
      return product['category_id'] == selectedCategory['id'];
    }).toList();
  }

  Future<void> _loadMenu() async {
    try {
      final categoriesData = await ApiService.getCategories();
      final productsData = await ApiService.getProducts();

      setState(() {
        _categories = categoriesData['categories'] ?? [];
        _products = productsData['products'] ?? [];
        _error = null;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _openProductDetail(dynamic item, double price) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          productId: item['id'] as int?,
          name: item['name'],
          description: item['description'],
          basePrice: price,
          image: (item['image_url'] ?? item['image'])?.toString(),
          categoryId: item['category_id'],
          options: item['options'] ?? [],
          stock: (item['stock'] as int?) ?? 99,
        ),
      ),
    );
  }

  void _goBack() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ProductsScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _filteredProducts.where((product) {
      final name = product['name'].toString().toLowerCase();
      final description = product['description'].toString().toLowerCase();

      return name.contains(_searchQuery) || description.contains(_searchQuery);
    }).toList();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goBack();
      },
      child: Scaffold(
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
                      if (_loading)
                        const Center(child: CircularProgressIndicator())
                      else if (_error != null)
                        _MenuError(message: _error!, onRetry: _loadMenu)
                      else if (filteredProducts.isEmpty)
                        _EmptyMenuState(
                          searching: _searchQuery.isNotEmpty,
                          onClearSearch: () {
                            setState(() {
                              _isSearching = false;
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      else
                        ...filteredProducts.map(_buildMenuItem),
                      const SizedBox(height: 24),
                      _buildPromoBanner(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
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
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.onSurfaceVariant,
            ),
            onPressed: _goBack,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _isSearching ? _buildTopSearchField() : _buildTopTitle(),
          ),
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search_outlined,
              color: AppColors.onSurfaceVariant,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;

                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTitle() {
    return Row(
      children: [
        const BrandLogo(size: 34, compact: true),
        const SizedBox(width: 10),
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
    );
  }

  Widget _buildTopSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      onChanged: (value) {
        setState(() {
          _searchQuery = value.trim().toLowerCase();
        });
      },
      style: GoogleFonts.hankenGrotesk(
        color: AppColors.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Search products',
        hintStyle: GoogleFonts.hankenGrotesk(
          color: AppColors.onSurfaceVariant,
          fontSize: 14,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.primaryFixed,
          size: 18,
        ),
        filled: true,
        fillColor: AppColors.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColors.primaryFixed.withValues(alpha: 0.25),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryFixed),
        ),
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
    final tabs = [
      {'id': 0, 'name': 'All'},
      ..._categories,
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final selected = _selectedFilter == i;

          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primaryFixed
                    : AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                tabs[i]['name'].toString(),
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

  Widget _buildMenuItem(dynamic item) {
    final price = double.parse(item['price'].toString());
    final image = (item['image_url'] ?? item['image'])?.toString();
    final imageUrl = image != null ? ApiService.productImage(image) : null;
    return GestureDetector(
      onTap: () => _openProductDetail(item, price),
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image_not_supported,
                            color: AppColors.primaryFixed.withValues(
                              alpha: 0.4,
                            ),
                            size: 36,
                          );
                        },
                      )
                    : Icon(
                        Icons.image_not_supported,
                        color: AppColors.primaryFixed.withValues(alpha: 0.4),
                        size: 36,
                      ),
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
                          item['name'],
                          style: GoogleFonts.hankenGrotesk(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['description'],
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
                        '\$${price.toStringAsFixed(2)}',
                        style: GoogleFonts.anybody(
                          color: AppColors.primaryFixed,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _openProductDetail(item, price),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primaryFixed.withValues(
                                alpha: 0.3,
                              ),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.shopping_cart_outlined,
                                color: AppColors.primaryFixed,
                                size: 14,
                              ),
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

  Widget _buildPromoBanner() {
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
                  'Cowabunga!',
                  style: GoogleFonts.anybody(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fresh out of the oven!',
                  style: GoogleFonts.hankenGrotesk(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                  '100%',
                  style: GoogleFonts.anybody(
                    color: AppColors.onPrimaryFixed,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'FRESH',
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
      (Icons.favorite_border, Icons.favorite, 'Favorites'),
      (Icons.person_outline, Icons.person, 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  } else if (i == 3) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FavoritesScreen(),
                      ),
                    );
                  } else if (i == 4) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
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

class _MenuError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _MenuError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: AppColors.secondary, size: 32),
          const SizedBox(height: 10),
          Text(
            'Could not load menu',
            style: GoogleFonts.hankenGrotesk(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.hankenGrotesk(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _EmptyMenuState extends StatelessWidget {
  final bool searching;
  final VoidCallback onClearSearch;

  const _EmptyMenuState({required this.searching, required this.onClearSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off, color: AppColors.secondary, size: 36),
          const SizedBox(height: 10),
          Text(
            searching ? 'No products found' : 'No products available',
            style: GoogleFonts.hankenGrotesk(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            searching
                ? 'Try another name or clear the search.'
                : 'Please try again in a moment.',
            textAlign: TextAlign.center,
            style: GoogleFonts.hankenGrotesk(
              color: AppColors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          if (searching) ...[
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onClearSearch,
              child: const Text('Clear Search'),
            ),
          ],
        ],
      ),
    );
  }
}
