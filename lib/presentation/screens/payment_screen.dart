import 'package:flutter/material.dart';
import 'qr_payment_screen.dart';
import 'payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double total;

  const PaymentScreen({super.key, required this.total});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selected = "QR";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F0E8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Payment", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      bottomNavigationBar: _bottomNav(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// Cash Option
            _paymentCard(
              icon: Icons.attach_money,
              title: "Cash on delivery",
              isSelected: selected == "Cash",
              onTap: () {
                setState(() => selected = "Cash");
              },
            ),
            const SizedBox(height: 25),

            /// QR Option
            _paymentCard(
              icon: Icons.qr_code_2,
              title: "QR Payment",
              isSelected: selected == "QR",
              onTap: () {
                setState(() => selected = "QR");
              },
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  "\$${widget.total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),

            GestureDetector(
              onTap: () {
                if (selected == "QR") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QRPaymentScreen(total: widget.total),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PaymentSuccessScreen(),
                    ),
                  );
                }
              },
              child: Container(
                height: 55,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9DCCB),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  selected == "QR" ? "Generate QR" : "Pay with Cash",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Back to order",
                style: TextStyle(decoration: TextDecoration.underline),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _paymentCard({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFFE9DCCB),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.transparent,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Center(child: Icon(icon, size: 50)),
            if (isSelected)
              Positioned(
                right: 10,
                top: 10,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.check, size: 16, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNav() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFFE9DCCB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.home),
          Icon(Icons.bookmark_border),
          Icon(Icons.shopping_cart),
          Icon(Icons.person_outline),
        ],
      ),
    );
  }
}