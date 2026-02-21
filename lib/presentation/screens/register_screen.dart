import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickalert/quickalert.dart';
import 'package:amork/data/services/api_service.dart';
import 'package:amork/data/models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      QuickAlert.show(context: context, type: QuickAlertType.warning, title: 'Missing Input', text: 'Please enter your email');
      return false;
    }
    if (!email.contains('@') || !email.contains('.')) {
      QuickAlert.show(context: context, type: QuickAlertType.error, title: 'Invalid Email', text: 'Please enter a valid email address');
      return false;
    }
    if (name.isEmpty) {
      QuickAlert.show(context: context, type: QuickAlertType.warning, title: 'Missing Input', text: 'Please enter your name');
      return false;
    }
    if (name.length < 2) {
      QuickAlert.show(context: context, type: QuickAlertType.error, title: 'Invalid Name', text: 'Name must be at least 2 characters');
      return false;
    }
    if (password.isEmpty) {
      QuickAlert.show(context: context, type: QuickAlertType.warning, title: 'Missing Input', text: 'Please create a password');
      return false;
    }
    if (password.length < 6) {
      QuickAlert.show(context: context, type: QuickAlertType.error, title: 'Weak Password', text: 'Password must be at least 6 characters');
      return false;
    }
    if (!_agreeToTerms) {
      QuickAlert.show(context: context, type: QuickAlertType.info, title: 'Terms & Conditions', text: 'Please agree to the Terms and Conditions');
      return false;
    }
    return true;
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final newUser = UserModel(
        id: '',
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: '',
      );
      await apiService.register(newUser, _passwordController.text);

      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Success',
          text: 'Account created successfully!',
          autoCloseDuration: const Duration(seconds: 2),
          showConfirmBtn: false,
        );
        
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context); // Take them back to Login screen
      }
    } catch (e) {
      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Registration Failed',
          text: 'Something went wrong. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleGoogleRegister() {
    QuickAlert.show(context: context, type: QuickAlertType.info, title: 'Coming Soon', text: 'Google Sign-In is not available yet!');
  }

  void _navigateToLogin() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Getting Started',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create an account to continue',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF888888),
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Your Email',
                      hintStyle: GoogleFonts.poppins(color: const Color(0xFF888888)),
                      filled: true,
                      fillColor: const Color(0xFFF2F2F2),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'Your Name',
                      hintStyle: GoogleFonts.poppins(color: const Color(0xFF888888)),
                      filled: true,
                      fillColor: const Color(0xFFF2F2F2),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Create Password',
                      hintStyle: GoogleFonts.poppins(color: const Color(0xFF888888)),
                      filled: true,
                      fillColor: const Color(0xFFF2F2F2),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF888888)),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) => Container(width: 20, height: 2, margin: const EdgeInsets.symmetric(horizontal: 4), color: Colors.grey[300])),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) {
                          setState(() => _agreeToTerms = value ?? false);
                        },
                        activeColor: Colors.teal,
                      ),
                      Expanded(
                        child: Text('By Creating an account, you agree to our Term and conditions', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF888888))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3D6),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoading ? null : _handleRegister,
                        borderRadius: BorderRadius.circular(30),
                        child: Center(
                          child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Color(0xFF1A1A1A), strokeWidth: 2)
                              )
                            : Text(
                                'Register',
                                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A)),
                              ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text('OR', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF888888))),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(30), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _handleGoogleRegister,
                        borderRadius: BorderRadius.circular(30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/google_icon.webp', width: 24, height: 24, errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, size: 24)),
                            const SizedBox(width: 10),
                            Text('Continue to Google', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A))),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF888888))),
                      GestureDetector(
                        onTap: _navigateToLogin,
                        child: Text('Sign in', style: GoogleFonts.poppins(fontSize: 13, color: Colors.blue, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}