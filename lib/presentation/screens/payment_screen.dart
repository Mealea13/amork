import 'dart:convert';
import 'package:amork/presentation/screens/payment_success_screen.dart';
import 'package:amork/presentation/screens/qr_payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_config.dart';

class PaymentScreen extends StatefulWidget {
  final double total;
  final List<Map<String, dynamic>> cartItems;

  const PaymentScreen({super.key, required this.total, required this.cartItems});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selected = "QR";
  bool _isProcessing = false;

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController   = TextEditingController();
  final TextEditingController _notesController   = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleCheckout() async {
    final address = _addressController.text.trim();
    final phone   = _phoneController.text.trim();

    if (address.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter address and phone number'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // Build order items from cart
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
          'payment_method':   selected == 'QR' ? 'qr_code' : 'cash_on_delivery',
          'delivery_address': address,
          'phone':            phone,
          'notes':            _notesController.text.trim(),
          'items':            items,
        }),
      );

      debugPrint('Order response: ${orderResponse.statusCode} ${orderResponse.body}');

      if (orderResponse.statusCode == 200 || orderResponse.statusCode == 201) {
        // Clear cart after successful order
        await http.delete(
          Uri.parse('${AppConfig.cartEndpoint}/clear'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (mounted) {
          // Go to success screen, then back to home
          await Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PaymentSuccessScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Order failed: ${orderResponse.body}"), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      debugPrint("Checkout Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Something went wrong. Try again."), backgroundColor: Colors.red),
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
        title: const Text("Checkout", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _paymentCard(
              imagePath: "assets/images/Cash on delivery.png",
              title: "Cash on Delivery",
              isSelected: selected == "Cash",
              onTap: () => setState(() => selected = "Cash"),
            ),
            const SizedBox(height: 15),
            _paymentCard(
              imagePath: "assets/images/QR icon.png",
              title: "QR Payment",
              isSelected: selected == "QR",
              onTap: () => setState(() => selected = "QR"),
            ),

            const SizedBox(height: 25),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Delivery Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: "Enter Delivery Address",
                prefixIcon: const Icon(Icons.location_on, color: Colors.orange),
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Phone Number",
                prefixIcon: const Icon(Icons.phone, color: Colors.orange),
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: "Notes (Optional)",
                prefixIcon: const Icon(Icons.note, color: Colors.orange),
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),

            // Order summary
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Order Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 10),
                  ...widget.cartItems.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${item['quantity']}x ${item['food_name'] ?? ''}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        Text("\$${((item['price'] ?? 0.0) * (item['quantity'] ?? 1)).toStringAsFixed(2)}", style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  )),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Delivery Fee", style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const Text("\$1.00", style: TextStyle(fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("\$${(widget.total + 1.00).toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            GestureDetector(
              onTap: _isProcessing ? null : () async {
                if (selected == "QR") {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => QRPaymentScreen(
                      total: widget.total,
                      cartItems: widget.cartItems,
                      deliveryAddress: _addressController.text.trim(),
                      phone: _phoneController.text.trim(),
                      notes: _notesController.text.trim(),
                    )),
                  );
                } else {
                  await _handleCheckout();
                }
              },
              child: Container(
                height: 55,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9DCCB),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3))],
                ),
                alignment: Alignment.center,
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Color(0xFF5D4037))
                    : Text(
                        selected == "QR" ? "Show QR" : "Place Order Now",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF5D4037)),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text("Change Order", style: TextStyle(decoration: TextDecoration.underline, color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentCard({required String imagePath, required String title, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.orange : Colors.transparent, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 1)],
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Image.asset(imagePath, height: 50,
              errorBuilder: (c, e, s) => const Icon(Icons.payment, size: 50, color: Colors.grey)),
            const SizedBox(width: 20),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Spacer(),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.check_circle, color: Colors.orange, size: 28),
              ),
          ],
        ),
      ),
    );
  }
}