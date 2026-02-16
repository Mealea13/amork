import 'package:flutter/material.dart';
import 'package:amork/data/models/food_model.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // A master list of items to search through
  final List<FoodModel> allItems = [
    FoodModel(id: 1, name: "Avocado nido Salad", categoryId: 1, price: 4.05, imageUrl: "assets/images/salad.png", description: "Healthy and fresh green salad", calories: 150, time: "10 min"),
    FoodModel(id: 2, name: "Cambodia Fish Amork", categoryId: 1, price: 6.00, imageUrl: "assets/images/amork.png", description: "Traditional Cambodian dish", calories: 350, time: "25 min"),
    FoodModel(id: 3, name: "Special Beef Burger", categoryId: 1, price: 5.50, imageUrl: "assets/images/burger.png", description: "Double beef with extra cheese", calories: 600, time: "15 min"),
    FoodModel(id: 8, name: "Classic Pizza", categoryId: 1, price: 8.00, imageUrl: "assets/images/pizza.png", description: "Cheesy classic pizza", calories: 800, time: "30 min"),
    FoodModel(id: 201, name: "Fresh Lemonade", categoryId: 2, price: 2.00, imageUrl: "assets/images/lemonade.png", description: "Cold refreshing drink", calories: 120, time: "2 min"),
    FoodModel(id: 202, name: "Iced Coffee", categoryId: 2, price: 3.50, imageUrl: "assets/images/iced_coffee.png", description: "Sweet iced coffee", calories: 200, time: "3 min"),
    FoodModel(id: 301, name: "Strawberry Cake", categoryId: 3, price: 4.50, imageUrl: "assets/images/cake.png", description: "Sweet and creamy dessert", calories: 450, time: "10 min"),
    FoodModel(id: 401, name: "Crispy Fries", categoryId: 4, price: 3.00, imageUrl: "assets/images/fries.png", description: "Hot salty french fries", calories: 300, time: "10 min"),
  ];

  List<FoodModel> filteredItems = [];

  @override
  void initState() {
    super.initState();
    filteredItems = allItems; // Show all items initially
  }

  void _filterSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredItems = allItems;
      } else {
        filteredItems = allItems
            .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // --- Search Bar ---
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios, color: Colors.black),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterSearch,
                      autofocus: true, // Keyboard pops up immediately
                      decoration: InputDecoration(
                        hintText: "Search for food, drinks...",
                        prefixIcon: const Icon(Icons.search, color: Colors.orange),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- Search Results ---
              Expanded(
                child: filteredItems.isEmpty
                    ? const Center(child: Text("No items found 😢", style: TextStyle(color: Colors.grey, fontSize: 16)))
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return GestureDetector(
                            onTap: () async {
                              // Go to detail screen and pass the result back to MainScreen if added to cart!
                              final addedFood = await Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(food: item)));
                              if (addedFood != null) {
                                Navigator.pop(context, addedFood); 
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))]),
                              child: Row(
                                children: [
                                  Image.asset(item.imageUrl, height: 60, width: 60, errorBuilder: (c,e,s) => const Icon(Icons.fastfood, color: Colors.grey, size: 50)),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(height: 4),
                                        Text("\$${item.price.toStringAsFixed(2)}", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}