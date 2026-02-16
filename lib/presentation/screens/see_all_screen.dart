import 'package:flutter/material.dart';
import 'package:amork/data/models/food_model.dart';
import 'detail_screen.dart';

class SeeAllScreen extends StatelessWidget {
  final List<FoodModel> allFoods;
  final String title;

  const SeeAllScreen({super.key, required this.allFoods, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: allFoods.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 15, mainAxisSpacing: 15,
          ),
          itemBuilder: (context, index) {
            final food = allFoods[index];

            return GestureDetector(
              onTap: () async {
                final addedFood = await Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(food: food)));
                if (addedFood != null) Navigator.pop(context, addedFood); 
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    
                    // DISCOUNT PRICE LOGIC
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
                          Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Image.asset(food.imageUrl, fit: BoxFit.contain)),
                          if (food.originalPrice != null)
                            Positioned(
                              top: 5, left: 0,
                              child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)), child: const Text("PROMO", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
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
                        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.add, color: Colors.white, size: 18)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}