import 'package:flutter/material.dart';
import 'package:amork/data/models/food_model.dart';
import 'detail_screen.dart';
import 'see_all_screen.dart';
import 'package:amork/presentation/screens/skeleton_widget.dart';

class SnackView extends StatefulWidget {
  final Function(FoodModel) onAddToCart;
  final VoidCallback? onDetailAdded;
  const SnackView({super.key, required this.onAddToCart, this.onDetailAdded});

  @override
  State<SnackView> createState() => _SnackViewState();
}

class _SnackViewState extends State<SnackView> {
  bool _isLoading = true;

  final List<FoodModel> discountSnacks = [
    FoodModel(id: 401, name: "Crispy Fries",  categoryId: 4, price: 1.50, originalPrice: 3.00, imageUrl: "assets/images/fries.png",       description: "Hot salty french fries",   calories: 300, time: "10 min"),
    FoodModel(id: 402, name: "Cheese Nachos", categoryId: 4, price: 2.25, originalPrice: 4.50, imageUrl: "assets/images/nachos.png",      description: "Chips with melted cheese", calories: 400, time: "10 min"),
    FoodModel(id: 403, name: "Onion Rings",   categoryId: 4, price: 1.75, originalPrice: 3.50, imageUrl: "assets/images/onion_rings.png", description: "Deep fried onion rings",   calories: 350, time: "15 min"),
    FoodModel(id: 404, name: "Movie Popcorn", categoryId: 4, price: 1.00, originalPrice: 2.00, imageUrl: "assets/images/popcorn.png",     description: "Buttery popcorn",          calories: 200, time: "5 min"),
    FoodModel(id: 405, name: "Potato Chips",  categoryId: 4, price: 0.75, originalPrice: 1.50, imageUrl: "assets/images/chips.png",       description: "Crunchy salted chips",     calories: 150, time: "2 min"),
  ];

  final List<FoodModel> popularSnacks = [
    FoodModel(id: 406, name: "Soft Pretzel",      categoryId: 4, price: 3.00, imageUrl: "assets/images/pretzel.png",      description: "Warm salted pretzel",        calories: 280, time: "5 min"),
    FoodModel(id: 407, name: "Chicken Nuggets",   categoryId: 4, price: 4.50, imageUrl: "assets/images/nuggets.png",      description: "6 piece golden nuggets",     calories: 380, time: "10 min"),
    FoodModel(id: 408, name: "Mozzarella Sticks", categoryId: 4, price: 5.00, imageUrl: "assets/images/mozzarella.png",   description: "Fried cheese with marinara", calories: 450, time: "12 min"),
    FoodModel(id: 409, name: "Garlic Bread",      categoryId: 4, price: 3.50, imageUrl: "assets/images/garlic_bread.png", description: "Toasted buttery bread",      calories: 300, time: "8 min"),
    FoodModel(id: 410, name: "Spring Rolls",      categoryId: 4, price: 4.00, imageUrl: "assets/images/spring_rolls.png", description: "Crispy veggie rolls",        calories: 250, time: "10 min"),
  ];

  final List<FoodModel> eventSnacks = [
    FoodModel(id: 411, name: "Meat Samosa",     categoryId: 4, price: 3.50, imageUrl: "assets/images/samosa.png",       description: "Fried pastry with filling",  calories: 350, time: "12 min"),
    FoodModel(id: 412, name: "Edamame",         categoryId: 4, price: 3.00, imageUrl: "assets/images/edamame.png",      description: "Steamed soybeans with salt", calories: 120, time: "5 min"),
    FoodModel(id: 413, name: "Cheese Crackers", categoryId: 4, price: 2.00, imageUrl: "assets/images/crackers.png",     description: "Baked snack crackers",       calories: 180, time: "2 min"),
    FoodModel(id: 414, name: "Roasted Nuts",    categoryId: 4, price: 4.00, imageUrl: "assets/images/roasted_nuts.png", description: "Mixed salted nuts",          calories: 400, time: "2 min"),
    FoodModel(id: 415, name: "Dried Fruit Mix", categoryId: 4, price: 3.50, imageUrl: "assets/images/dried_fruit.png",  description: "Healthy dried fruits",       calories: 250, time: "2 min"),
  ];

  final List<FoodModel> bestSellingSnacks = [
    FoodModel(id: 416, name: "Potato Wedges", categoryId: 4, price: 3.50, imageUrl: "assets/images/wedges.png",      description: "Thick cut seasoned fries", calories: 320, time: "15 min"),
    FoodModel(id: 417, name: "Corn Dog",      categoryId: 4, price: 2.50, imageUrl: "assets/images/corn_dog.png",    description: "Fried sausage on a stick", calories: 300, time: "10 min"),
    FoodModel(id: 418, name: "Hash Browns",   categoryId: 4, price: 2.00, imageUrl: "assets/images/hash_browns.png", description: "Crispy fried potato",      calories: 250, time: "8 min"),
    FoodModel(id: 419, name: "Tater Tots",    categoryId: 4, price: 3.00, imageUrl: "assets/images/tater_tots.png",  description: "Bite-sized potato puffs",  calories: 280, time: "10 min"),
    FoodModel(id: 420, name: "Beef Jerky",    categoryId: 4, price: 6.00, imageUrl: "assets/images/beef_jerky.png",  description: "Dried and seasoned beef",  calories: 200, time: "2 min"),
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
          _buildHorizontalSection("🔥 Discount 50%", discountSnacks, context),
          _buildHorizontalSection("⭐ Popular", popularSnacks, context),
          _buildHorizontalSection("🎊 Happy Khmer New Year", eventSnacks, context),
          _buildHorizontalSection("🏆 Best Selling", bestSellingSnacks, context),
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
                      errorBuilder: (c, e, s) => const Icon(Icons.cookie, size: 50, color: Colors.grey)),
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