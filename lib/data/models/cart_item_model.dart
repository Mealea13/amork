import 'food_model.dart';

class CartItemModel {
  final String id;
  final FoodModel food;
  int quantity;
  final String? specialInstructions;
  CartItemModel({
    required this.id,
    required this.food,
    required this.quantity,
    this.specialInstructions,
  });
  double get totalPrice => food.price * quantity;
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id']?.toString() ?? '',
      food: FoodModel.fromJson(json['food'] ?? {}),
      quantity: json['quantity'] ?? 1,
      specialInstructions: json['special_instructions'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'food_id': food.id,
      'quantity': quantity,
      'special_instructions': specialInstructions,
    };
  }
}