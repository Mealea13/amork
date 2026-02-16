import 'package:flutter/material.dart';
import 'package:amork/data/models/food_model.dart';
import 'detail_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String selectedCategory = "Food";
  List<FoodModel> cart = [];

  int get currentCategoryId {
    switch (selectedCategory) {
      case "Drink": return 2;
      case "Dessert": return 3;
      case "Snack": return 4;
      case "Food":
      default: return 1;
    }
  }

  // FIXED: Using your local images from assets/images/
  final List<FoodModel> foods = [
    FoodModel(
      id: 1,
      name: "Avocado nido Salad",
      categoryId: 1,
      price: 4.05,
      imageUrl: "assets/images/cheese.png", // Using your local image
      description: "Healthy and fresh green salad",
      calories: 44,
      time: "25 min",
    ),
    FoodModel(
      id: 2,
      name: "Cambodia Fish Amork",
      categoryId: 1,
      price: 6.00,
      imageUrl: "assets/images/amork.png", // Using your local image
      description: "Traditional Cambodian dish",
      calories: 44,
      time: "25 min",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    List<FoodModel> filteredFoods = foods
        .where((f) => f.categoryId == currentCategoryId)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0), 
      
      /// ================= BOTTOM NAVIGATION =================
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Color(0xFFF1E6D3),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Image.asset("assets/images/home.png", height: 28),
            Image.asset("assets/images/order.png", height: 28),
            GestureDetector(
              onTap: () async {
                final updatedCart = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CartScreen(cart: cart)),
                );
                if (updatedCart != null) {
                  setState(() { cart = updatedCart; });
                }
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.asset("assets/images/cart.png", height: 28),
                  if (cart.isNotEmpty)
                    Positioned(
                      right: -5,
                      top: -5,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          cart.length.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
              child: Image.asset("assets/images/profile.png", height: 28),
            ),
          ],
        ),
      ),

      /// ================= MAIN BODY =================
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// --- Header ---
                Row(
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
                      children: const [
                        Icon(Icons.search, size: 28),
                        SizedBox(width: 15),
                        Icon(Icons.notifications_none, size: 28),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                /// --- Categories ---
                SizedBox(
                  height: 90,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _categoryItem("Food", "assets/images/food.png"),
                      _categoryItem("Drink", "assets/images/drink.png"),
                      _categoryItem("Dessert", "assets/images/dessert.png"),
                      _categoryItem("Snack", "assets/images/snack.png"),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                /// --- Advertisement Banners ---
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 120,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "More than a simple option",
                              style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Icon(Icons.eco, color: Colors.green, size: 50),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Container(
                        height: 120,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Simply a new choice for your McCombo",
                              style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Icon(Icons.fastfood, color: Colors.blue, size: 50),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                /// --- Popular Header ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Popular", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text("See All", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 15),

                /// --- Food Grid ---
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredFoods.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65, 
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemBuilder: (context, index) {
                    final food = filteredFoods[index];

                    return GestureDetector(
                      onTap: () async {
                        final addedFood = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DetailScreen(food: food)),
                        );
                        if (addedFood != null) {
                          setState(() { cart.add(addedFood); });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
                          ]
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              food.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "\$${food.price.toStringAsFixed(2)}",
                              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            
                            /// FIXED: Image.asset instead of Image.network
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Image.asset(food.imageUrl, fit: BoxFit.contain), 
                              ),
                            ),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.local_fire_department, color: Colors.orange, size: 14),
                                        const SizedBox(width: 4),
                                        Text("${food.calories} Calories", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time_filled, color: Colors.orangeAccent, size: 14),
                                        const SizedBox(width: 4),
                                        Text(food.time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                      ],
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() { cart.add(food); });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${food.name} added to cart!'),
                                        duration: const Duration(seconds: 1),
                                        backgroundColor: Colors.green,
                                      )
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.add, color: Colors.white, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoryItem(String title, String imagePath) {
    bool isSelected = selectedCategory == title;

    return GestureDetector(
      onTap: () {
        setState(() { selectedCategory = title; });
      },
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
            Image.asset(imagePath, height: 35, errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood, size: 30)),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}