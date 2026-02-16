import 'package:amork/data/models/food_model.dart';
import 'package:flutter/material.dart';

class DetailScreen extends StatefulWidget {
  final FoodModel food;

  const DetailScreen({super.key, required this.food});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7), 
      body: Column(
        children: [
          // ================= TOP SECTION =================
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context), 
                  child: const Icon(Icons.arrow_back, color: Colors.black, size: 28)
                ),
              ),
            ),
          ),
          
          // Big Food Image
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Image.asset(widget.food.imageUrl, height: 250, fit: BoxFit.contain, errorBuilder: (c,e,s) => const Icon(Icons.fastfood, size: 100, color: Colors.grey)),
          ),

          // ================= BOTTOM SECTION =================
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Rating & Price Row ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: const Color(0xFFFFF3D6), borderRadius: BorderRadius.circular(20)),
                                child: Row(children: const [Icon(Icons.star, color: Colors.orange, size: 18), SizedBox(width: 5), Text("4.8", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
                              ),
                              
                              // DISCOUNT PRICE LOGIC
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (widget.food.originalPrice != null)
                                    Text("\$${(widget.food.originalPrice! * quantity).toStringAsFixed(2)}", style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 14)),
                                  Text(
                                    "\$${(widget.food.price * quantity).toStringAsFixed(2)}",
                                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: widget.food.originalPrice != null ? Colors.red : Colors.orange),
                                  ),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 20),

                          // --- Title & Quantity Selector ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(widget.food.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                              Row(
                                children: [
                                  GestureDetector(onTap: () { if (quantity > 1) setState(() => quantity--); }, child: const Icon(Icons.remove_circle, color: Colors.orange, size: 28)),
                                  Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('$quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                                  GestureDetector(onTap: () => setState(() => quantity++), child: const Icon(Icons.add_circle, color: Colors.orange, size: 28)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          // --- Description ---
                          Text(widget.food.description, style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5)),
                          const SizedBox(height: 20),

                          // --- Add-ons Section (ONLY FOR CATEGORY 1: FOOD) ---
                          if (widget.food.categoryId == 1) ...[
                            const Text("Add ons", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _addOnItem("assets/images/cheese.png"),
                                _addOnItem("assets/images/amork.png"),
                                _addOnItem("assets/images/cheese.png"),
                              ],
                            ),
                            const SizedBox(height: 20), 
                          ],
                        ],
                      ),
                    ),
                  ),

                  // --- Add to Cart Button ---
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF3D6), 
                      minimumSize: const Size(double.infinity, 55), 
                      elevation: 0, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                    ),
                    onPressed: () {
                      final cartItem = FoodModel(
                        id: widget.food.id, 
                        name: widget.food.name, 
                        categoryId: widget.food.categoryId,
                        price: widget.food.price * quantity, 
                        originalPrice: widget.food.originalPrice != null ? widget.food.originalPrice! * quantity : null,
                        imageUrl: widget.food.imageUrl, 
                        description: widget.food.description, 
                        calories: widget.food.calories, 
                        time: widget.food.time,
                      );
                      Navigator.pop(context, cartItem);
                    },
                    child: const Text("Add to Cart", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build the little Add-on boxes with the green "+"
  Widget _addOnItem(String imagePath) {
    return Container(
      width: 65, height: 65, margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(color: const Color(0xFFF9F6F0), borderRadius: BorderRadius.circular(15)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(child: Image.asset(imagePath, height: 40, fit: BoxFit.contain, errorBuilder: (c,e,s) => const Icon(Icons.fastfood, color: Colors.grey))),
          Positioned(
            bottom: -5, right: -5, 
            child: Container(
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), 
              child: const Icon(Icons.add_circle, color: Colors.green, size: 24)
            )
          ),
        ],
      ),
    );
  }
}