import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amork/core/app_config.dart';
import 'package:amork/data/models/food_model.dart';

// Views
import 'food_view.dart';
import 'drink_view.dart';
import 'dessert_view.dart';
import 'snack_view.dart';

// Screens
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'order_screen.dart';
import 'favorite_screen.dart';
import 'search_screen.dart';
import 'notification_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String selectedCategory = "Food";
  String userName = "Loading...";
  int cartCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchCartCount();
  }

  Future<void> _fetchUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('user_id');
      if (userId == null) {
        setState(() => userName = "Guest");
        return;
      }
      final response = await http.get(Uri.parse('${AppConfig.profileEndpoint}/$userId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => userName = data['fullname'] ?? "User");
      }
    } catch (e) {
      debugPrint("Error fetching user: $e");
      setState(() => userName = "User");
    }
  }

  Future<void> _fetchCartCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final response = await http.get(
        Uri.parse(AppConfig.cartEndpoint),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data is List ? data : (data['items'] ?? []);
        setState(() => cartCount = (items as List).length);
      }
    } catch (e) {
      debugPrint("Error fetching cart count: $e");
    }
  }

  void _handleCheckoutSuccess() {
    setState(() {
      cartCount = 0;
      _selectedIndex = 1; // Go to Orders tab
    });
    _fetchCartCount();
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0: return _buildHomeBody();
      case 1: return const OrderScreen();
      case 2: return CartScreen(onCheckoutSuccess: _handleCheckoutSuccess);
      case 3: return FavoriteScreen(onAddToCart: (food) => _addToCart(food));
      case 4: return const ProfileScreen();
      default: return _buildHomeBody();
    }
  }

  // ✅ Shared add to cart function
  Future<void> _addToCart(FoodModel food) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final response = await http.post(
        Uri.parse('${AppConfig.cartEndpoint}/add'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'food_id': food.id, 'quantity': 1}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await _fetchCartCount();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${food.name} added to cart! 🛒'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Add to cart error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      body: _getBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 75,
      decoration: const BoxDecoration(
        color: Color(0xFFF1E6D3),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(icon: Icons.home_outlined,        activeIcon: Icons.home,         index: 0),
          _buildNavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, index: 1),
          _buildCartItem(index: 2),
          _buildNavItem(icon: Icons.favorite_border,      activeIcon: Icons.favorite,     index: 3, activeColor: Colors.red),
          _buildNavItem(icon: Icons.person_outline,       activeIcon: Icons.person,       index: 4),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required int index,
    Color activeColor = Colors.orange,
  }) {
    final bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(
          isActive ? activeIcon : icon,
          color: isActive ? activeColor : Colors.brown,
          size: 26,
        ),
      ),
    );
  }

  Widget _buildCartItem({required int index}) {
    final bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              isActive ? Icons.shopping_cart : Icons.shopping_cart_outlined,
              color: isActive ? Colors.orange : Colors.brown,
              size: 26,
            ),
          ),
          if (cartCount > 0)
            Positioned(
              right: 2, top: 2,
              child: CircleAvatar(
                radius: 8,
                backgroundColor: Colors.red,
                child: Text('$cartCount', style: const TextStyle(fontSize: 10, color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHomeBody() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 10),
          _buildCategorySelector(),
          Expanded(child: _getCategoryView()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Hello 👋", style: TextStyle(fontSize: 14, color: Colors.grey)),
              Text(userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _categoryItem("Food",    "assets/images/food.png"),
          _categoryItem("Drink",   "assets/images/Drink.png"),
          _categoryItem("Dessert", "assets/images/Dessert.png"),
          _categoryItem("Snack",   "assets/images/snack.png"),
        ],
      ),
    );
  }

  Widget _getCategoryView() {
    switch (selectedCategory) {
      case "Drink":   return DrinkView(onAddToCart:   (food) => _addToCart(food));
      case "Dessert": return DessertView(onAddToCart: (food) => _addToCart(food));
      case "Snack":   return SnackView(onAddToCart:   (food) => _addToCart(food));
      default:        return FoodView(onAddToCart:    (food) => _addToCart(food));
    }
  }

  Widget _categoryItem(String title, String imagePath) {
    final bool isSelected = selectedCategory == title;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = title),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF1E6D3),
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: Colors.orange, width: 2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 35,
                errorBuilder: (c, e, s) => const Icon(Icons.fastfood)),
            const SizedBox(height: 5),
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}