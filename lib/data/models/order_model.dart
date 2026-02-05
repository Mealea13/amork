import 'cart_model.dart';

class OrderModel {
  final String orderId;
  final List<CartItemModel> items;
  final double totalAmount;
  final String paymentMethod; // "Cash" or "QR"
  final DateTime orderDate;

  OrderModel({
    required this.orderId,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.orderDate,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['orderId'],
      items: (json['items'] as List)
          .map((item) => CartItemModel.fromJson(item))
          .toList(),
      totalAmount: json['totalAmount'].toDouble(),
      paymentMethod: json['paymentMethod'],
      orderDate: DateTime.parse(json['orderDate']),
    );
  }
}