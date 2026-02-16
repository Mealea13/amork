import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Notifications", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          _buildNotificationCard(
            icon: Icons.local_shipping,
            color: Colors.green,
            title: "Order Delivered!",
            message: "Your order #AMK-0988 has been successfully delivered. Enjoy your meal!",
            time: "10 mins ago",
            isNew: true,
          ),
          _buildNotificationCard(
            icon: Icons.local_offer,
            color: Colors.red,
            title: "Happy Khmer New Year! 🎊",
            message: "Enjoy 50% OFF on all traditional foods today. Don't miss out!",
            time: "2 hours ago",
            isNew: true,
          ),
          _buildNotificationCard(
            icon: Icons.star,
            color: Colors.orange,
            title: "Rate your last meal",
            message: "How was your Special Beef Burger? Leave a review and earn points.",
            time: "1 day ago",
            isNew: false,
          ),
          _buildNotificationCard(
            icon: Icons.account_balance_wallet,
            color: Colors.blue,
            title: "Payment Successful",
            message: "We have received your payment of \$10.50 via ABA Pay.",
            time: "2 days ago",
            isNew: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    required String time,
    required bool isNew,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNew ? Colors.white : const Color(0xFFF1E6D3).withOpacity(0.5), // Slightly darker if read
        borderRadius: BorderRadius.circular(20),
        boxShadow: isNew ? [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))] : [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                    if (isNew)
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      )
                  ],
                ),
                const SizedBox(height: 5),
                Text(message, style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4)),
                const SizedBox(height: 8),
                Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}