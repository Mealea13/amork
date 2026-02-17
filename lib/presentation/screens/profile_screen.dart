import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Use your real WiFi IP address here
  final String serverUrl = "http://10.180.126.159:5000";
  
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final String userId = prefs.getString('user_id') ?? "101abf10-82c3-4b4a-a2fd-0fd2f25591b0";

      // ✅ FIX: Added userId to the URL to avoid 404
      final response = await http.get(Uri.parse('$serverUrl/api/profile/$userId'));

      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String? imagePath = userData?['profile_image'];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // Header Stack
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(height: 180, color: const Color(0xFFE7DCC3)),
                  Positioned(
                    bottom: -50,
                    child: CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade300,
                        // ✅ Load directly from Network
                        backgroundImage: imagePath != null
                            ? NetworkImage("$serverUrl$imagePath")
                            : null,
                        child: imagePath == null ? const Icon(Icons.person, size: 50) : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              Text(userData?['fullname'] ?? "User", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  final updated = await Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen(
                    name: userData?['fullname'] ?? "",
                    phone: userData?['phone'] ?? "",
                    email: userData?['email'] ?? "",
                  )));
                  if (updated == true) _fetchProfile(); // Refresh after save
                },
                child: const Text("Edit Profile"),
              ),
              const SizedBox(height: 40),
            ],
          ),
    );
  }
}