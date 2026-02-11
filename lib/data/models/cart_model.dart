import 'food_model.dart';

class CartItemModel {
  final String cartItemId;
  final FoodModel food;
  int quantity;

  CartItemModel({
    required this.cartItemId,
    required this.food,
    this.quantity = 1,
  });

  double get totalPrice => food.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'cartItemId': cartItemId,
      'food': food.toJson(),
      'quantity': quantity,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      cartItemId: json['cartItemId'] ?? '',
      food: FoodModel.fromJson(json['food']),
      quantity: json['quantity'],
    );
  }
}