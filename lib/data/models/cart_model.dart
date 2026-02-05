import 'food_model.dart';

class CartItemModel {
  final FoodModel food;
  int quantity;

  CartItemModel({
    required this.food,
    this.quantity = 1,
  });

  double get totalPrice => food.price * quantity;

  // Useful for the "2 items in cart" logic in your Figma
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      food: FoodModel.fromJson(json['food']),
      quantity: json['quantity'],
    );
  }
}