import 'package:flutter/material.dart';
import 'package:amork/data/models/food_model.dart';
import 'package:amork/presentation/screens/skeleton_widget.dart';
import 'detail_screen.dart';
import 'see_all_screen.dart';

class FoodView extends StatefulWidget {
  final Function(FoodModel) onAddToCart;
  final VoidCallback? onDetailAdded;

  const FoodView({super.key, required this.onAddToCart, this.onDetailAdded});

  @override
  State<FoodView> createState() => _FoodViewState();
}

class _FoodViewState extends State<FoodView> {
  bool _isLoading = true;

  final List<FoodModel> popularFoods = [
    FoodModel(id: 1,   name: "Avocado nido Salad",  categoryId: 1, price: 4.05,  imageUrl: "assets/images/Salad.png",         description: "Healthy and fresh green salad",      calories: 150, time: "10 min"),
    FoodModel(id: 2,   name: "Cambodia Fish Amork",  categoryId: 1, price: 6.00,  imageUrl: "assets/images/amork.png",         description: "Traditional Cambodian dish",         calories: 350, time: "25 min"),
    FoodModel(id: 101, name: "Kuy Teav",             categoryId: 1, price: 3.50,  imageUrl: "assets/images/Kuy teav.png",      description: "Pork broth noodle soup",             calories: 400, time: "15 min"),
    FoodModel(id: 102, name: "Papaya Salad",         categoryId: 1, price: 2.50,  imageUrl: "assets/images/Papaya Salad.png",  description: "Spicy and sour green papaya",        calories: 120, time: "10 min"),
    FoodModel(id: 103, name: "Tom Yum Goong",        categoryId: 1, price: 7.00,  imageUrl: "assets/images/tong yum.png",      description: "Spicy Thai shrimp soup",             calories: 250, time: "20 min"),
    FoodModel(id: 104, name: "Sushi Platter",        categoryId: 1, price: 12.00, imageUrl: "assets/images/Sushi.png",         description: "Fresh salmon and tuna sushi",        calories: 450, time: "15 min"),
  ];

  final List<FoodModel> bestSelling = [
    FoodModel(id: 3,   name: "Special Beef Burger",  categoryId: 1, price: 5.50,  imageUrl: "assets/images/Burger.png",        description: "Double beef with extra cheese",      calories: 600, time: "15 min"),
    FoodModel(id: 8,   name: "Classic Pizza",        categoryId: 1, price: 8.00,  imageUrl: "assets/images/pizza.png",         description: "Cheesy classic pizza",               calories: 800, time: "30 min"),
    FoodModel(id: 105, name: "Beef Lok Lak",         categoryId: 1, price: 6.50,  imageUrl: "assets/images/lok lak.png",       description: "Stir-fried beef with pepper sauce",  calories: 550, time: "20 min"),
    FoodModel(id: 106, name: "Grilled Steak",        categoryId: 1, price: 15.00, imageUrl: "assets/images/Steak.png",         description: "Premium ribeye medium rare",         calories: 700, time: "25 min"),
    FoodModel(id: 107, name: "Lot Cha",              categoryId: 1, price: 1.50,  imageUrl: "assets/images/lot cha.png",       description: "Cambodian short noodle lot cha",     calories: 500, time: "15 min"),
    FoodModel(id: 108, name: "Spicy Ramen",          categoryId: 1, price: 5.00,  imageUrl: "assets/images/Ramen.png",         description: "Japanese noodle soup",               calories: 480, time: "15 min"),
  ];

  final List<FoodModel> khmerNewYear = [
    FoodModel(id: 9,   name: "Num Ansorm",           categoryId: 1, price: 2.50,  imageUrl: "assets/images/ansorm.png",        description: "Traditional sticky rice cake",       calories: 350, time: "10 min"),
    FoodModel(id: 10,  name: "Khmer Curry",          categoryId: 1, price: 5.00,  imageUrl: "assets/images/Curry.png",         description: "Rich and spicy chicken curry",       calories: 500, time: "25 min"),
    FoodModel(id: 109, name: "Prahok Ktis",          categoryId: 1, price: 4.00,  imageUrl: "assets/images/Brohok.png",        description: "Minced pork with fermented fish",    calories: 400, time: "20 min"),
    FoodModel(id: 110, name: "Bai Sach Chrouk",      categoryId: 1, price: 2.00,  imageUrl: "assets/images/Bay sach jruk.png",description: "Pork and rice breakfast",            calories: 450, time: "5 min"),
    FoodModel(id: 111, name: "Kralan",               categoryId: 1, price: 1.50,  imageUrl: "assets/images/krolan.png",        description: "Bamboo sticky rice",                 calories: 200, time: "5 min"),
    FoodModel(id: 112, name: "Nom Banh Chok",        categoryId: 1, price: 2.50,  imageUrl: "assets/images/Nom banh jok.png",  description: "Khmer noodles with fish gravy",      calories: 300, time: "10 min"),
  ];

