class FoodModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int calories;
  final String time; // e.g., "25 min"
  final String imageUrl;

  FoodModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.calories,
    required this.time,
    required this.imageUrl,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      calories: json['calories'],
      time: json['time'],
      imageUrl: json['imageUrl'],
    );
  }
}