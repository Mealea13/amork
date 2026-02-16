import 'package:flutter/material.dart';
import 'main_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F0E8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 180,
              width: 180,
              decoration: const BoxDecoration(
                color: Color(0xFFE9DCCB),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 120, color: Colors.green),
            ),
            const SizedBox(height: 30),
            const Text(
              "Your Order is Successful!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Thank You so much for Order."),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                // Navigate back to Main Screen and clear history stack
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainScreen()),
                  (route) => false,
                );
              },
              child: const Text(
                "Back to Menu",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}