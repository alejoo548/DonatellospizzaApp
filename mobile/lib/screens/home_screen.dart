import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/ninja_button.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'cart_screen.dart';
import 'products_screen.dart';
import 'ordering_flow_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDim,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DotPatternPainter(),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      _buildHero(),
                      const SizedBox(height: 56),
                      Text(
                        'FORMULARIOS',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.hankenGrotesk(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 20),
                      NinjaButton(
                        label: 'Página Principal (Productos)',
                        icon: Icons.storefront_outlined,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProductsScreen()),
                        ),
                      ),
                      const SizedBox(height: 14),
                      NinjaButton(
                        label: 'Iniciar Sesión',
                        icon: Icons.login,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        ),
                        variant: NinjaButtonVariant.ghost,
                      ),
                      const SizedBox(height: 14),
                      NinjaButton(
                        label: 'Crear Cuenta',
                        icon: Icons.person_add_outlined,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen()),
                        ),
                        variant: NinjaButtonVariant.ghost,
                      ),
                      const SizedBox(height: 14),
                      NinjaButton(
                        label: 'Ver Carrito',
                        icon: Icons.shopping_cart_outlined,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CartScreen()),
                        ),
                        variant: NinjaButtonVariant.ghost,
                      ),
                      const SizedBox(height: 14),
                      NinjaButton(
                        label: 'Menú (Ordering Flow)',
                        icon: Icons.restaurant_menu_outlined,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const OrderingFlowScreen()),
                        ),
                        variant: NinjaButtonVariant.ghost,
                      ),
                      const SizedBox(height: 14),
                      NinjaButton(
                        label: 'Detalle Producto',
                        icon: Icons.local_pizza_outlined,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProductDetailScreen()),
                        ),
                        variant: NinjaButtonVariant.ghost,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryFixed.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryFixed.withValues(alpha: 0.1),
                blurRadius: 20,
              ),
            ],
          ),
          child: const Icon(Icons.local_pizza,
              color: AppColors.primaryFixed, size: 40),
        ),
        const SizedBox(height: 24),
        Text(
          "DONATELLO'S",
          textAlign: TextAlign.center,
          style: GoogleFonts.anybody(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: 1,
            height: 1,
            fontStyle: FontStyle.italic,
          ),
        ),
        Text(
          'PIZZA',
          textAlign: TextAlign.center,
          style: GoogleFonts.anybody(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryFixed,
            letterSpacing: 1,
            height: 1.1,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Vigilante Hospitality',
          style: GoogleFonts.hankenGrotesk(
            color: AppColors.onSurfaceVariant,
            fontSize: 13,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9FFB00).withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    const spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotPatternPainter old) => false;
}
