import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 1. IMPORT YOUR PROVIDERS
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/home_provider.dart';

// 2. IMPORT YOUR SCREENS
import 'presentation/screens/welcome_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Amork Food App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}