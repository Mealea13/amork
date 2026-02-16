import 'package:flutter/material.dart';
import 'package:amork/data/models/food_model.dart';
import 'payment_screen.dart';

class CartScreen extends StatefulWidget {
  final List<FoodModel> cart;
  final Function(int) onRemoveItem;
  final VoidCallback onCheckoutSuccess;

  const CartScreen({super.key, required this.cart, required this.onRemoveItem, required this.onCheckoutSuccess});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController instructionController = TextEditingController();

  double get total => widget.cart.fold(0.0, (sum, item) => sum + item.price);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("My Cart (${widget.cart.length})", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              if (widget.cart.isEmpty)
                const Expanded(child: Center(child: Text("Your cart is empty.", style: TextStyle(color: Colors.grey, fontSize: 16))))
              else
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: widget.cart.length,
                    itemBuilder: (context, index) {
                      final item = widget.cart[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))]),
                        child: Row(
                          children: [
                            Image.asset(item.imageUrl, height: 60, width: 60),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      if (item.originalPrice != null) ...[
                                        Text("\$${item.originalPrice!.toStringAsFixed(2)}", style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12)),
                                        const SizedBox(width: 5),
                                      ],
                                      Text("\$${item.price.toStringAsFixed(2)}", style: TextStyle(color: item.originalPrice != null ? Colors.red : Colors.orange, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(icon: const Icon(Icons.close, color: Colors.red, size: 20), onPressed: () => widget.onRemoveItem(index)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
              if (widget.cart.isNotEmpty) ...[
                const Text("Order Instructions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                TextField(controller: instructionController, maxLines: 2, decoration: InputDecoration(hintText: "Add special instructions...", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none))),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text("\$${total.toStringAsFixed(2)}", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: () async {
                    final success = await Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentScreen(total: total)));
                    if (success == true) widget.onCheckoutSuccess();
                  },
                  child: Container(height: 55, decoration: BoxDecoration(color: const Color(0xFFF1E6D3), borderRadius: BorderRadius.circular(20)), alignment: Alignment.center, child: const Text("Checkout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                ),
                const SizedBox(height: 10),
              ]
            ],
          ),
        ),
      ),
    );
  }
}