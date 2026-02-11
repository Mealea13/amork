class AppConfig {
  // UPDATE THIS WITH YOUR IP ADDRESS
  static const String baseUrl = "http://192.168.100.7:5000/api";
  static const String authEndpoint = "$baseUrl/auth";
  static const String foodsEndpoint = "$baseUrl/foods";
  static const String cartEndpoint = "$baseUrl/cart";
  static const String ordersEndpoint = "$baseUrl/orders";
  static const String categoriesEndpoint = "$baseUrl/categories";
  static const String favoritesEndpoint = "$baseUrl/favorites";
  static const String reviewsEndpoint = "$baseUrl/reviews";
  static const String profileEndpoint = "$baseUrl/profile";
}