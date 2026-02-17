import 'dart:convert';
import 'dart:typed_data'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http; // NEW: For API calls
import 'package:shared_preferences/shared_preferences.dart'; // NEW: To get User ID & Token

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String member;
  final String phone;
  final String email;
  final Uint8List? imageBytes; 

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.member,
    required this.phone,
    required this.email,
    this.imageBytes,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

// ... imports stay the same ...

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  Uint8List? _displayImage; 
  bool _imageChanged = false;
  final ImagePicker _picker = ImagePicker();

  // ✅ Match your .NET server IP
  final String serverUrl = "http://10.180.126.159:5000";

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    phoneController = TextEditingController(text: widget.phone);
    emailController = TextEditingController(text: widget.email);
    _displayImage = widget.imageBytes;
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes(); 
      setState(() {
        _displayImage = bytes; 
        _imageChanged = true;
      });
    }
  }

  Future<void> _saveProfile() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.orange)),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final String userId = prefs.getString('user_id') ?? "101abf10-82c3-4b4a-a2fd-0fd2f25591b0";

      // 1. Update Text
      final profileResp = await http.put(
        Uri.parse('$serverUrl/api/profile/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Fullname': nameController.text,
          'Phone': phoneController.text,
          'Email': emailController.text,
        }),
      );

      if (profileResp.statusCode != 200) throw Exception("Failed to update text");

      // 2. Upload Image if changed
      if (_displayImage != null && _imageChanged) {
        var request = http.MultipartRequest('POST', Uri.parse('$serverUrl/api/profile/upload-image/$userId'));
        request.files.add(http.MultipartFile.fromBytes('image', _displayImage!, filename: 'profile.png'));
        await request.send();
      }

      if (context.mounted) {
        Navigator.pop(context); // Close loading
        Navigator.pop(context, true); // Return 'true' to trigger refresh
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      debugPrint("Error saving: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0), 
      appBar: AppBar(title: const Text("Edit Profile"), centerTitle: true, backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 70,
                backgroundImage: _displayImage != null ? MemoryImage(_displayImage!) : null,
                child: _displayImage == null ? const Icon(Icons.person, size: 70) : null,
              ),
            ),
            const SizedBox(height: 30),
            _buildTextField("Name", nameController),
            const SizedBox(height: 20),
            _buildTextField("Phone", phoneController),
            const SizedBox(height: 20),
            _buildTextField("Email", emailController),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size(double.infinity, 50)),
              onPressed: _saveProfile,
              child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
    );
  }
}