import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/session_manager.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SessionManager.init();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
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
      home: const SplashScreen(),
    );
  }
}
