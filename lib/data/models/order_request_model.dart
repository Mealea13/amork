class OrderRequestModel {
  int? id;
  String? productName;
  double? price;
  int? quantity;

  OrderRequestModel({this.id, this.productName, this.price, this.quantity});
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
    };
  }
}