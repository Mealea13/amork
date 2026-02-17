import 'package:flutter/material.dart';
import 'order_detail_screen.dart'; // NEW: Import the detail screen!

// A simple model to hold our order data
class OrderModel {
  final String orderNumber;
  final String date;
  final String items;
  final double total;
  final String status;

  OrderModel({
    required this.orderNumber,
    required this.date,
    required this.items,
    required this.total,
    required this.status,
  });
}

class OrderScreen extends StatelessWidget {
  final List<OrderModel> orders;

  const OrderScreen({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "My Orders",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // If there are no orders, show a friendly empty state
            if (orders.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    "You haven't ordered anything yet!\nGo to the Home tab to add food.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      // NEW: Wrap the card in a GestureDetector
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
                          );
                        },
                        child: _orderCard(
                          orderNumber: order.orderNumber,
                          date: order.date,
                          items: order.items,
                          total: "\$${order.total.toStringAsFixed(2)}",
                          status: order.status,
                          statusColor: order.status == "Delivering" ? Colors.orange : Colors.green,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _orderCard({
    required String orderNumber,
    required String date,
    required String items,
    required String total,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(orderNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFFF4F0E8), thickness: 1.5),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(items, style: const TextStyle(fontSize: 13, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 10),
              Text(total, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)),
            ],
          )
        ],
      ),
    );
  }
}