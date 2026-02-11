import 'package:flutter/foundation.dart';
import '../data/models/cart_model.dart';
import '../data/models/food_model.dart';
import '../data/services/api_service.dart';

class CartProvider with ChangeNotifier {
  List<CartItemModel> _items = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;
  int get itemCount => _items.length;

  double get total => _items.fold(0, (sum, item) => sum + (item.food.price * item.quantity));

  Future<void> loadCart(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getCart(userId);
      if (response != null && response['cartItems'] != null) {
        _items = (response['cartItems'] as List)
            .map((item) => CartItemModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(String userId, FoodModel food) async {
    final cartItem = CartItemModel(
      cartItemId: DateTime.now().millisecondsSinceEpoch.toString(),
      food: food,
      quantity: 1,
    );

    try {
      await _apiService.addToCart(cartItem);
      await loadCart(userId);
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      rethrow;
    }
  }
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    try {
      await _apiService.updateCartQuantity(cartItemId, quantity);
      final index = _items.indexWhere((item) => item.cartItemId == cartItemId);
      if (index != -1) {
        _items[index].quantity = quantity;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating quantity: $e');
      rethrow;
    }
  }

  Future<void> removeItem(String userId, String cartItemId) async {
    try {
      await _apiService.removeFromCart(cartItemId);
      await loadCart(userId);
    } catch (e) {
      debugPrint('Error removing item: $e');
      rethrow;
    }
  }

  Future<void> clearCart(String userId) async {
    try {
      await _apiService.clearCart(userId);
      _items = [];
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
      rethrow;
    }
  }
}