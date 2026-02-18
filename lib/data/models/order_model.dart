class OrderModel {
  final int id;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
  return OrderModel(
    id: json['orderId'] ?? json['order_id'] ?? 0,
    totalAmount: (json['totalAmount'] ?? json['total'] ?? 0.0).toDouble(),
    status: json['status'] ?? 'pending',
    createdAt: DateTime.tryParse(json['createdAt'] ?? json['created_at'] ?? '') ?? DateTime.now(),
    items: (json['orderItems'] ?? json['items'] ?? [])
        .map<OrderItemModel>((i) => OrderItemModel.fromJson(i))
        .toList(),
  );
}
}

class OrderItemModel {
  final String foodName;
  final int quantity;
  final double price;

  OrderItemModel({required this.foodName, required this.quantity, required this.price});

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
  return OrderItemModel(
    foodName: json['foodName'] ?? json['food_name'] ?? '',
    quantity: json['quantity'] ?? 0,
    price: (json['price'] ?? 0.0).toDouble(),
  );
}
}