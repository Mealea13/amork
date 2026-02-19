class FavoriteModel {
  final String favoriteId;
  final int foodId;
  final String foodName;
  final String description;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final int calories;
  final String cookingTime;
  final double rating;
  final int categoryId;
  final DateTime createdAt;

  FavoriteModel({
    required this.favoriteId,
    required this.foodId,
    required this.foodName,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    required this.calories,
    required this.cookingTime,
    required this.rating,
    required this.categoryId,
    required this.createdAt,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      favoriteId:    json['favoriteId']    ?? json['favorite_id']   ?? '',
      foodId:        json['foodId']        ?? json['food_id']        ?? 0,
      foodName:      json['foodName']      ?? json['food_name']      ?? json['name'] ?? '',
      description:   json['description']   ?? '',
      price:         (json['price']        ?? 0.0).toDouble(),
      originalPrice: json['originalPrice'] != null
          ? (json['originalPrice'] as num).toDouble()
          : json['original_price'] != null
              ? (json['original_price'] as num).toDouble()
              : null,
      imageUrl:      json['imageUrl']      ?? json['image_url']      ?? '',
      calories:      json['calories']      ?? 0,
      cookingTime:   json['cookingTime']   ?? json['cooking_time']   ?? json['time'] ?? '',
      rating:        (json['rating']       ?? 0.0).toDouble(),
      categoryId:    json['categoryId']    ?? json['category_id']    ?? 0,
      createdAt:     DateTime.tryParse(json['createdAt'] ?? json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}