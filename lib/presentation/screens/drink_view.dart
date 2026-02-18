import 'package:flutter/material.dart';
import 'package:amork/data/models/food_model.dart';
import 'detail_screen.dart';
import 'see_all_screen.dart';
class DrinkView extends StatelessWidget {
  final Function(FoodModel) onAddToCart;

  DrinkView({super.key, required this.onAddToCart});

  final List<FoodModel> discountDrinks = [
    FoodModel(id: 201, name: "Fresh Lemonade", categoryId: 2, price: 1.00, originalPrice: 2.00, imageUrl: "assets/images/lemonade.png", description: "Cold refreshing drink", calories: 120, time: "2 min"),
    FoodModel(id: 202, name: "Iced Coffee", categoryId: 2, price: 1.75, originalPrice: 3.50, imageUrl: "assets/images/iced latte.png", description: "Sweet iced coffee", calories: 200, time: "3 min"),
    FoodModel(id: 203, name: "Coca Cola", categoryId: 2, price: 0.75, originalPrice: 1.50, imageUrl: "assets/images/coke.png", description: "Classic soda", calories: 140, time: "1 min"),
    FoodModel(id: 204, name: "Brown Sugar Boba", categoryId: 2, price: 2.00, originalPrice: 4.00, imageUrl: "assets/images/Boba.png", description: "Milk tea with sweet pearls", calories: 350, time: "5 min"),
    FoodModel(id: 205, name: "Mango Smoothie", categoryId: 2, price: 1.50, originalPrice: 3.00, imageUrl: "assets/images/smoothies.png", description: "Blended fresh mango", calories: 250, time: "5 min"),
  ];

  final List<FoodModel> popularDrinks = [
    FoodModel(id: 206, name: "Green Tea", categoryId: 2, price: 2.50, imageUrl: "assets/images/green-tea.png", description: "Healthy hot green tea", calories: 0, time: "3 min"),
    FoodModel(id: 207, name: "Matcha Latte", categoryId: 2, price: 4.50, imageUrl: "assets/images/matcha-latte.png", description: "Premium Japanese matcha", calories: 220, time: "5 min"),
    FoodModel(id: 208, name: "Americano", categoryId: 2, price: 2.50, imageUrl: "assets/images/pngtree-americano-coffee-.png", description: "Black coffee", calories: 10, time: "3 min"),
    FoodModel(id: 209, name: "Cappuccino", categoryId: 2, price: 3.50, imageUrl: "assets/images/coffee-cappuccino.png", description: "Espresso with milk foam", calories: 150, time: "4 min"),
    FoodModel(id: 210, name: "Orange Juice", categoryId: 2, price: 3.00, imageUrl: "assets/images/orange-juice.png", description: "Freshly squeezed", calories: 110, time: "2 min"),
  ];

  final List<FoodModel> eventDrinks = [
    FoodModel(id: 211, name: "Apple Juice", categoryId: 2, price: 2.50, imageUrl: "assets/images/apple_juice.png", description: "Sweet apple juice", calories: 100, time: "2 min"),
    FoodModel(id: 212, name: "Strawberry Shake", categoryId: 2, price: 5.00, imageUrl: "assets/images/milkshake.png", description: "Thick creamy shake", calories: 500, time: "5 min"),
    FoodModel(id: 213, name: "Caramel Frappe", categoryId: 2, price: 5.50, imageUrl: "assets/images/frappe.png", description: "Blended coffee with caramel", calories: 550, time: "6 min"),
    FoodModel(id: 214, name: "Hot Mocha", categoryId: 2, price: 4.00, imageUrl: "assets/images/mocha.png", description: "Coffee mixed with chocolate", calories: 250, time: "4 min"),
    FoodModel(id: 215, name: "Hot Chocolate", categoryId: 2, price: 3.50, imageUrl: "assets/images/hot_choco.png", description: "Warm cocoa with marshmallows", calories: 300, time: "5 min"),
  ];

  final List<FoodModel> bestSellingDrinks = [
    FoodModel(id: 216, name: "Fresh Coconut", categoryId: 2, price: 2.00, imageUrl: "assets/images/coconut.png", description: "Whole fresh coconut", calories: 50, time: "1 min"),
    FoodModel(id: 217, name: "Passion Fruit", categoryId: 2, price: 3.00, imageUrl: "assets/images/passion_fruit_juice.png", description: "Sweet and sour tropical drink", calories: 130, time: "3 min"),
    FoodModel(id: 218, name: "Club Soda", categoryId: 2, price: 1.00, imageUrl: "assets/images/soda.png", description: "Sparkling water", calories: 0, time: "1 min"),
    FoodModel(id: 219, name: "Mineral Water", categoryId: 2, price: 0.50, imageUrl: "assets/images/water.png", description: "Bottled water", calories: 0, time: "1 min"),
    FoodModel(id: 220, name: "Energy Drink", categoryId: 2, price: 2.50, imageUrl: "assets/images/Energy_drink.png", description: "Red Bull energy", calories: 110, time: "1 min"),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHorizontalSection("🔥 Discount 50%", discountDrinks, context),
          _buildHorizontalSection("⭐ Popular", popularDrinks, context),
          _buildHorizontalSection("🎊 Happy Khmer New Year", eventDrinks, context),
          _buildHorizontalSection("🏆 Best Selling", bestSellingDrinks, context),
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
                if (addedFood != null) onAddToCart(addedFood);
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
                  final addedFood = await Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(food: food)));
                  if (addedFood != null) onAddToCart(addedFood);
                },
                child: Container(
                  width: 170, 
                  margin: const EdgeInsets.only(right: 15),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))]),
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
                            Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Image.asset(food.imageUrl, fit: BoxFit.contain, errorBuilder: (c,e,s) => const Icon(Icons.local_drink, size: 50, color: Colors.grey))),
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
                            onTap: () => onAddToCart(food), 
                            child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.add, color: Colors.white, size: 18))
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 25), 
      ],
    );
  }
}