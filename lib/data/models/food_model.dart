class FoodModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int calories;
  final String time;
  final String imageUrl;
  final double rating;    // Added to match C# decimal
  final int categoryId;   // Added to match C# int

  String get foodId => id;

  FoodModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.calories,
    required this.time,
    required this.imageUrl,
    this.rating = 0.0,    // Added
    this.categoryId = 0,  // Added
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'calories': calories,
      'time': time,
      'imageUrl': imageUrl,
      'rating': rating,      // Added
      'categoryId': categoryId, // Added
    };
  }

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: (json['id'] ?? json['foodId'] ?? '').toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      calories: json['calories'] ?? 0,
      time: json['time'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(), // Added
      categoryId: json['categoryId'] ?? 0,
    );
  }
}