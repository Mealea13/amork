import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/app_config.dart'; // Import your new config
import '../models/food_model.dart';

class ApiService {
  // Now you are using the keyword instead of the real IP string
  final String _url = AppConfig.baseUrl;

  Future<List<FoodModel>> getPopularFoods() async {
    try {
      final response = await http.get(Uri.parse('$_url/foods/popular'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => FoodModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load foods');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
}