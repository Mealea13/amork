import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/home_provider.dart';
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
      themeMode: ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        // This makes sure every new screen starts with your Figma beige color
        scaffoldBackgroundColor: const Color(0xFFF9F6F0),
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}