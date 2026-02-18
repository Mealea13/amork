import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amork/core/app_config.dart';
import 'detail_screen.dart';
import 'package:amork/data/models/food_model.dart';

class FavoriteScreen extends StatefulWidget {
  final Function(FoodModel)? onAddToCart;
  const FavoriteScreen({super.key, this.onAddToCart});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<dynamic> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _fetchFavorites() async {
    setState(() => _isLoading = true);
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/favorites'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _favorites = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Fetch favorites error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFavorite(int foodId) async {
    try {
      final token = await _getToken();
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/api/favorites/remove/$foodId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        _fetchFavorites();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Removed from favorites'), backgroundColor: Colors.red, duration: Duration(seconds: 1)),
          );
        }
      }
    } catch (e) {
      debugPrint('Remove favorite error: $e');
    }
  }

  FoodModel _toFoodModel(Map<String, dynamic> item) {
    return FoodModel(
      id:            item['foodId'] ?? 0,
      name:          item['foodName'] ?? '',
      description:   item['description'] ?? '',
      price:         (item['price'] ?? 0.0).toDouble(),
      originalPrice: item['originalPrice'] != null ? (item['originalPrice'] as num).toDouble() : null,
      calories:      item['calories'] ?? 0,
      time:          item['cookingTime'] ?? '',
      imageUrl:      item['imageUrl'] ?? '',
      rating:        (item['rating'] ?? 0.0).toDouble(),
      categoryId:    item['categoryId'] ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("My Favorites ❤️",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.orange),
            onPressed: _fetchFavorites,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text("No favorites yet",
                          style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text("Tap ❤️ on any food to save it here",
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Browse Food", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchFavorites,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      final item = _favorites[index] as Map<String, dynamic>;
                      final food = _toFoodModel(item);
                      return _buildFavoriteCard(food, item);
                    },
                  ),
                ),
    );
  }

  Widget _buildFavoriteCard(FoodModel food, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () async {
        final added = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(food: food)),
        );
        if (added != null && widget.onAddToCart != null) {
          widget.onAddToCart!(added);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + Remove button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.asset(
                    food.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      height: 120,
                      color: const Color(0xFFF1E6D3),
                      child: const Icon(Icons.fastfood, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
                // Remove favorite button
                Positioned(
                  top: 8, right: 8,
                  child: GestureDetector(
                    onTap: () => _removeFavorite(food.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: const Icon(Icons.favorite, color: Colors.red, size: 18),
                    ),
                  ),
                ),
                // Promo badge
                if (food.originalPrice != null)
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                      child: const Text("PROMO", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  // Price
                  Row(
                    children: [
                      if (food.originalPrice != null) ...[
                        Text("\$${food.originalPrice!.toStringAsFixed(2)}",
                            style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 11)),
                        const SizedBox(width: 4),
                      ],
                      Text("\$${food.price.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: food.originalPrice != null ? Colors.red : Colors.orange,
                            fontWeight: FontWeight.bold, fontSize: 13,
                          )),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Calories & time
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.orange, size: 12),
                      const SizedBox(width: 2),
                      Text("${food.calories} Cal", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      const SizedBox(width: 8),
                      const Icon(Icons.access_time, color: Colors.orange, size: 12),
                      const SizedBox(width: 2),
                      Text(food.time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}