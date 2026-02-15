import 'package:flutter/foundation.dart';
import '../data/models/category_model.dart';
import '../data/models/food_model.dart';
import '../data/services/api_service.dart';

class HomeProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<CategoryModel> _categories = [];
  List<FoodModel> _popularFoods = [];
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  List<FoodModel> get popularFoods => _popularFoods;
  bool get isLoading => _isLoading;

  Future<void> loadHomeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Fetch Categories
      // Note: Make sure getCategories() exists in your ApiService!
      // If it's missing, I've included the code below to add to ApiService.
      final categoryData = await _apiService.getCategories();
      _categories = categoryData;

      // 2. Fetch Popular Foods
      final foodData = await _apiService.getPopularFoods();
      _popularFoods = foodData;

    } catch (e) {
      debugPrint("Error loading home data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}