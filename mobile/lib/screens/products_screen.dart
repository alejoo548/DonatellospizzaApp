import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';
import '../theme/app_theme.dart';
import '../widgets/app_toast.dart';
import '../widgets/brand_logo.dart';
import 'cart_screen.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'product_detail_screen.dart';
import 'ordering_flow_screen.dart';
import 'profile_screen.dart';
import 'purchase_history_screen.dart';
import '../widgets/promo_carousel.dart';

class _Product {
  final int? id;
  final String name;
  final String description;
  final double price;
  final String? image;
  final int? categoryId;
  final List<dynamic> options;
  final bool isBestSeller;
  final bool isNew;
  final int stock;

  const _Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    this.image,
    this.categoryId,
    this.options = const [],
    this.isBestSeller = false,
    this.isNew = false,
    this.stock = 99,
  });

  factory _Product.fromJson(Map<String, dynamic> json) {
    return _Product(
      id: json['id'] as int?,
      name: json['name']?.toString() ?? 'Product',
      description: json['description']?.toString() ?? '',
      price: double.parse(json['price'].toString()),
      image: (json['image_url'] ?? json['image'])?.toString(),
      categoryId: json['category_id'] as int?,
      options: json['options'] as List<dynamic>? ?? [],
      stock: (json['stock'] as int?) ?? 99,
    );
  }
}

class _MenuCategory {
  final int? id;
  final String name;

  const _MenuCategory({this.id, required this.name});

  factory _MenuCategory.fromJson(Map<String, dynamic> json) {
    return _MenuCategory(
      id: json['id'] as int?,
      name: json['name']?.toString() ?? 'Category',
    );
  }
}


