import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amork/providers/auth_provider.dart';
import 'package:amork/providers/cart_provider.dart';
import 'package:amork/providers/home_provider.dart';
import 'package:amork/presentation/widgets/food_cart.dart';
import 'package:amork/presentation/widgets/category_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when screen opens
    Future.microtask(() =>
        Provider.of<HomeProvider>(context, listen: false).loadHomeData());
  }

  @override
  Widget build(BuildContext context) {
    // Access Providers
    final homeProvider = Provider.of<HomeProvider>(context);
    final user = Provider.of<AuthProvider>(context).currentUser;
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: homeProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. HEADER ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Hello 👋", style: TextStyle(color: Colors.grey, fontSize: 16)),
                            Text(
                              user?.name ?? "Guest",
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        // Cart Icon with Badge
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFF8E1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
                            ),
                            if (cartProvider.items.isNotEmpty)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${cartProvider.items.length}',
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- 2. SEARCH BAR ---
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        hintText: "Search your food...",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- 3. CATEGORIES LIST ---
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: homeProvider.categories.length,
                        itemBuilder: (context, index) {
                          return CategoryItem(
                            category: homeProvider.categories[index],
                            isSelected: index == 0, // Highlight first one as example
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- 4. POPULAR SECTION ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Popular",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text("See All", style: TextStyle(color: Colors.orange)),
                        )
                      ],
                    ),

                    const SizedBox(height: 16),

                    // --- 5. POPULAR FOODS LIST ---
                    SizedBox(
                      height: 270, 
                      child: homeProvider.popularFoods.isEmpty
                          ? const Center(child: Text("No foods found."))
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: homeProvider.popularFoods.length,
                              itemBuilder: (context, index) {
                                return FoodCard(food: homeProvider.popularFoods[index]);
                              },
                            ),
                    ),
                  ],
                ),
              ),
      ),
      // Optional Bottom Nav (Static for now)
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Fav'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}