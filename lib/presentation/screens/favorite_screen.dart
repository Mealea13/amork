import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amork/core/app_config.dart';
import 'detail_screen.dart';
import 'package:amork/data/models/food_model.dart';
import 'package:amork/data/models/favorite_model.dart';
import 'package:amork/presentation/screens/skeleton_widget.dart';

class FavoriteScreen extends StatefulWidget {
  final Function(FoodModel)? onAddToCart;
  final Function(int)? onFavoriteCountChanged;

  const FavoriteScreen({
    super.key,
    this.onAddToCart,
    this.onFavoriteCountChanged,
  });

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<FavoriteModel> _favorites = [];
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
        final List<dynamic> data = jsonDecode(response.body);
        final favorites = data
            .map((e) => FavoriteModel.fromJson(e as Map<String, dynamic>))
            .toList();
        setState(() {
          _favorites = favorites;
          _isLoading = false;
        });
        widget.onFavoriteCountChanged?.call(favorites.length);
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
        await _fetchFavorites();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removed from favorites'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Remove favorite error: $e');
    }
  }

  FoodModel _toFoodModel(FavoriteModel item) {
    return FoodModel(
      id:            item.foodId,
      name:          item.foodName,
      description:   item.description,
      price:         item.price,
      originalPrice: item.originalPrice,
      calories:      item.calories,
      time:          item.cookingTime,
      imageUrl:      item.imageUrl,
      rating:        item.rating,
      categoryId:    item.categoryId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("My Favorites",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            if (_favorites.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_favorites.length}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.orange),
            onPressed: _fetchFavorites,
          ),
        ],
      ),
      body: _isLoading
      ? GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 14,
            mainAxisSpacing: 14, childAspectRatio: 0.78,
          ),
          itemCount: 6,
          itemBuilder: (_, __) => const FavoriteCardSkeleton(),
        )
          : _favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite_border,
                          size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text("No favorites yet",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text("Tap ❤️ on any food to save it here",
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                        child: const Text("Browse Food",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchFavorites,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:   2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing:  14,
                      childAspectRatio: 0.78, // ✅ controls card height ratio
                    ),
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      final item = _favorites[index];
                      final food = _toFoodModel(item);
                      return _buildFavoriteCard(food, item);
                    },
                  ),
                ),
    );
  }

  Widget _buildFavoriteCard(FoodModel food, FavoriteModel item) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(food: food)),
        );
        await _fetchFavorites();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: SizedBox(
                    height: 110, // ✅ fixed height
                    width: double.infinity,
                    child: Image.asset(
                      item.imageUrl,
                      fit: BoxFit.cover, // ✅ covers without overflow
                      errorBuilder: (c, e, s) => Container(
                        height: 110,
                        color: const Color(0xFFF1E6D3),
                        child: const Icon(Icons.fastfood,
                            size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                // Remove button
                Positioned(
                  top: 8, right: 8,
                  child: GestureDetector(
                    onTap: () => _removeFavorite(food.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4)
                        ],
                      ),
                      child: const Icon(Icons.favorite,
                          color: Colors.red, size: 18),
                    ),
                  ),
                ),
                // Promo badge
                if (item.originalPrice != null)
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text("PROMO",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),

            // ── Info ──
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (item.originalPrice != null) ...[
                        Text(
                          "\$${item.originalPrice!.toStringAsFixed(2)}",
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        "\$${food.price.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: item.originalPrice != null
                              ? Colors.red
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department,
                          color: Colors.orange, size: 12),
                      const SizedBox(width: 2),
                      Text("${food.calories} Cal",
                          style: const TextStyle(
                              fontSize: 10, color: Colors.grey)),
                      const SizedBox(width: 8),
                      const Icon(Icons.access_time,
                          color: Colors.orange, size: 12),
                      const SizedBox(width: 2),
                      Text(food.time,
                          style: const TextStyle(
                              fontSize: 10, color: Colors.grey)),
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