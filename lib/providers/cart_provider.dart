import 'package:flutter/foundation.dart';
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

  // Load Cart
  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getCart();
      if (response['cartItems'] != null) {
        // Map the JSON list to our Dart Model list
        _items = (response['cartItems'] as List)
            .map((item) => CartItemModel.fromJson(item))
            .toList();
      } else {
        _items = [];
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add to Cart
  Future<void> addToCart(FoodModel food) async {
    try {
      await _apiService.addToCart(food.id, 1);
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