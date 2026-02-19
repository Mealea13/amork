import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amork/core/app_config.dart';
import 'package:amork/data/models/food_model.dart';

class DetailScreen extends StatefulWidget {
  final FoodModel food;

  const DetailScreen({super.key, required this.food});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int quantity = 1;
  bool isAddingToCart = false;

  // ── Favorite ──
  bool _isFavorite = false;
  bool _isTogglingFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _checkFavorite() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/favorites/check/${widget.food.id}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _isFavorite = data['isFavorite'] ?? false);
      }
    } catch (e) {
      debugPrint('Check favorite error: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() => _isTogglingFavorite = true);
    try {
      final token = await _getToken();
      if (_isFavorite) {
        await http.delete(
          Uri.parse('${AppConfig.baseUrl}/api/favorites/remove/${widget.food.id}'),
          headers: {'Authorization': 'Bearer $token'},
        );
      } else {
        await http.post(
          Uri.parse('${AppConfig.baseUrl}/api/favorites/add'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'food_id': widget.food.id}),
        );
      }
      setState(() => _isFavorite = !_isFavorite);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isFavorite ? 'Added to favorites ❤️' : 'Removed from favorites'),
          backgroundColor: _isFavorite ? Colors.red : Colors.grey,
          duration: const Duration(seconds: 1),
        ));
      }
    } catch (e) {
      debugPrint('Toggle favorite error: $e');
    } finally {
      if (mounted) setState(() => _isTogglingFavorite = false);
    }
  }

  double get totalPrice => widget.food.price * quantity;

  double? get totalOriginalPrice {
    if (widget.food.originalPrice == null) return null;
    return widget.food.originalPrice! * quantity;
  }

  Future<void> _addToCart() async {
    setState(() => isAddingToCart = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('${AppConfig.cartEndpoint}/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'food_id': widget.food.id,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) Navigator.pop(context, quantity);
      } else {
        throw Exception("Failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add to cart')),
        );
      }
    } finally {
      if (mounted) setState(() => isAddingToCart = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      body: Column(
        children: [
          // ── Top bar ──
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                  ),
                  _isTogglingFavorite
                      ? const SizedBox(
                          width: 28, height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                        )
                      : GestureDetector(
                          onTap: _toggleFavorite,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              _isFavorite ? Icons.favorite : Icons.favorite_border,
                              key: ValueKey(_isFavorite),
                              color: _isFavorite ? Colors.red : Colors.grey,
                              size: 28,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),

          // ── Food Image ──
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Image.asset(
              widget.food.imageUrl,
              height: 220,
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.fastfood, size: 100, color: Colors.grey),
            ),
          ),

          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // ── Rating & Price ──
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3D6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(children: [
                                  Icon(Icons.star, color: Colors.orange, size: 18),
                                  SizedBox(width: 5),
                                  Text("4.8", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ]),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (totalOriginalPrice != null)
                                    Text(
                                      "\$${totalOriginalPrice!.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey, fontSize: 14,
                                      ),
                                    ),
                                  Text(
                                    "\$${totalPrice.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontSize: 24, fontWeight: FontWeight.bold,
                                      color: totalOriginalPrice != null ? Colors.red : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // ── Name & Quantity ──
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.food.name,
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (quantity > 1) setState(() => quantity--);
                                    },
                                    child: const Icon(Icons.remove_circle, color: Colors.orange, size: 30),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text('$quantity',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  ),
                                  GestureDetector(
                                    onTap: () => setState(() => quantity++),
                                    child: const Icon(Icons.add_circle, color: Colors.orange, size: 30),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // ── Calories & Time ──
                          Row(
                            children: [
                              const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                              const SizedBox(width: 4),
                              Text("${widget.food.calories} Cal",
                                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
                              const SizedBox(width: 16),
                              const Icon(Icons.access_time_filled, color: Colors.orangeAccent, size: 16),
                              const SizedBox(width: 4),
                              Text(widget.food.time,
                                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // ── Description ──
                          Text(
                            widget.food.description,
                            style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // ── Add to Cart Button ──
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF3D6),
                      minimumSize: const Size(double.infinity, 55),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: isAddingToCart ? null : _addToCart,
                    child: isAddingToCart
                        ? const SizedBox(
                            height: 22, width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.shopping_cart_outlined, color: Colors.black, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Add to Cart  •  \$${totalPrice.toStringAsFixed(2)}",
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}