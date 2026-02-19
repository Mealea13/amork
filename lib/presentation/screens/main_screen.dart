import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amork/core/app_config.dart';
import 'package:amork/data/models/food_model.dart';

import 'food_view.dart';
import 'drink_view.dart';
import 'dessert_view.dart';
import 'snack_view.dart';
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
  int _selectedIndex    = 0;
  String selectedCategory = "Food";
  String userName       = "Loading...";
  int cartCount         = 0;
  int favoriteCount     = 0;
  int orderCount        = 0;
  int notificationCount = 0;

  // ── Ad Banner ──
  final PageController _adController = PageController();
  int _currentAdIndex = 0;
  Timer? _adTimer;

  // 🖼️ Replace these with your actual asset paths
  final List<Map<String, String>> _ads = [
    {
      'image': 'assets/images/ads-1.png',
      'title': 'Special Offer!',
      'subtitle': '20% off all burgers today',
    },
    {
      'image': 'assets/images/ads-2.png',
      'title': 'Great day with good snack 🍹',
      'subtitle': 'Try our refreshing summer drinks',
    },
    {
      'image': 'assets/images/ads-3.png',
      'title': 'New Arrival 🍹',
      'subtitle': 'Try our refreshing summer drinks',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchCartCount();
    _fetchFavoriteCount();
    _fetchOrderCount();
    _fetchNotificationCount();
    _startAdTimer();
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    _adController.dispose();
    super.dispose();
  }

  void _startAdTimer() {
    _adTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final next = (_currentAdIndex + 1) % _ads.length;
      _adController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _fetchUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('user_id');
      if (userId == null) { setState(() => userName = "Guest"); return; }
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
        int total = 0;
        for (final item in (items as List)) {
          total += (item['quantity'] ?? 1) as int;
        }
        if (mounted) setState(() => cartCount = total);
      }
    } catch (e) {
      debugPrint("Error fetching cart count: $e");
    }
  }

  Future<void> _fetchFavoriteCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/favorites'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (mounted) setState(() => favoriteCount = data.length);
      }
    } catch (e) {
      debugPrint("Error fetching favorite count: $e");
    }
  }

  Future<void> _fetchOrderCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/orders'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (mounted) setState(() => orderCount = data.length);
      }
    } catch (e) {
      debugPrint("Error fetching order count: $e");
    }
  }

  Future<void> _fetchNotificationCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/orders'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (mounted) setState(() => notificationCount = data.length * 2);
      }
    } catch (e) {
      debugPrint("Error fetching notification count: $e");
    }
  }

  void _handleCheckoutSuccess() {
    setState(() { cartCount = 0; _selectedIndex = 1; });
    _fetchCartCount();
    _fetchOrderCount();
    _fetchNotificationCount();
  }

  Future<void> _addToCart(FoodModel food) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final response = await http.post(
        Uri.parse('${AppConfig.cartEndpoint}/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'food_id': food.id, 'quantity': 1}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) setState(() => cartCount += 1);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${food.name} added to cart! 🛒'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 1),
          ));
        }
      }
    } catch (e) {
      debugPrint('Add to cart error: $e');
    }
  }

  Future<void> _onDetailScreenReturned() async {
    await _fetchCartCount();
    await _fetchFavoriteCount();
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0: return _buildHomeBody();
      case 1: return OrderScreen(
        onOrderCountChanged: (count) => setState(() => orderCount = count),
      );
      case 2: return CartScreen(
        onCheckoutSuccess: _handleCheckoutSuccess,
        onCartCountChanged: (totalQty) {
          if (mounted) setState(() => cartCount = totalQty);
        },
      );
      case 3: return FavoriteScreen(
        onAddToCart: (food) => _addToCart(food),
        onFavoriteCountChanged: (count) => setState(() => favoriteCount = count),
      );
      case 4: return const ProfileScreen();
      default: return _buildHomeBody();
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
          _buildNavItem(icon: Icons.home_outlined,         activeIcon: Icons.home,         index: 0),
          _buildNavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, index: 1, badgeCount: orderCount),
          _buildCartItem(index: 2),
          _buildNavItem(icon: Icons.favorite_border,       activeIcon: Icons.favorite,     index: 3, activeColor: Colors.red, badgeCount: favoriteCount),
          _buildNavItem(icon: Icons.person_outline,        activeIcon: Icons.person,       index: 4),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required int index,
    Color activeColor = Colors.orange,
    int badgeCount = 0,
  }) {
    final bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (index == 1) _fetchOrderCount();
        if (index == 3) _fetchFavoriteCount();
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
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
          if (badgeCount > 0)
            Positioned(
              right: 2, top: 2,
              child: CircleAvatar(
                radius: 8,
                backgroundColor: Colors.red,
                child: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
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
                child: Text(
                  cartCount > 99 ? '99+' : '$cartCount',
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
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
          const SizedBox(height: 15),
          _buildAdBanner(),         // ← Ad carousel here
          const SizedBox(height: 10),
          Expanded(child: _getCategoryView()),
        ],
      ),
    );
  }

  // ── Ad Banner Carousel ──────────────────────────────────────────────────────
  Widget _buildAdBanner() {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _adController,
            itemCount: _ads.length,
            onPageChanged: (i) => setState(() => _currentAdIndex = i),
            itemBuilder: (context, index) {
              final ad = _ads[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background image
                      Image.asset(
                        ad['image']!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange.shade300,
                                Colors.orange.shade600,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                      // Dark gradient overlay for text readability
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.45),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      // Text overlay
                      Positioned(
                        left: 16,
                        bottom: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ad['title']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(blurRadius: 4, color: Colors.black45),
                                ],
                              ),
                            ),
                            Text(
                              ad['subtitle']!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                shadows: [
                                  Shadow(blurRadius: 4, color: Colors.black45),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // ── Dot indicators ──
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_ads.length, (i) {
            final bool active = i == _currentAdIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 20 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active ? Colors.orange : Colors.orange.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
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
              const Text("Hello 👋",
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              Text(userName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotificationScreen()),
                      );
                      if (mounted) setState(() => notificationCount = 0);
                    },
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: 6, top: 6,
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.red,
                        child: Text(
                          notificationCount > 99 ? '99+' : '$notificationCount',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
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
      case "Drink":
        return DrinkView(
          onAddToCart: _addToCart,
          onDetailAdded: _onDetailScreenReturned,
        );
      case "Dessert":
        return DessertView(
          onAddToCart: _addToCart,
          onDetailAdded: _onDetailScreenReturned,
        );
      case "Snack":
        return SnackView(
          onAddToCart: _addToCart,
          onDetailAdded: _onDetailScreenReturned,
        );
      default:
        return FoodView(
          onAddToCart: _addToCart,
          onDetailAdded: _onDetailScreenReturned,
        );
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
            Text(title,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}