  final List<FoodModel> discountFoods = [
    FoodModel(id: 11,  name: "Spicy Wings",          categoryId: 1, price: 3.00, originalPrice: 6.00, imageUrl: "assets/images/wings grill.png", description: "Hot and spicy chicken wings",  calories: 400, time: "15 min"),
    FoodModel(id: 12,  name: "Fried Rice",           categoryId: 1, price: 2.50, originalPrice: 5.00, imageUrl: "assets/images/Bay cha.png",      description: "Pork fried rice with egg",     calories: 450, time: "20 min"),
    FoodModel(id: 113, name: "Beef Tacos",           categoryId: 1, price: 3.50, originalPrice: 7.00, imageUrl: "assets/images/Tacos.png",        description: "Mexican street tacos",         calories: 300, time: "10 min"),
    FoodModel(id: 114, name: "Pork Dumplings",       categoryId: 1, price: 2.00, originalPrice: 4.00, imageUrl: "assets/images/dumpling.png",     description: "Steamed meat dumplings",       calories: 250, time: "15 min"),
    FoodModel(id: 115, name: "Dim Sum",              categoryId: 1, price: 4.00, originalPrice: 8.00, imageUrl: "assets/images/dum sum.png",      description: "Assorted Chinese bites",       calories: 350, time: "20 min"),
  ];

  @override
  void initState() {
    super.initState();
    // Simulate network delay for skeleton
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner skeleton
            Row(
              children: [
                Expanded(child: SkeletonWidget(width: double.infinity, height: 120, borderRadius: BorderRadius.circular(15))),
                const SizedBox(width: 15),
                Expanded(child: SkeletonWidget(width: double.infinity, height: 120, borderRadius: BorderRadius.circular(15))),
              ],
            ),
            const SizedBox(height: 30),
            const HomeSectionSkeleton(),
            const HomeSectionSkeleton(),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          _buildHorizontalSection("🔥 Discount 50%", discountFoods, context),
          _buildHorizontalSection("⭐ Popular", popularFoods, context),
          _buildHorizontalSection("🎊 Happy Khmer New Year", khmerNewYear, context),
          _buildHorizontalSection("🏆 Best Selling", bestSelling, context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHorizontalSection(String title, List<FoodModel> items, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () async {
                final addedFood = await Navigator.push(context, MaterialPageRoute(builder: (_) => SeeAllScreen(allFoods: items, title: title)));
                if (addedFood is FoodModel) widget.onDetailAdded?.call();
              },
              child: const Text("See All", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final food = items[index];
              return GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(food: food)));
                  if (result is int && result > 0) widget.onDetailAdded?.call();
                },
                child: _buildFoodCard(food, context),
              );
            },
          ),
        ),
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildFoodCard(FoodModel food, BuildContext context) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (food.originalPrice != null) ...[
                Text("\$${food.originalPrice!.toStringAsFixed(2)}", style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 11)),
                const SizedBox(width: 5),
              ],
              Text("\$${food.price.toStringAsFixed(2)}", style: TextStyle(color: food.originalPrice != null ? Colors.red : Colors.orange, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Image.asset(food.imageUrl, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.fastfood, size: 50, color: Colors.grey)),
                ),
                if (food.originalPrice != null)
                  Positioned(top: 5, left: 0, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)), child: const Text("PROMO", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)))),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [const Icon(Icons.local_fire_department, color: Colors.orange, size: 14), const SizedBox(width: 4), Text("${food.calories} Cal", style: const TextStyle(fontSize: 10, color: Colors.grey))]),
                  const SizedBox(height: 4),
                  Row(children: [const Icon(Icons.access_time_filled, color: Colors.orangeAccent, size: 14), const SizedBox(width: 4), Text(food.time, style: const TextStyle(fontSize: 10, color: Colors.grey))]),
                ],
              ),
              GestureDetector(
                onTap: () => widget.onAddToCart(food),
                child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.add, color: Colors.white, size: 18)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}