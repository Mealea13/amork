import 'package:flutter/material.dart';
import 'payment_success_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_config.dart';

class QRPaymentScreen extends StatefulWidget {
  final double total;
  final List<Map<String, dynamic>> cartItems;
  final String deliveryAddress;
  final String phone;
  final String notes;

  const QRPaymentScreen({
    super.key,
    required this.total,
    required this.cartItems,
    required this.deliveryAddress,
    required this.phone,
    required this.notes,
  });

  @override
  State<QRPaymentScreen> createState() => _QRPaymentScreenState();
}

class _QRPaymentScreenState extends State<QRPaymentScreen> {
  bool _isProcessing = false;

  Future<void> _confirmPayment() async {
    setState(() => _isProcessing = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final items = widget.cartItems.map((item) => {
        'food_id':   item['food_id'],
        'food_name': item['food_name'] ?? '',
        'quantity':  item['quantity'],
        'price':     item['price'],
      }).toList();

      final orderResponse = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'total':            widget.total,
          'payment_method':   'qr_code',
          'delivery_address': widget.deliveryAddress,
          'phone':            widget.phone,
          'notes':            widget.notes,
          'items':            items,
        }),
      );

      debugPrint('QR Order: ${orderResponse.statusCode} ${orderResponse.body}');

      if (orderResponse.statusCode == 200 || orderResponse.statusCode == 201) {
        // Clear cart
        await http.delete(
          Uri.parse('${AppConfig.cartEndpoint}/clear'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (mounted) {
          await Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PaymentSuccessScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Order failed: ${orderResponse.body}'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      debugPrint('QR order error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F0E8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("QR Payment", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      "assets/images/mealea-qr.webp",
                      height: 350,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => const Column(
                        children: [
                          Icon(Icons.qr_code_scanner, size: 100, color: Colors.grey),
                          Text("QR Image Not Found", style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text("Scan to complete payment", style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Amount: \$${(widget.total + 1.00).toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE9DCCB),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: _isProcessing ? null : _confirmPayment,
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Color(0xFF5D4037))
                  : const Text("I Have Paid",
                      style: TextStyle(color: Color(0xFF5D4037), fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(decoration: TextDecoration.underline, color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}