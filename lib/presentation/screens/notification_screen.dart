import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Example data that mimics a real API response
  final List<Map<String, dynamic>> _notifications = [
    {"id": 1, "title": "Order Delivered!", "body": "Your order #102 has arrived.", "time": "Just now", "isRead": false, "type": "delivery"},
    {"id": 2, "title": "Promo!", "body": "Get 20% off with code AMORK20.", "time": "2h ago", "isRead": false, "type": "promo"},
    {"id": 3, "title": "Review", "body": "How was your Fish Amork?", "time": "Yesterday", "isRead": true, "type": "star"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          TextButton(onPressed: () => setState(() {
            for (var n in _notifications) { n['isRead'] = true; }
          }), child: const Text("Clear all", style: TextStyle(color: Colors.orange)))
        ],
      ),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final n = _notifications[index];
          return Container(
            color: n['isRead'] ? Colors.transparent : Colors.orange.withOpacity(0.05),
            child: ListTile(
              leading: _getIcon(n['type']),
              title: Text(n['title'], style: TextStyle(fontWeight: n['isRead'] ? FontWeight.normal : FontWeight.bold)),
              subtitle: Text(n['body']),
              trailing: Text(n['time'], style: const TextStyle(fontSize: 10)),
              onTap: () => setState(() => n['isRead'] = true),
            ),
          );
        },
      ),
    );
  }

  Widget _getIcon(String type) {
    IconData icon;
    Color color;
    if (type == "delivery") { icon = Icons.local_shipping; color = Colors.green; }
    else if (type == "promo") { icon = Icons.card_giftcard; color = Colors.red; }
    else { icon = Icons.star; color = Colors.orange; }
    return CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 20));
  }
}