import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/app_config.dart';
import '../models/food_model.dart';
import '../models/cart_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import 'package:amork/data/models/order_request_model.dart';

class ApiService {
  // Authentication
  Future<Map<String, dynamic>> register(UserModel user) async {
    final response = await http.post(
      Uri.parse('${AppConfig.authEndpoint}/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user.toJson()),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Registration failed');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConfig.authEndpoint}/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Login failed');
    }
  }

  // Foods
  Future<List<FoodModel>> getPopularFoods() async {
    final response = await http.get(
      Uri.parse('${AppConfig.foodsEndpoint}/popular'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => FoodModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load foods');
    }
  }

  Future<List<FoodModel>> getFoodsByCategory(int categoryId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.categoriesEndpoint}/$categoryId/foods'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => FoodModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load foods');
    }
  }

  // Cart Operations
  Future<Map<String, dynamic>> getCart(String userId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.cartEndpoint}/$userId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load cart');
    }
  }

  Future<void> addToCart(CartItemModel item) async {
    final response = await http.post(
      Uri.parse('${AppConfig.cartEndpoint}/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(item.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add to cart');
    }
  }

  Future<void> updateCartQuantity(String cartItemId, int quantity) async {
    final response = await http.put(
      Uri.parse('${AppConfig.cartEndpoint}/update/$cartItemId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'quantity': quantity}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update quantity');
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    final response = await http.delete(
      Uri.parse('${AppConfig.cartEndpoint}/remove/$cartItemId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove item');
    }
  }

  Future<void> clearCart(String userId) async {
    final response = await http.delete(
      Uri.parse('${AppConfig.cartEndpoint}/clear/$userId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to clear cart');
    }
  }

  Future<Map<String, dynamic>> placeOrder(OrderRequestModel order) async {
    final response = await http.post(
      Uri.parse('${AppConfig.ordersEndpoint}/place'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(order.toJson()),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to place order');
    }
  }

  Future<List<OrderModel>> getUserOrders(String userId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.ordersEndpoint}/user/$userId'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => OrderModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.ordersEndpoint}/$orderId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load order details');
    }
  }

  // Profile
  Future<UserModel> getUserProfile(String userId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.profileEndpoint}/$userId'),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${AppConfig.profileEndpoint}/update/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile');
    }
  }
}