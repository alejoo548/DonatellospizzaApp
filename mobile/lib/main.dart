import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
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
      home: const HomeScreen(),
    );
  }
}
