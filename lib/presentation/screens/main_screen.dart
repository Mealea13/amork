import 'package:flutter/material.dart';
import 'package:amork/data/models/food_model.dart';

import 'food_view.dart';
import 'drink_view.dart';
import 'dessert_view.dart';
import 'snack_view.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'order_screen.dart';   
import 'search_screen.dart';      // NEW IMPORT
import 'notification_screen.dart'; // NEW IMPORT

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; 
  String selectedCategory = "Food"; 
  List<FoodModel> cart = [];
  
  List<OrderModel> myOrders = [
    OrderModel(orderNumber: "#AMK-0988", date: "Yesterday, 06:15 PM", items: "1x Burger, 1x Coke", total: 6.00, status: "Completed"),
  ];

  void _handleAddToCart(FoodModel food) {
    setState(() { cart.add(food); });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${food.name} added!'), duration: const Duration(seconds: 1), backgroundColor: Colors.green)
    );
  }

  void _handleCheckoutSuccess() {
    Map<String, int> itemCounts = {};
    double total = 0;
    for (var food in cart) {
      itemCounts[food.name] = (itemCounts[food.name] ?? 0) + 1;
      total += food.price;
    }
    
    String itemsSummary = itemCounts.entries.map((e) => "${e.value}x ${e.key}").join(", ");
    String orderNum = "#AMK-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}";
    String date = "Today, ${TimeOfDay.now().format(context)}";

    setState(() {
      myOrders.insert(0, OrderModel(orderNumber: orderNum, date: date, items: itemsSummary, total: total, status: "Delivering"));
      cart.clear(); 
      _selectedIndex = 1; 
    });
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0: return _buildHomeBody();
      case 1: return OrderScreen(orders: myOrders);
      case 2: return CartScreen(cart: cart, onRemoveItem: (i) => setState(() => cart.removeAt(i)), onCheckoutSuccess: _handleCheckoutSuccess);
      case 3: return const ProfileScreen();
      default: return _buildHomeBody();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0), 
      body: _getBody(),
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Color(0xFFF1E6D3),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(iconPath: "assets/images/home.png", index: 0),
            _buildNavItem(iconPath: "assets/images/order.png", index: 1, fallbackIcon: Icons.receipt_long),
            _buildCartItem(index: 2),
            _buildNavItem(iconPath: "assets/images/profile.png", index: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({required String iconPath, required int index, IconData? fallbackIcon}) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: isActive ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(18), boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)] : []),
        child: Image.asset(iconPath, height: 28, errorBuilder: (c, e, s) => Icon(fallbackIcon ?? Icons.image, size: 28)),
      ),
    );
  }

  Widget _buildCartItem({required int index}) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: isActive ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(18), boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)] : []),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Image.asset("assets/images/cart.png", height: 28),
            if (cart.isNotEmpty)
              Positioned(
                right: -5, top: -5,
                child: Container(
                  padding: const EdgeInsets.all(5), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: Text(cart.length.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeBody() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Pinned Header (NOW CLICKABLE!)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hello 👋", style: TextStyle(fontSize: 14, color: Colors.grey)),
                    Text("Him Somealea", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: [
                    // --- SEARCH BUTTON ---
                    GestureDetector(
                      onTap: () async {
                        final addedFood = await Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
                        if (addedFood != null) {
                          _handleAddToCart(addedFood);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.search, size: 24),
                      ),
                    ),
                    const SizedBox(width: 15),

                    // --- NOTIFICATION BUTTON ---
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.notifications_none, size: 24),
                            // Red Badge for Unread Notifications
                            Positioned(
                              right: 2, top: 2,
                              child: Container(
                                width: 8, height: 8,
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Pinned Categories List
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _categoryItem("Food", "assets/images/food.png"),
                _categoryItem("Drink", "assets/images/drink.png"),
                _categoryItem("Dessert", "assets/images/dessert.png"),
                _categoryItem("Snack", "assets/images/snack.png"),
              ],
            ),
          ),
          
          // 3. Dynamic Scrollable Body
          Expanded(child: _getCategoryView()),
        ],
      ),
    );
  }

  Widget _getCategoryView() {
    switch (selectedCategory) {
      case "Drink": return DrinkView(onAddToCart: _handleAddToCart);
      case "Dessert": return DessertView(onAddToCart: _handleAddToCart);
      case "Snack": return SnackView(onAddToCart: _handleAddToCart);
      case "Food":
      default: return FoodView(onAddToCart: _handleAddToCart);
    }
  }

  Widget _categoryItem(String title, String imagePath) {
    bool isSelected = selectedCategory == title;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = title),
      child: Container(
        width: 75,
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF1E6D3),
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: Colors.red, width: 1.5) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 35, errorBuilder: (c, e, s) => const Icon(Icons.fastfood, size: 30)),
            const SizedBox(height: 5),
            Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}