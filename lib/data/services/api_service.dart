import 'dart:convert';
import 'package:amork/data/models/category_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_config.dart';
import '../models/food_model.dart';
import '../models/cart_item_model.dart'; // Ensure you have this or CartModel
import '../models/user_model.dart';

class ApiService {
  // Helper to get Headers with Token
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- Authentication ---

  Future<Map<String, dynamic>> register(UserModel user, String password) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'fullname': user.name,
        'email': user.email,
        'password': password,
        'phone': user.phone,
        'member_type': 'regular',
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Login failed');
    }
  }

  Future<UserModel> getUserProfile(String userId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/profile'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserModel.fromJson(data);
    } else {
      throw Exception('Failed to load profile');
    }
  }
  Future<List<CategoryModel>> getCategories() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/categories'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }


  // --- Foods ---

  Future<List<FoodModel>> getPopularFoods() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/foods/popular?limit=10'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => FoodModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load popular foods');
    }
  }

  // --- Cart Operations (Updated to match your API) ---

  // Note: API uses Token to identify user, so we don't need userId in params
  Future<Map<String, dynamic>> getCart() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/cart'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load cart');
    }
  }

  Future<void> addToCart(int foodId, int quantity) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/cart/add'),
      headers: headers,
      // API expects food_id and quantity, NOT a full object
      body: json.encode({
        'food_id': foodId,
        'quantity': quantity,
        // Add 'additional_ingredients' here if needed later
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add to cart');
    }
  }

  Future<void> updateCartQuantity(String cartItemId, int quantity) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('${AppConfig.baseUrl}/api/cart/$cartItemId'),
      headers: headers,
      body: json.encode({'quantity': quantity}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update quantity');
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('${AppConfig.baseUrl}/api/cart/$cartItemId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove item');
    }
  }

  Future<void> clearCart() async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('${AppConfig.baseUrl}/api/cart/clear'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to clear cart');
    }
  }
}