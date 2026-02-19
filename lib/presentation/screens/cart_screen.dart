import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amork/core/app_config.dart';
import 'payment_screen.dart';
import 'package:amork/presentation/screens/skeleton_widget.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback onCheckoutSuccess;
  final Function(int totalQty)? onCartCountChanged;

  const CartScreen({
    super.key,
    required this.onCheckoutSuccess,
    this.onCartCountChanged,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController instructionController = TextEditingController();
  List<dynamic> cartItems = [];
  bool isLoading = true;
  double total = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchCart();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  int get _totalQuantity =>
      cartItems.fold(0, (sum, item) => sum + ((item['quantity'] ?? 1) as int));

  Future<void> _fetchCart() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse(AppConfig.cartEndpoint),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          cartItems = data['items'] ?? [];
          total = (data['total'] ?? 0.0).toDouble();
        });
      } else {
        setState(() {
          cartItems = [];
          total = 0.0;
        });
      }
    } catch (e) {
      debugPrint('Fetch cart error: $e');
      setState(() {
        cartItems = [];
        total = 0.0;
      });
    } finally {
      setState(() => isLoading = false);
      widget.onCartCountChanged?.call(_totalQuantity);
    }
  }

  Future<void> _removeItem(dynamic cartItemId) async {
    try {
      final token = await _getToken();
      final response = await http.delete(
        Uri.parse('${AppConfig.cartEndpoint}/$cartItemId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        await _fetchCart();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item removed'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Remove item error: $e');
    }
  }

  Future<void> _clearCart() async {
    try {
      final token = await _getToken();
      await http.delete(
        Uri.parse('${AppConfig.cartEndpoint}/clear'),
        headers: {'Authorization': 'Bearer $token'},
      );
    } catch (e) {
      debugPrint('Clear cart error: $e');
    }
  }

  Future<void> _updateQuantity(dynamic cartItemId, int newQuantity) async {
    if (newQuantity < 1) {
      await _removeItem(cartItemId);
      return;
    }
    try {
      final token = await _getToken();
      await http.put(
        Uri.parse('${AppConfig.cartEndpoint}/$cartItemId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'quantity': newQuantity}),
      );
      await _fetchCart();
    } catch (e) {
      debugPrint('Update quantity error: $e');
    }
  }

  List<Map<String, dynamic>> _getCartItemsForPayment() {
    return cartItems.map<Map<String, dynamic>>((item) => {
          'food_id': item['food_id'],
          'food_name': item['food_name'] ?? item['name'] ?? '',
          'quantity': item['quantity'] ?? 1,
          'price': (item['price'] ?? 0.0).toDouble(),
        }).toList();
  }

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

              // ── Header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "My Cart (${isLoading ? '...' : _totalQuantity})",
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  if (cartItems.isNotEmpty)
                    GestureDetector(
                      onTap: () async {
                        await _clearCart();
                        await _fetchCart();
                      },
                      child: const Text("Clear All",
                          style: TextStyle(color: Colors.red, fontSize: 13)),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Body ── (FIXED: removed duplicate if (isLoading))
              if (isLoading)
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    itemCount: 4,
                    itemBuilder: (_, __) => const CartItemSkeleton(),
                  ),
                )
              else if (cartItems.isEmpty)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            size: 80, color: Colors.grey),
                        SizedBox(height: 15),
                        Text("Your cart is empty.",
                            style:
                                TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchCart,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        final itemId = item['id'] ?? item['cart_item_id'];
                        final int qty = item['quantity'] ?? 1;
                        final double price =
                            (item['price'] ?? 0.0).toDouble();
                        final String imageUrl = item['image_url'] ?? '';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Food Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: imageUrl.startsWith('http')
                                    ? Image.network(
                                        imageUrl,
                                        height: 60,
                                        width: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) =>
                                            const Icon(Icons.fastfood,
                                                size: 60),
                                      )
                                    : Image.asset(
                                        imageUrl,
                                        height: 60,
                                        width: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) =>
                                            const Icon(Icons.fastfood,
                                                size: 60),
                                      ),
                              ),
                              const SizedBox(width: 12),

                              // Name & Price
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['food_name'] ??
                                          item['name'] ??
                                          'Unknown',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "\$${(price * qty).toStringAsFixed(2)}",
                                      style: const TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),

                              // Quantity Controls
                              Row(
                                children: [
                                  _qtyButton(Icons.remove,
                                      () => _updateQuantity(itemId, qty - 1)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text('$qty',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                  ),
                                  _qtyButton(Icons.add,
                                      () => _updateQuantity(itemId, qty + 1)),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // ── Bottom Section ──
              if (cartItems.isNotEmpty) ...[
                const Text("Order Instructions",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                TextField(
                  controller: instructionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: "Add special instructions...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(
                      "\$${total.toStringAsFixed(2)}",
                      style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentScreen(
                          total: total,
                          cartItems: _getCartItemsForPayment(),
                        ),
                      ),
                    );
                    await _fetchCart();
                    widget.onCheckoutSuccess();
                  },
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1E6D3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "Checkout",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFFF1E6D3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}