class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchController = TextEditingController();
  int _selectedCategory = 0;
  int _navIndex = 0;
  bool _isSearching = false;
  bool _loadingProducts = true;
  String? _loadError;
  String _searchQuery = '';
  List<_Product> _products = [];
  List<_MenuCategory> _categories = const [_MenuCategory(name: 'All')];
  List<dynamic> _carouselItems = [];

  List<_Product> get _visibleProducts {
    Iterable<_Product> products = _products;

    if (_selectedCategory > 0 && _selectedCategory < _categories.length) {
      final categoryId = _categories[_selectedCategory].id;
      products = products.where((product) => product.categoryId == categoryId);
    }

    if (_searchQuery.isEmpty) return products.toList();

    return products.where((product) {
      final name = product.name.toLowerCase();
      final description = product.description.toLowerCase();
      return name.contains(_searchQuery) || description.contains(_searchQuery);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final results = await Future.wait([
        ApiService.getProducts(),
        ApiService.getCategories(),
      ]);
      final data = results[0];
      final categoriesData = results[1];
      final items = data['products'] as List<dynamic>? ?? [];
      final categoryItems =
          categoriesData['categories'] as List<dynamic>? ?? [];
      if (!mounted) return;
      setState(() {
        _products = items
            .map((item) => _Product.fromJson(item as Map<String, dynamic>))
            .toList();
        _categories = [
          const _MenuCategory(name: 'All'),
          ...categoryItems.map(
            (item) => _MenuCategory.fromJson(item as Map<String, dynamic>),
          ),
        ];
        if (_selectedCategory >= _categories.length) {
          _selectedCategory = 0;
        }
        _loadingProducts = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _loadingProducts = false;
      });
    }

    // Carousel loads independently — failure doesn't affect home
    try {
      final carouselData = await ApiService.getCarousel();
      if (!mounted) return;
      setState(() => _carouselItems = carouselData['carousel'] ?? []);
    } catch (_) {}
  }

  Future<void> _signOut() async {
    await SessionManager.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.surfaceDim,
      endDrawer: _buildDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: _isSearching
                  ? _buildSearchResultsView()
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_carouselItems.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                              child: PromoCarousel(
                                items: _carouselItems,
                                onOrderNow: _openCarouselItem,
                              ),
                            )
                          else if (!_loadingProducts && _products.isNotEmpty)
                            _buildHero(_products.first),
                          const SizedBox(height: 22),
                          _buildCategories(),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Our Menu',
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

  Widget _buildSearchResultsView() {
    final hasQuery = _searchQuery.isNotEmpty;
    final results = hasQuery ? _visibleProducts : <_Product>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: [
        Text(
          hasQuery ? 'Search Results' : 'Search the menu',
          style: GoogleFonts.anybody(
            color: AppColors.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          hasQuery
              ? '${results.length} item${results.length == 1 ? '' : 's'} found'
              : 'Start typing to find pizzas, sides, and drinks.',
          style: GoogleFonts.hankenGrotesk(
            color: AppColors.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        if (_loadingProducts)
          const Center(child: CircularProgressIndicator())
        else if (!hasQuery)
          _SearchHintCard(onOpenMenu: _openMenu)
        else if (results.isEmpty)
          _SearchEmptyCard(
            onClear: () {
              setState(() {
                _searchController.clear();
                _searchQuery = '';
              });
            },
          )
        else
          ...results.map(_buildSearchResultItem),
      ],
    );
  }

  void _openMenu() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OrderingFlowScreen()),
    );
  }

  Widget _buildSearchResultItem(_Product product) {
    return GestureDetector(
      onTap: () => _openProduct(product),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 68,
                height: 68,
                child: product.image != null && product.image!.isNotEmpty
                    ? Image.network(
                        ApiService.productImage(product.image!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _pizzaPlaceholder(),
                      )
                    : _pizzaPlaceholder(),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.hankenGrotesk(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.hankenGrotesk(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: GoogleFonts.anybody(
                          color: AppColors.primaryFixed,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.onSurfaceVariant,
                        size: 20,
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

  Widget _pizzaPlaceholder() {
    return Container(
      color: AppColors.surfaceContainerHigh,
      child: const Icon(
        Icons.local_pizza,
        color: AppColors.primaryFixed,
        size: 34,
      ),
    );
  }

  void _openCarouselItem(dynamic item) {
    final price = item['price'] != null
        ? double.tryParse(item['price'].toString()) ?? 0.0
        : 0.0;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          productId: item['product_id'] as int?,
          name: item['title'],
          description: item['description'],
          basePrice: price,
          image: (item['image_url'] ?? item['image'])?.toString(),
          categoryId: item['category_id'],
          stock: (item['stock'] as int?) ?? 99,
        ),
      ),
    );
  }

  void _openProduct(_Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          productId: product.id,
          name: product.name,
          description: product.description,
          basePrice: product.price,
          image: product.image,
          categoryId: product.categoryId,
          options: product.options,
          stock: product.stock,
        ),
      ),
    );
  }

  Future<void> _addProductToCart(_Product product) async {
    if (product.id == null) return;

    try {
      await ApiService.addCartItem(productId: product.id!, quantity: 1);
      if (!mounted) return;
      showAppToast(
        context,
        message: 'Product added to cart.',
        type: AppToastType.success,
      );
    } catch (e) {
      if (!mounted) return;
      showAppToast(context, message: e.toString(), type: AppToastType.error);
    }
  }

  Widget _buildDrawer() {
    final user = SessionManager.user;
    final name = user?['name'] as String? ?? 'Guest';
    final lastname = user?['lastname'] as String? ?? '';
    final email = user?['email'] as String? ?? '';

    return Drawer(
      backgroundColor: AppColors.surfaceContainerHighest,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrandLogo(size: 72),
                  const SizedBox(height: 12),
                  Text(
                    '$name $lastname'.trim(),
                    style: GoogleFonts.hankenGrotesk(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  if (email.isNotEmpty)
                    Text(
                      email,
                      style: GoogleFonts.hankenGrotesk(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),

            // Menu items
            const SizedBox(height: 8),
            _DrawerItem(
              icon: Icons.home_outlined,
              label: 'Home',
              onTap: () => Navigator.pop(context),
            ),
            _DrawerItem(
              icon: Icons.restaurant_menu_outlined,
              label: 'Menu',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrderingFlowScreen()),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.shopping_cart_outlined,
              label: 'Cart',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.favorite_border,
              label: 'Favorites',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.receipt_long_outlined,
              label: 'Purchase History',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PurchaseHistoryScreen(),
                  ),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.person_outline,
              label: 'Profile',
              onTap: () => Navigator.pop(context),
            ),

            const Spacer(),

            // Divider
            Divider(color: Colors.white.withValues(alpha: 0.05)),

            // Sign out
            _DrawerItem(
              icon: Icons.logout,
              label: 'Sign Out',
              color: Colors.red.shade400,
              onTap: () {
                Navigator.pop(context);
                _signOut();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
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
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.onSurfaceVariant),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
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
              letterSpacing: -0.3,
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
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Search products',
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

  Widget _buildHero(_Product featured) {
    final imageUrl = featured.image != null && featured.image!.isNotEmpty
        ? ApiService.productImage(featured.image!)
        : null;

    return GestureDetector(
      onTap: () => _openProduct(featured),
      child: Container(
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
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Positioned.fill(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                ),
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      Colors.transparent,
                      AppColors.surfaceDim.withValues(alpha: 0.92),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          color: AppColors.secondary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Featured',
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
                    featured.name,
                    style: GoogleFonts.anybody(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    featured.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                        '\$${featured.price.toStringAsFixed(2)}',
                        style: GoogleFonts.anybody(
                          color: AppColors.primaryFixed,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryFixed.withValues(alpha: 0.3),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                _categories[i].name,
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
    if (_loadingProducts) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              const Icon(Icons.wifi_off, color: AppColors.secondary, size: 36),
              const SizedBox(height: 10),
              Text('Could not load products', style: GoogleFonts.hankenGrotesk(color: AppColors.onSurface, fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 6),
              Text('Check your connection and try again.', textAlign: TextAlign.center, style: GoogleFonts.hankenGrotesk(color: AppColors.onSurfaceVariant, fontSize: 13)),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () { setState(() { _loadError = null; _loadingProducts = true; }); _loadProducts(); },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_visibleProducts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
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
              const Icon(
                Icons.search_off,
                color: AppColors.secondary,
                size: 36,
              ),
              const SizedBox(height: 10),
              Text(
                'No products found',
                style: GoogleFonts.hankenGrotesk(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Try another name or clear the search.',
                textAlign: TextAlign.center,
                style: GoogleFonts.hankenGrotesk(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                    _isSearching = false;
                  });
                },
                child: const Text('Clear Search'),
              ),
            ],
          ),
        ),
      );
    }

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
      itemCount: _visibleProducts.length,
      itemBuilder: (context, i) => GestureDetector(
        onTap: () => _openProduct(_visibleProducts[i]),
        child: _ProductCard(
          product: _visibleProducts[i],
          onAdd: () => _addProductToCart(_visibleProducts[i]),
        ),
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
                  if (i == 1) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderingFlowScreen()));
                  } else if (i == 2) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                  } else if (i == 3) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()));
                  } else if (i == 4) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
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

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.onSurface;
    return ListTile(
      leading: Icon(icon, color: c, size: 22),
      title: Text(
        label,
        style: GoogleFonts.hankenGrotesk(
          color: c,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class _SearchHintCard extends StatelessWidget {
  final VoidCallback onOpenMenu;

  const _SearchHintCard({required this.onOpenMenu});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryFixed.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.search, color: AppColors.primaryFixed, size: 36),
          const SizedBox(height: 10),
          Text(
            'Type to search products',
            textAlign: TextAlign.center,
            style: GoogleFonts.hankenGrotesk(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Results will appear here as a menu-style list.',
            textAlign: TextAlign.center,
            style: GoogleFonts.hankenGrotesk(
              color: AppColors.onSurfaceVariant,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onOpenMenu,
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('Open Full Menu'),
          ),
        ],
      ),
    );
  }
}

