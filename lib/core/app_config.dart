//lib/core/app_config.dart

class AppConfig {
  static const String baseUrl = 'http://localhost:5000';

  // All endpoints are built from baseUrl automatically
  static const String authEndpoint       = "$baseUrl/api/auth";
  static const String foodsEndpoint      = "$baseUrl/api/foods";
  static const String cartEndpoint       = '${baseUrl}/api/cart';
  static const String ordersEndpoint     = "$baseUrl/api/orders";
  static const String categoriesEndpoint = "$baseUrl/api/categories";
  static const String favoritesEndpoint  = "$baseUrl/api/favorites";
  static const String reviewsEndpoint    = "$baseUrl/api/reviews";
  static const String profileEndpoint    = "$baseUrl/api/profile";
  static const String paymentEndpoint    = "$baseUrl/api/payment";
  static const String notificationsEndpoint = "$baseUrl/api/notifications";
  static const String promotionsEndpoint = "$baseUrl/api/promotions";
  static const String analyticsEndpoint  = "$baseUrl/api/analytics";
  static const String supportEndpoint    = "$baseUrl/api/support";
}