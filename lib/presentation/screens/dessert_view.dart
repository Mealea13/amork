import 'package:flutter/material.dart';
import 'package:amork/data/models/food_model.dart';
import 'detail_screen.dart';
import 'see_all_screen.dart';
import 'package:amork/presentation/screens/skeleton_widget.dart';

class DessertView extends StatefulWidget {
  final Function(FoodModel) onAddToCart;
  final VoidCallback? onDetailAdded;
  const DessertView({super.key, required this.onAddToCart, this.onDetailAdded});

  @override
  State<DessertView> createState() => _DessertViewState();
}

class _DessertViewState extends State<DessertView> {
  bool _isLoading = true;

  final List<FoodModel> discountDesserts = [
    FoodModel(id: 301, name: "Strawberry Cake",   categoryId: 3, price: 2.25, originalPrice: 4.50, imageUrl: "assets/images/cake.png",      description: "Sweet and creamy dessert",   calories: 450, time: "10 min"),
    FoodModel(id: 302, name: "Vanilla Ice Cream", categoryId: 3, price: 1.25, originalPrice: 2.50, imageUrl: "assets/images/ice_cream.png", description: "Two scoops of vanilla",      calories: 300, time: "2 min"),
    FoodModel(id: 303, name: "Chocolate Brownie", categoryId: 3, price: 1.50, originalPrice: 3.00, imageUrl: "assets/images/brownie.png",   description: "Warm chocolate fudge",       calories: 400, time: "5 min"),
    FoodModel(id: 304, name: "Pancakes",          categoryId: 3, price: 2.00, originalPrice: 4.00, imageUrl: "assets/images/pancakes.png",  description: "Fluffy pancakes with syrup", calories: 350, time: "10 min"),
    FoodModel(id: 305, name: "Belgian Waffles",   categoryId: 3, price: 2.25, originalPrice: 4.50, imageUrl: "assets/images/waffles.png",   description: "Crispy waffles with honey",  calories: 380, time: "10 min"),
  ];

  final List<FoodModel> popularDesserts = [
    FoodModel(id: 306, name: "NY Cheesecake",   categoryId: 3, price: 5.00, imageUrl: "assets/images/cheesecake.png", description: "Classic creamy slice",       calories: 500, time: "5 min"),
    FoodModel(id: 307, name: "Tiramisu",        categoryId: 3, price: 5.50, imageUrl: "assets/images/tiramisu.png",   description: "Italian coffee dessert",     calories: 450, time: "5 min"),
    FoodModel(id: 308, name: "Macarons (3pcs)", categoryId: 3, price: 6.00, imageUrl: "assets/images/macarons.png",   description: "French almond cookies",      calories: 200, time: "2 min"),
    FoodModel(id: 309, name: "Glazed Donut",    categoryId: 3, price: 1.50, imageUrl: "assets/images/donut.png",      description: "Sweet sugar ring",           calories: 250, time: "2 min"),
    FoodModel(id: 310, name: "Churros",         categoryId: 3, price: 3.50, imageUrl: "assets/images/churros.png",    description: "Fried dough with chocolate", calories: 350, time: "8 min"),
  ];

  final List<FoodModel> eventDesserts = [
    FoodModel(id: 311, name: "Caramel Pudding",    categoryId: 3, price: 3.00, imageUrl: "assets/images/pudding.png",  description: "Soft flan dessert",             calories: 250, time: "5 min"),
    FoodModel(id: 312, name: "Fruit Tart",         categoryId: 3, price: 4.00, imageUrl: "assets/images/tart.png",     description: "Crispy shell with fresh fruit", calories: 300, time: "5 min"),
    FoodModel(id: 313, name: "Mango Gelato",       categoryId: 3, price: 3.50, imageUrl: "assets/images/gelato.png",   description: "Italian style ice cream",       calories: 220, time: "3 min"),
    FoodModel(id: 314, name: "Chocolate Mousse",   categoryId: 3, price: 4.50, imageUrl: "assets/images/mousse.png",   description: "Light and airy chocolate",      calories: 350, time: "5 min"),
    FoodModel(id: 315, name: "Red Velvet Cupcake", categoryId: 3, price: 2.50, imageUrl: "assets/images/cupcake.png",  description: "Small cake with frosting",      calories: 280, time: "3 min"),
  ];

  final List<FoodModel> bestSellingDesserts = [
    FoodModel(id: 316, name: "Lemon Sorbet",       categoryId: 3, price: 2.50, imageUrl: "assets/images/sorbet.png",  description: "Dairy-free frozen treat",     calories: 150, time: "3 min"),
    FoodModel(id: 317, name: "Korean Bingsu",      categoryId: 3, price: 7.00, imageUrl: "assets/images/bingsu.png",  description: "Shaved ice with sweet beans", calories: 500, time: "10 min"),
    FoodModel(id: 318, name: "French Crepes",      categoryId: 3, price: 4.50, imageUrl: "assets/images/crepes.png",  description: "Thin pancake with Nutella",   calories: 400, time: "8 min"),
    FoodModel(id: 319, name: "Chocolate Eclair",   categoryId: 3, price: 3.50, imageUrl: "assets/images/eclair.png",  description: "Cream-filled pastry",         calories: 300, time: "5 min"),
    FoodModel(id: 320, name: "Choco Chip Cookies", categoryId: 3, price: 2.00, imageUrl: "assets/images/cookies.png", description: "Two warm cookies",            calories: 250, time: "3 min"),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            HomeSectionSkeleton(),
            HomeSectionSkeleton(),
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
          _buildHorizontalSection("🔥 Discount 50%", discountDesserts, context),
          _buildHorizontalSection("⭐ Popular", popularDesserts, context),
          _buildHorizontalSection("🎊 Happy Khmer New Year", eventDesserts, context),
          _buildHorizontalSection("🏆 Best Selling", bestSellingDesserts, context),
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
                child: _buildCard(food),
              );
            },
          ),
        ),
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildCard(FoodModel food) {
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
                  child: Image.asset(food.imageUrl, fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => const Icon(Icons.cake, size: 50, color: Colors.grey)),
                ),
                if (food.originalPrice != null)
                  Positioned(
                    top: 5, left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                      child: const Text("PROMO", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ),
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