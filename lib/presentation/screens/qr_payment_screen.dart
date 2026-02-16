import 'package:flutter/material.dart';
import 'package:amork/presentation/screens/payment_success_screen.dart';

class QRPaymentScreen extends StatelessWidget {
  final double total;

  const QRPaymentScreen({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F0E8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("QR Payment", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// QR Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE9DCCB),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  "assets/images/aba_qr.png",
                  height: 280,
                  width: 280,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 30),

            Text(
              "Total: \$${total.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const Spacer(),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE9DCCB),
                minimumSize: const Size(double.infinity, 55),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PaymentSuccessScreen(),
                  ),
                );
              },
              child: const Text(
                "I Have Paid",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),

            const SizedBox(height: 15),

            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Back to Payment",
                style: TextStyle(decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}