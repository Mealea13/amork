import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_config.dart';
import '../models/category_model.dart';
import '../models/food_model.dart';
import '../models/user_model.dart';

class ApiService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  Future<Map<String, dynamic>> register(UserModel user, String password) async {
    final response = await http.post(
      Uri.parse('${AppConfig.authEndpoint}/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'fullname': user.name,
        'email': user.email,
        'password': password,
        'phone': user.phone,
        'member_type': 'new guest',
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      await _saveAuthData(data);
      return data;
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConfig.authEndpoint}/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      await _saveAuthData(data);
      return data;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<void> _saveAuthData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    final token = data['token'] ?? data['access_token'] ?? data['accessToken'] ?? '';
    if (token.toString().isNotEmpty) {
      await prefs.setString('auth_token', token.toString());
    }

    final user = data['user'] ?? data['User'] ?? data;
    final userId = user['id'] ?? user['userId'] ?? user['user_id'] ?? '';
    if (userId.toString().isNotEmpty) {
      await prefs.setString('user_id', userId.toString());
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
  }
  Future<UserModel> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('${AppConfig.profileEndpoint}/$userId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }
  Future<List<CategoryModel>> getCategories() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(AppConfig.categoriesEndpoint),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }
  Future<List<FoodModel>> getPopularFoods() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${AppConfig.foodsEndpoint}/popular'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => FoodModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load popular foods');
    }
  }
  Future<Map<String, dynamic>> getCart() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(AppConfig.cartEndpoint),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data is List ? {'cartItems': data} : data;
    } else {
      throw Exception('Failed to load cart');
    }
  }

  Future<void> addToCart(int foodId, int quantity, {String? notes}) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${AppConfig.cartEndpoint}/add'),
      headers: headers,
      body: json.encode({
        'food_id': foodId,
        'quantity': quantity,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed: ${response.statusCode}');
    }
  }

  Future<void> updateCartQuantity(String cartItemId, int quantity) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('${AppConfig.cartEndpoint}/$cartItemId'),
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
      Uri.parse('${AppConfig.cartEndpoint}/$cartItemId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove item');
    }
  }

  Future<void> clearCart() async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('${AppConfig.cartEndpoint}/clear'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to clear cart');
    }
  }
  Future<List<dynamic>> getOrders({String status = 'all'}) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${AppConfig.ordersEndpoint}?status=$status'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data is List ? data : (data['orders'] ?? []);
    } else {
      throw Exception('Failed to load orders');
    }
  }
}