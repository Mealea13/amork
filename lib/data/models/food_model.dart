class FoodModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final int calories;
  final String time;
  final String imageUrl;
  final double rating;
  final int categoryId;

  FoodModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.calories,
    required this.time,
    required this.imageUrl,
    this.rating = 0.0,
    this.categoryId = 0,
  });
  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['food_name'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      calories: json['calories'] ?? 0,
      time: json['cooking_time'] ?? json['time'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      categoryId: json['category_id'] ?? json['categoryId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'food_name': name,
      'description': description,
      'price': price,
      'calories': calories,
      'cooking_time': time,
      'image_url': imageUrl,
      'rating': rating,
      'category_id': categoryId,
    };
  }
}