class _SearchEmptyCard extends StatelessWidget {
  final VoidCallback onClear;

  const _SearchEmptyCard({required this.onClear});

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
            'No products found',
            textAlign: TextAlign.center,
            style: GoogleFonts.hankenGrotesk(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try another name or clear the search.',
            textAlign: TextAlign.center,
            style: GoogleFonts.hankenGrotesk(
              color: AppColors.onSurfaceVariant,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: onClear, child: const Text('Clear Search')),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final _Product product;
  final VoidCallback onAdd;

  const _ProductCard({required this.product, required this.onAdd});

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
          SizedBox(
            height: 118,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: SizedBox.expand(
                    child: product.image != null && product.image!.isNotEmpty
                        ? Image.network(
                            ApiService.productImage(product.image!),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const _ProductImageFallback(),
                            loadingBuilder: (_, child, progress) {
                              if (progress == null) return child;
                              return const _ProductImageFallback();
                            },
                          )
                        : const _ProductImageFallback(),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.surfaceDim.withValues(alpha: 0.52),
                        ],
                      ),
                    ),
                  ),
                ),
                if (product.isBestSeller)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _Badge(
                      label: 'Best Seller',
                      color: AppColors.secondary,
                    ),
                  ),
                if (product.isNew)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _Badge(
                      label: 'New',
                      color: AppColors.primaryFixed,
                      textColor: AppColors.onPrimaryFixed,
                    ),
                  ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest.withValues(
                        alpha: 0.8,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      color: AppColors.onSurfaceVariant,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                  const SizedBox(height: 4),
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
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: GoogleFonts.anybody(
                          color: AppColors.primaryFixed,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: onAdd,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryFixed.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add,
                            color: AppColors.onPrimaryFixed,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductImageFallback extends StatelessWidget {
  const _ProductImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerHigh,
      alignment: Alignment.center,
      child: Icon(
        Icons.local_pizza,
        size: 46,
        color: AppColors.primaryFixed.withValues(alpha: 0.35),
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
