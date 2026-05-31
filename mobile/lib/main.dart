import 'package:flutter/material.dart';
import 'services/session_manager.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/products_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SessionManager.init();
  runApp(const DonatellosPizzaApp());
}

class DonatellosPizzaApp extends StatelessWidget {
  const DonatellosPizzaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Donatello's Pizza",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: SessionManager.isLoggedIn
          ? const ProductsScreen()
          : const HomeScreen(),
    );
  }
}
