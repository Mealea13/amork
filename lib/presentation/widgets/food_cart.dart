import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amork/data/models/food_model.dart';
import 'package:amork/providers/cart_provider.dart';

class FoodCard extends StatelessWidget {
  final FoodModel food;

  const FoodCard({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 15),
          // 1. Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              food.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          // 2. Price
          Text(
            "\$${food.price.toStringAsFixed(2)}",
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 10),
          // 3. Image Circle
          Container(
            height: 100,
            width: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
              ],
            ),
            child: ClipOval(
              child: Image.network(
                food.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) => const Icon(Icons.fastfood, size: 40, color: Colors.orange),
              ),
            ),
          ),
          const Spacer(),
          // 4. Info Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIconText(Icons.local_fire_department, "${food.calories} Cal"),
                GestureDetector(
                  onTap: () {
                    cartProvider.addToCart(food);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Added ${food.name} to cart"), 
                        duration: const Duration(milliseconds: 800),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.orangeAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 5),
           Padding(
            padding: const EdgeInsets.only(left: 12.0, bottom: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildIconText(Icons.access_time, food.time),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.orange),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}