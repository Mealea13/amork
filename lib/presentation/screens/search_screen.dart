import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:amork/data/models/food_model.dart';
import 'package:amork/core/app_config.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<FoodModel> _results = [];
  List<FoodModel> _allFoods = [];
  bool _isLoading = false;
  bool _isLoadingAll = true;

  // All foods combined from all views
  final List<FoodModel> _localFoods = [
    // Food
    FoodModel(id: 1,   name: "Avocado nido Salad",  categoryId: 1, price: 4.05,  imageUrl: "assets/images/Salad.png",          description: "Healthy and fresh green salad",      calories: 150, time: "10 min"),
    FoodModel(id: 2,   name: "Cambodia Fish Amork",  categoryId: 1, price: 6.00,  imageUrl: "assets/images/amork.png",          description: "Traditional Cambodian dish",         calories: 350, time: "25 min"),
    FoodModel(id: 3,   name: "Special Beef Burger",  categoryId: 1, price: 5.50,  imageUrl: "assets/images/Burger.png",         description: "Double beef with extra cheese",      calories: 600, time: "15 min"),
    FoodModel(id: 8,   name: "Classic Pizza",        categoryId: 1, price: 8.00,  imageUrl: "assets/images/pizza.png",          description: "Cheesy classic pizza",               calories: 800, time: "30 min"),
    FoodModel(id: 9,   name: "Num Ansorm",           categoryId: 1, price: 2.50,  imageUrl: "assets/images/ansorm.png",         description: "Traditional sticky rice cake",       calories: 350, time: "10 min"),
    FoodModel(id: 10,  name: "Khmer Curry",          categoryId: 1, price: 5.00,  imageUrl: "assets/images/Curry.png",          description: "Rich and spicy chicken curry",       calories: 500, time: "25 min"),
    FoodModel(id: 11,  name: "Spicy Wings",          categoryId: 1, price: 3.00,  originalPrice: 6.00, imageUrl: "assets/images/wings grill.png", description: "Hot and spicy chicken wings", calories: 400, time: "15 min"),
    FoodModel(id: 12,  name: "Fried Rice",           categoryId: 1, price: 2.50,  originalPrice: 5.00, imageUrl: "assets/images/Bay cha.png",     description: "Pork fried rice with egg",    calories: 450, time: "20 min"),
    FoodModel(id: 101, name: "Kuy Teav",             categoryId: 1, price: 3.50,  imageUrl: "assets/images/Kuy teav.png",       description: "Pork broth noodle soup",             calories: 400, time: "15 min"),
    FoodModel(id: 102, name: "Papaya Salad",         categoryId: 1, price: 2.50,  imageUrl: "assets/images/Papaya Salad.png",   description: "Spicy and sour green papaya",        calories: 120, time: "10 min"),
    FoodModel(id: 103, name: "Tom Yum Goong",        categoryId: 1, price: 7.00,  imageUrl: "assets/images/tong yum.png",       description: "Spicy Thai shrimp soup",             calories: 250, time: "20 min"),
    FoodModel(id: 104, name: "Sushi Platter",        categoryId: 1, price: 12.00, imageUrl: "assets/images/Sushi.png",          description: "Fresh salmon and tuna sushi",        calories: 450, time: "15 min"),
    FoodModel(id: 105, name: "Beef Lok Lak",         categoryId: 1, price: 6.50,  imageUrl: "assets/images/lok lak.png",        description: "Stir-fried beef with pepper sauce",  calories: 550, time: "20 min"),
    FoodModel(id: 106, name: "Grilled Steak",        categoryId: 1, price: 15.00, imageUrl: "assets/images/Steak.png",          description: "Premium ribeye medium rare",         calories: 700, time: "25 min"),
    FoodModel(id: 107, name: "Lot Cha",              categoryId: 1, price: 1.50,  imageUrl: "assets/images/lot cha.png",        description: "Cambodian short noodle lot cha",     calories: 500, time: "15 min"),
    FoodModel(id: 108, name: "Spicy Ramen",          categoryId: 1, price: 5.00,  imageUrl: "assets/images/Ramen.png",          description: "Japanese noodle soup",               calories: 480, time: "15 min"),
    FoodModel(id: 109, name: "Prahok Ktis",          categoryId: 1, price: 4.00,  imageUrl: "assets/images/Brohok.png",         description: "Minced pork with fermented fish",    calories: 400, time: "20 min"),
    FoodModel(id: 110, name: "Bai Sach Chrouk",      categoryId: 1, price: 2.00,  imageUrl: "assets/images/Bay sach jruk.png", description: "Pork and rice breakfast",            calories: 450, time: "5 min"),
    FoodModel(id: 111, name: "Kralan",               categoryId: 1, price: 1.50,  imageUrl: "assets/images/krolan.png",         description: "Bamboo sticky rice",                 calories: 200, time: "5 min"),
    FoodModel(id: 112, name: "Nom Banh Chok",        categoryId: 1, price: 2.50,  imageUrl: "assets/images/Nom banh jok.png",   description: "Khmer noodles with fish gravy",      calories: 300, time: "10 min"),
    FoodModel(id: 113, name: "Beef Tacos",           categoryId: 1, price: 3.50,  originalPrice: 7.00, imageUrl: "assets/images/Tacos.png",    description: "Mexican street tacos",  calories: 300, time: "10 min"),
    FoodModel(id: 114, name: "Pork Dumplings",       categoryId: 1, price: 2.00,  originalPrice: 4.00, imageUrl: "assets/images/dumpling.png", description: "Steamed meat dumplings",calories: 250, time: "15 min"),
    FoodModel(id: 115, name: "Dim Sum",              categoryId: 1, price: 4.00,  originalPrice: 8.00, imageUrl: "assets/images/dum sum.png",  description: "Assorted Chinese bites", calories: 350, time: "20 min"),
    // Drinks
    FoodModel(id: 201, name: "Fresh Lemonade",   categoryId: 2, price: 1.00, originalPrice: 2.00, imageUrl: "assets/images/lemonade.png",               description: "Cold refreshing drink",         calories: 120, time: "2 min"),
    FoodModel(id: 202, name: "Iced Coffee",      categoryId: 2, price: 1.75, originalPrice: 3.50, imageUrl: "assets/images/iced latte.png",             description: "Sweet iced coffee",             calories: 200, time: "3 min"),
    FoodModel(id: 203, name: "Coca Cola",        categoryId: 2, price: 0.75, originalPrice: 1.50, imageUrl: "assets/images/coke.png",                   description: "Classic soda",                  calories: 140, time: "1 min"),
    FoodModel(id: 204, name: "Brown Sugar Boba", categoryId: 2, price: 2.00, originalPrice: 4.00, imageUrl: "assets/images/Boba.png",                   description: "Milk tea with sweet pearls",    calories: 350, time: "5 min"),
    FoodModel(id: 205, name: "Mango Smoothie",   categoryId: 2, price: 1.50, originalPrice: 3.00, imageUrl: "assets/images/smoothies.png",              description: "Blended fresh mango",           calories: 250, time: "5 min"),
    FoodModel(id: 206, name: "Green Tea",        categoryId: 2, price: 2.50, imageUrl: "assets/images/green-tea.png",                 description: "Healthy hot green tea",   calories: 0,   time: "3 min"),
    FoodModel(id: 207, name: "Matcha Latte",     categoryId: 2, price: 4.50, imageUrl: "assets/images/matcha-latte.png",              description: "Premium Japanese matcha", calories: 220, time: "5 min"),
    FoodModel(id: 208, name: "Americano",        categoryId: 2, price: 2.50, imageUrl: "assets/images/pngtree-americano-coffee-.png", description: "Black coffee",            calories: 10,  time: "3 min"),
    FoodModel(id: 209, name: "Cappuccino",       categoryId: 2, price: 3.50, imageUrl: "assets/images/coffee-cappuccino.png",         description: "Espresso with milk foam", calories: 150, time: "4 min"),
    FoodModel(id: 210, name: "Orange Juice",     categoryId: 2, price: 3.00, imageUrl: "assets/images/orange-juice.png",              description: "Freshly squeezed",        calories: 110, time: "2 min"),
    FoodModel(id: 216, name: "Fresh Coconut",    categoryId: 2, price: 2.00, imageUrl: "assets/images/coconut.png",                   description: "Whole fresh coconut",     calories: 50,  time: "1 min"),
    FoodModel(id: 219, name: "Mineral Water",    categoryId: 2, price: 0.50, imageUrl: "assets/images/water.png",                     description: "Bottled water",           calories: 0,   time: "1 min"),
    FoodModel(id: 220, name: "Energy Drink",     categoryId: 2, price: 2.50, imageUrl: "assets/images/Energy_drink.png",              description: "Red Bull energy",         calories: 110, time: "1 min"),
    // Desserts
    FoodModel(id: 301, name: "Strawberry Cake",   categoryId: 3, price: 2.25, originalPrice: 4.50, imageUrl: "assets/images/cake.png",      description: "Sweet and creamy dessert",   calories: 450, time: "10 min"),
    FoodModel(id: 302, name: "Vanilla Ice Cream", categoryId: 3, price: 1.25, originalPrice: 2.50, imageUrl: "assets/images/ice_cream.png", description: "Two scoops of vanilla",      calories: 300, time: "2 min"),
    FoodModel(id: 303, name: "Chocolate Brownie", categoryId: 3, price: 1.50, originalPrice: 3.00, imageUrl: "assets/images/brownie.png",   description: "Warm chocolate fudge",       calories: 400, time: "5 min"),
    FoodModel(id: 306, name: "NY Cheesecake",     categoryId: 3, price: 5.00, imageUrl: "assets/images/cheesecake.png",                    description: "Classic creamy slice",       calories: 500, time: "5 min"),
    FoodModel(id: 307, name: "Tiramisu",          categoryId: 3, price: 5.50, imageUrl: "assets/images/tiramisu.png",                      description: "Italian coffee dessert",     calories: 450, time: "5 min"),
    FoodModel(id: 309, name: "Glazed Donut",      categoryId: 3, price: 1.50, imageUrl: "assets/images/donut.png",                         description: "Sweet sugar ring",           calories: 250, time: "2 min"),
    FoodModel(id: 310, name: "Churros",           categoryId: 3, price: 3.50, imageUrl: "assets/images/churros.png",                       description: "Fried dough with chocolate", calories: 350, time: "8 min"),
    // Snacks
    FoodModel(id: 401, name: "Crispy Fries",    categoryId: 4, price: 1.50, originalPrice: 3.00, imageUrl: "assets/images/fries.png",       description: "Hot salty french fries",   calories: 300, time: "10 min"),
    FoodModel(id: 402, name: "Cheese Nachos",   categoryId: 4, price: 2.25, originalPrice: 4.50, imageUrl: "assets/images/nachos.png",      description: "Chips with melted cheese", calories: 400, time: "10 min"),
    FoodModel(id: 406, name: "Soft Pretzel",    categoryId: 4, price: 3.00, imageUrl: "assets/images/pretzel.png",                         description: "Warm salted pretzel",      calories: 280, time: "5 min"),
    FoodModel(id: 407, name: "Chicken Nuggets", categoryId: 4, price: 4.50, imageUrl: "assets/images/nuggets.png",                         description: "6 piece golden nuggets",   calories: 380, time: "10 min"),
    FoodModel(id: 410, name: "Spring Rolls",    categoryId: 4, price: 4.00, imageUrl: "assets/images/spring_rolls.png",                    description: "Crispy veggie rolls",      calories: 250, time: "10 min"),
    FoodModel(id: 416, name: "Potato Wedges",   categoryId: 4, price: 3.50, imageUrl: "assets/images/wedges.png",                          description: "Thick cut seasoned fries", calories: 320, time: "15 min"),
    FoodModel(id: 420, name: "Beef Jerky",      categoryId: 4, price: 6.00, imageUrl: "assets/images/beef_jerky.png",                      description: "Dried and seasoned beef",  calories: 200, time: "2 min"),
  ];

  @override
  void initState() {
    super.initState();
    _allFoods = _localFoods;
    _results  = _localFoods; // show all by default
    _isLoadingAll = false;
  }

  void _search(String query) {
    if (query.isEmpty) {
      setState(() => _results = _allFoods);
      return;
    }
    final q = query.toLowerCase();
    setState(() {
      _results = _allFoods.where((f) =>
        f.name.toLowerCase().contains(q) ||
        f.description.toLowerCase().contains(q)
      ).toList();
    });
  }

  String _categoryName(int id) {
    switch (id) {
      case 1: return "🍛 Food";
      case 2: return "🥤 Drink";
      case 3: return "🍰 Dessert";
      case 4: return "🍿 Snack";
      default: return "Other";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          onChanged: _search,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Search food, drinks, desserts...",
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      _search('');
                    },
                  )
                : null,
          ),
        ),
      ),
      body: _isLoadingAll
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : Column(
              children: [
                // Result count bar
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        _searchController.text.isEmpty
                            ? "All Menu (${_results.length} items)"
                            : "${_results.length} result${_results.length != 1 ? 's' : ''} for \"${_searchController.text}\"",
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _results.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off, size: 80, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                "No results for \"${_searchController.text}\"",
                                style: const TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(15),
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final food = _results[index];
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => DetailScreen(food: food)),
                              ),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        food.imageUrl,
                                        width: 65, height: 65,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Container(
                                          width: 65, height: 65,
                                          color: const Color(0xFFF1E6D3),
                                          child: const Icon(Icons.fastfood, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  food.name,
                                                  style: const TextStyle(
                                                      fontWeight: FontWeight.bold, fontSize: 14),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF1E6D3),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  _categoryName(food.categoryId),
                                                  style: const TextStyle(fontSize: 10),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            food.description,
                                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              if (food.originalPrice != null) ...[
                                                Text(
                                                  "\$${food.originalPrice!.toStringAsFixed(2)}",
                                                  style: const TextStyle(
                                                    decoration: TextDecoration.lineThrough,
                                                    color: Colors.grey, fontSize: 11,
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                              ],
                                              Text(
                                                "\$${food.price.toStringAsFixed(2)}",
                                                style: TextStyle(
                                                  color: food.originalPrice != null
                                                      ? Colors.red
                                                      : Colors.orange,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const Spacer(),
                                              const Icon(Icons.local_fire_department,
                                                  color: Colors.orange, size: 13),
                                              const SizedBox(width: 2),
                                              Text("${food.calories} Cal",
                                                  style: const TextStyle(
                                                      fontSize: 11, color: Colors.grey)),
                                              const SizedBox(width: 8),
                                              const Icon(Icons.access_time,
                                                  color: Colors.orangeAccent, size: 13),
                                              const SizedBox(width: 2),
                                              Text(food.time,
                                                  style: const TextStyle(
                                                      fontSize: 11, color: Colors.grey)),
                                            ],
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
              ],
            ),
    );
  }
}