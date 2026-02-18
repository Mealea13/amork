import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amork/core/app_config.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Map<String, dynamic>? orderData;
  Map<String, dynamic>? trackingData;
  bool isLoading = true;
  bool isTracking = false;
  bool showTracking = false;

  // Ordered list of all possible statuses for the tracker
  final List<String> _trackingSteps = ['pending', 'confirmed', 'preparing', 'ready', 'delivering', 'delivered'];

  final Map<String, IconData> _stepIcons = {
    'pending':    Icons.receipt_outlined,
    'confirmed':  Icons.check_circle_outline,
    'preparing':  Icons.restaurant_outlined,
    'ready':      Icons.delivery_dining_outlined,
    'delivering': Icons.directions_bike_outlined,
    'delivered':  Icons.home_outlined,
  };

  @override
  void initState() {
    super.initState();
    _fetchOrderDetail();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _fetchOrderDetail() async {
    setState(() => isLoading = true);
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.ordersEndpoint}/${widget.orderId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          orderData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('Order detail error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchTracking() async {
    setState(() => isTracking = true);
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.ordersEndpoint}/${widget.orderId}/track'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          trackingData = jsonDecode(response.body);
          showTracking = true;
          isTracking = false;
        });
      } else {
        setState(() => isTracking = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tracking not available yet'), backgroundColor: Colors.orange),
          );
        }
      }
    } catch (e) {
      debugPrint('Tracking error: $e');
      setState(() => isTracking = false);
    }
  }

  Future<void> _cancelOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Cancel Order"),
        content: const Text("Are you sure you want to cancel this order?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("No")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('${AppConfig.ordersEndpoint}/${widget.orderId}/cancel'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({'reason': 'Cancelled by user'}),
      );

      if (response.statusCode == 200) {
        _fetchOrderDetail();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order cancelled'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      debugPrint('Cancel error: $e');
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':    return Colors.blue;
      case 'confirmed':  return Colors.indigo;
      case 'preparing':  return Colors.orange;
      case 'ready':      return Colors.teal;
      case 'delivering': return Colors.purple;
      case 'delivered':  return Colors.green;
      case 'cancelled':  return Colors.red;
      default:           return Colors.grey;
    }
  }

  int _currentStepIndex(String status) {
    final idx = _trackingSteps.indexOf(status.toLowerCase());
    return idx == -1 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF9F6F0),
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    if (orderData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F6F0),
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
            leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Navigator.pop(context))),
        body: const Center(child: Text("Order not found.")),
      );
    }

    final String status = orderData!['status'] ?? 'pending';
    final String orderNumber = orderData!['order_number'] ?? '#AMK-${widget.orderId}';
    final double orderTotal = (orderData!['total'] ?? 0.0).toDouble();
    final double deliveryFee = (orderData!['delivery_fee'] ?? 0.0).toDouble();
    final double tax = (orderData!['tax'] ?? 0.0).toDouble();
    final double subtotal = (orderData!['subtotal'] ?? (orderTotal - deliveryFee - tax)).toDouble();
    final String date = orderData!['created_at'] ?? orderData!['date'] ?? '';
    final String paymentMethod = orderData!['payment_method'] ?? 'N/A';
    final Map deliveryAddress = orderData!['delivery_address'] ?? {};
    final List items = orderData!['items'] ?? [];
    final Color statusColor = _statusColor(status);
    final bool canCancel = status == 'pending' || status == 'confirmed';
    final bool canTrack = status != 'cancelled' && status != 'delivered';

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Order Details", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          if (canCancel)
            TextButton(
              onPressed: _cancelOrder,
              child: const Text("Cancel", style: TextStyle(color: Colors.red, fontSize: 13)),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchOrderDetail,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Order Header ──
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(orderNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            status[0].toUpperCase() + status.substring(1),
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text("Placed on: $date", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text("Payment: ${paymentMethod.replaceAll('_', ' ').toUpperCase()}",
                        style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Live Tracking Section ──
              if (canTrack) ...[
                GestureDetector(
                  onTap: isTracking ? null : _fetchTracking,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.directions_bike, color: Colors.orange, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Track Order", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const Text("Tap to see live delivery status", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        isTracking
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange))
                            : const Icon(Icons.chevron_right, color: Colors.orange),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],

              // ── Tracking Progress Bar ──
              if (showTracking && trackingData != null) ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Live Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            trackingData!['estimated_time'] ?? trackingData!['eta'] ?? '',
                            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildTrackingTimeline(trackingData!['current_status'] ?? status),
                      if (trackingData!['note'] != null) ...[
                        const SizedBox(height: 12),
                        Text(trackingData!['note'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ── Delivery Address ──
              if (deliveryAddress.isNotEmpty) ...[
                const Text("Delivery Address", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.orange),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "${deliveryAddress['street'] ?? ''}, ${deliveryAddress['district'] ?? ''}, ${deliveryAddress['city'] ?? ''}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ── Items Ordered ──
              const Text("Items Ordered", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
                child: Column(
                  children: [
                    ...items.map((item) {
                      final double itemPrice = (item['price'] ?? 0.0).toDouble();
                      final int qty = item['quantity'] ?? 1;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${qty}x ${item['food_name'] ?? item['name'] ?? ''}",
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            Text("\$${(itemPrice * qty).toStringAsFixed(2)}",
                                style: const TextStyle(fontSize: 14, color: Colors.orange, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    }),
                    const Divider(color: Color(0xFFF4F0E8), thickness: 1.5),
                    const SizedBox(height: 8),
                    _receiptRow("Subtotal", "\$${subtotal.toStringAsFixed(2)}"),
                    _receiptRow("Delivery Fee", "\$${deliveryFee.toStringAsFixed(2)}"),
                    _receiptRow("Tax", "\$${tax.toStringAsFixed(2)}"),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("\$${orderTotal.toStringAsFixed(2)}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.orange)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackingTimeline(String currentStatus) {
    final currentIndex = _currentStepIndex(currentStatus);

    return Column(
      children: List.generate(_trackingSteps.length, (index) {
        final step = _trackingSteps[index];
        final isDone = index <= currentIndex;
        final isCurrent = index == currentIndex;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circle + line
            Column(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: isDone ? Colors.orange : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _stepIcons[step] ?? Icons.circle,
                    size: 16,
                    color: isDone ? Colors.white : Colors.grey,
                  ),
                ),
                if (index < _trackingSteps.length - 1)
                  Container(width: 2, height: 30, color: index < currentIndex ? Colors.orange : Colors.grey.shade200),
              ],
            ),
            const SizedBox(width: 14),
            // Label
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step[0].toUpperCase() + step.substring(1),
                    style: TextStyle(
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      fontSize: isCurrent ? 14 : 13,
                      color: isCurrent ? Colors.orange : (isDone ? Colors.black : Colors.grey),
                    ),
                  ),
                  if (isCurrent)
                    const Text("Current Status", style: TextStyle(color: Colors.orange, fontSize: 11)),
                  SizedBox(height: index < _trackingSteps.length - 1 ? 18 : 0),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}