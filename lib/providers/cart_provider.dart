import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_config.dart';
import '../data/models/cart_item_model.dart';
import '../data/models/food_model.dart';
import '../data/services/api_service.dart';

class CartProvider with ChangeNotifier {
  List<CartItemModel> _items = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;

  double get total {
    return _items.fold(0.0, (sum, item) {
      return sum + (item.food.price * item.quantity);
    });
  }

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/foods/cart'), 
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        _items = data.map((json) => CartItemModel.fromJson(json)).toList();
      } else {
        _items = [];
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    } finally {
      // ✅ This line STOPS the loading spinner even if there is an error
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Now this works because we updated ApiService!
  Future<void> addToCart(FoodModel food, {int quantity = 1, String? notes}) async {
    try {
      await _apiService.addToCart(food.id, quantity, notes: notes);
      await loadCart(); 
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      rethrow;
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    try {
      await _apiService.updateCartQuantity(cartItemId, quantity);
      await loadCart();
    } catch (e) {
      debugPrint('Error updating quantity: $e');
      rethrow;
    }
  }

  Future<void> removeItem(String cartItemId) async {
    try {
      await _apiService.removeFromCart(cartItemId);
      await loadCart();
    } catch (e) {
      debugPrint('Error removing item: $e');
      rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      await _apiService.clearCart();
      _items = [];
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
      rethrow;
    }
  }
}