import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amork/data/models/user_model.dart';
import '../data/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  final ApiService _apiService = ApiService();

  // Check if user is logged in on app start
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId != null) {
      try {
        _currentUser = await _apiService.getUserProfile(userId);
        notifyListeners();
      } catch (e) {
        // If failed to load profile, clear saved data
        await logout();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      // Save user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', response['user']['userId']);
      _currentUser = UserModel(
        id: response['user']['userId'],
        email: email,
        name: response['user']['fullname'],
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(UserModel user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.register(user);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _currentUser = null;
    notifyListeners();
  }
}