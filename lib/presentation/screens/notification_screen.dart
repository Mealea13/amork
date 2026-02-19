import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amork/core/app_config.dart';
import 'order_screen.dart';
import 'package:amork/presentation/screens/skeleton_widget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _eventNotifications = [
    {
      "id":       "evt_1",
      "title":    "🎉 Khmer New Year Special!",
      "body":     "Get 50% off on all Khmer dishes this week.",
      "time":     "Today",
      "isRead":   false,
      "type":     "promo",
      "actionLabel": "View Deals",
    },
    {
      "id":       "evt_2",
      "title":    "🔥 Flash Sale - 2 Hours Only!",
      "body":     "All drinks 30% off. Use code AMORK30.",
      "time":     "2h ago",
      "isRead":   false,
      "type":     "promo",
      "actionLabel": "Shop Now",
    },
    {
      "id":       "evt_3",
      "title":    "⭐ New Menu Available!",
      "body":     "Try our new Sushi Platter and Grilled Steak.",
      "time":     "Yesterday",
      "isRead":   true,
      "type":     "new",
      "actionLabel": "See Menu",
    },
    {
      "id":       "evt_4",
      "title":    "💝 Weekend Special",
      "body":     "Free delivery on orders above \$15 this weekend.",
      "time":     "2 days ago",
      "isRead":   true,
      "type":     "promo",
      "actionLabel": "Order Now",
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/orders'),
        headers: {'Authorization': 'Bearer $token'},
      );

      List<Map<String, dynamic>> orderNotifications = [];

      if (response.statusCode == 200) {
        final List<dynamic> orders = jsonDecode(response.body);

        for (final order in orders) {
          final status   = order['status']      ?? 'confirmed';
          final orderNum = order['orderNumber'] ?? order['order_number'] ?? '';
          final total    = (order['total']      ?? 0.0).toDouble();
          final orderId  = order['orderId']     ?? order['order_id']     ?? '';
          final createdAt = order['createdAt']  ?? order['created_at']   ?? '';

          orderNotifications.add({
            "id":          "order_$orderId",
            "title":       "✅ Order Confirmed",
            "body":        "Order $orderNum (\$${total.toStringAsFixed(2)}) has been confirmed.",
            "time":        _formatTime(createdAt),
            "isRead":      false,
            "type":        "order",
            "orderId":     orderId,
            "orderNumber": orderNum,
            "actionLabel": "View Order",
          });

          if (status == 'delivered') {
            orderNotifications.add({
              "id":          "delivered_$orderId",
              "title":       "🚀 Order Delivered!",
              "body":        "Order $orderNum has been delivered. Enjoy your meal!",
              "time":        _formatTime(createdAt),
              "isRead":      false,
              "type":        "delivery",
              "orderId":     orderId,
              "orderNumber": orderNum,
              "actionLabel": "View Order",
            });
          }

          orderNotifications.add({
            "id":          "review_$orderId",
            "title":       "⭐ How was your order?",
            "body":        "Rate your experience for order $orderNum.",
            "time":        _formatTime(createdAt),
            "isRead":      true,
            "type":        "review",
            "orderId":     orderId,
            "orderNumber": orderNum,
            "actionLabel": "Rate Now",
          });
        }
      }

      setState(() {
        _notifications = [...orderNotifications, ..._eventNotifications];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Fetch notifications error: $e');
      setState(() {
        _notifications = _eventNotifications;
        _isLoading = false;
      });
    }
  }

  String _formatTime(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1)  return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24)   return '${diff.inHours}h ago';
      if (diff.inDays == 1)    return 'Yesterday';
      return '${diff.inDays} days ago';
    } catch (_) {
      return '';
    }
  }

  int get _unreadCount =>
      _notifications.where((n) => n['isRead'] == false).length;

  void _markAllRead() {
    setState(() {
      for (var n in _notifications) {
        n['isRead'] = true;
      }
    });
  }

  // ── Handle tap — navigate based on type ──
  void _handleTap(Map<String, dynamic> n) {
    setState(() => n['isRead'] = true);

    final type    = n['type']    ?? '';
    final orderId = n['orderId'] ?? '';

    switch (type) {
      case 'order':
      case 'delivery':
      case 'review':
        // Navigate to Order screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OrderScreen()),
        );
        break;

      case 'promo':
      case 'new':
        // Show event detail bottom sheet
        _showEventDetail(n);
        break;

      default:
        break;
    }
  }

  void _showEventDetail(Map<String, dynamic> n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _getIcon(n['type']),
            const SizedBox(height: 16),
            Text(
              n['title'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              n['body'],
              style: const TextStyle(color: Colors.grey, fontSize: 15, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              n['time'],
              style: const TextStyle(color: Colors.orange, fontSize: 13),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1E6D3),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  n['actionLabel'] ?? 'OK',
                  style: const TextStyle(
                      color: Colors.brown,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _getIcon(String type) {
    IconData icon;
    Color color;
    switch (type) {
      case 'order':    icon = Icons.receipt_long;   color = Colors.blue;   break;
      case 'delivery': icon = Icons.local_shipping;  color = Colors.green;  break;
      case 'promo':    icon = Icons.card_giftcard;   color = Colors.red;    break;
      case 'review':   icon = Icons.star;            color = Colors.orange; break;
      case 'new':      icon = Icons.new_releases;    color = Colors.purple; break;
      default:         icon = Icons.notifications;   color = Colors.grey;   break;
    }
    return CircleAvatar(
      radius: 24,
      backgroundColor: color.withOpacity(0.12),
      child: Icon(icon, color: color, size: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text("Notifications",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 10,
                backgroundColor: Colors.red,
                child: Text('$_unreadCount',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        centerTitle: false,
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text("Mark all read",
                  style: TextStyle(color: Colors.orange, fontSize: 13)),
            ),
        ],
      ),
      body: _isLoading
      ? ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: 5,
          itemBuilder: (_, __) => const NotificationItemSkeleton(),
        )
          : _notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("No notifications yet",
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final n      = _notifications[index];
                      final isRead = n['isRead'] == true;
                      return GestureDetector(
                        onTap: () => _handleTap(n),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 5),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isRead
                                ? Colors.white
                                : Colors.orange.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(16),
                            border: isRead
                                ? null
                                : Border.all(
                                    color: Colors.orange.withOpacity(0.3),
                                    width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _getIcon(n['type']),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            n['title'],
                                            style: TextStyle(
                                              fontWeight: isRead
                                                  ? FontWeight.normal
                                                  : FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Text(n['time'],
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      n['body'],
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 13),
                                    ),
                                    const SizedBox(height: 8),
                                    // ── Action label button ──
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1E6D3),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                n['actionLabel'] ?? 'View',
                                                style: const TextStyle(
                                                  color: Colors.brown,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Icon(
                                                Icons.arrow_forward_ios,
                                                size: 10,
                                                color: Colors.brown,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (!isRead)
                                Container(
                                  margin: const EdgeInsets.only(left: 8, top: 4),
                                  width: 8, height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}