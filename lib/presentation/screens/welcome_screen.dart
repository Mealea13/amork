import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void onLoginPressed(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section - Hero Image
            Container(
              height: MediaQuery.of(context).size.height * 0.55,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF8E7),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/welcome_screen_amok.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            
            // Middle Section - Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Welcome to\n',
                          style: TextStyle(color: Color(0xFF1A1A1A)),
                        ),
                        TextSpan(
                          text: 'Amork Food Order',
                          style: TextStyle(color: Color(0xFFA94442)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Subtitle
                  Text(
                    'A healthy life doesn\'t start with drastic changes—it begins with small, mindful bites that slowly transform how you feel, think, and live.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF888888),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            // Bottom Section - Action Button
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, bottom: 40),
              child: Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3D6),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onLoginPressed(context),
                    borderRadius: BorderRadius.circular(30),
                    child: Center(
                      child: Text(
                        'Log In',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
