import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_toast.dart';
import '../widgets/brand_logo.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await ApiService.getFavorites();
      if (!mounted) return;
      setState(() {
        _favorites = data['favorites'] as List<dynamic>? ?? [];
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

  Future<void> _removeFavorite(dynamic item) async {
    final id = item['id'] as int;
    final index = _favorites.indexOf(item);

    setState(() => _favorites.removeAt(index));

    try {
      await ApiService.removeFavorite(id);
    } catch (e) {
      if (!mounted) return;
      setState(() => _favorites.insert(index, item));
      showAppToast(context, message: e.toString(), type: AppToastType.error);
    }
  }

  Future<void> _addToCart(dynamic item) async {
    try {
      final isPizza = item['category_id'] == 2;
      await ApiService.addCartItem(
        productId: item['id'] as int,
        quantity: 1,
        size: isPizza ? 'Medium' : null,
        crust: isPizza ? 'NYC Thin Crust' : null,
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
    }
  }

  void _openDetail(dynamic item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          productId: item['id'] as int?,
          name: item['name'],
          description: item['description'],
          basePrice: double.parse(item['price'].toString()),
          image: item['image'],
          categoryId: item['category_id'],
        ),
      ),
    ).then((_) => _loadFavorites());
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
              'Favorites',
              style: GoogleFonts.anybody(
                color: AppColors.primaryFixed,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryFixed),
            onPressed: _loadFavorites,
          ),
        ],
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _EmptyState(
        icon: Icons.error_outline,
        title: 'Could not load favorites',
        message: _error!,
        actionLabel: 'Retry',
        onAction: _loadFavorites,
      );
    }

    if (_favorites.isEmpty) {
      return _EmptyState(
        icon: Icons.favorite_border,
        title: 'No favorites yet',
        message: 'Tap the heart on a product to save it here.',
        actionLabel: 'Back to Menu',
        onAction: () => Navigator.pop(context),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _favorites.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _FavoriteCard(
          item: _favorites[index],
          onOpen: () => _openDetail(_favorites[index]),
          onRemove: () => _removeFavorite(_favorites[index]),
          onAddToCart: () => _addToCart(_favorites[index]),
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback onOpen;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;

  const _FavoriteCard({
    required this.item,
    required this.onOpen,
    required this.onRemove,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final price = double.parse(item['price'].toString());
    final image = (item['image_url'] ?? item['image'])?.toString();

    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
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
                width: 74,
                height: 74,
                child: image != null && image.isNotEmpty
                    ? Image.network(
                        ApiService.productImage(image),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'].toString(),
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
                    item['description'].toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.hankenGrotesk(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        '\$${price.toStringAsFixed(2)}',
                        style: GoogleFonts.anybody(
                          color: AppColors.primaryFixed,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.shopping_cart_outlined,
                          color: AppColors.primaryFixed,
                          size: 20,
                        ),
                        onPressed: onAddToCart,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        onPressed: onRemove,
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

  Widget _placeholder() {
    return Container(
      color: AppColors.surfaceContainerHigh,
      child: const Icon(
        Icons.local_pizza,
        color: AppColors.primaryFixed,
        size: 34,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
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
            Icon(icon, color: AppColors.primaryFixed, size: 48),
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
