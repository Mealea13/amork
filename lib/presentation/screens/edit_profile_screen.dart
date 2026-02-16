import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Needed to pick the image here too!

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String member;
  final String phone;
  final String email;
  final File? image; // Receive current image

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.member,
    required this.phone,
    required this.email,
    this.image,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controllers to edit text
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  
  // Variable to hold the potentially new image
  File? _displayImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    nameController = TextEditingController(text: widget.name);
    phoneController = TextEditingController(text: widget.phone);
    emailController = TextEditingController(text: widget.email);
    
    // Initialize display image with the current image
    _displayImage = widget.image;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // Function to pick image in edit screen
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _displayImage = File(pickedFile.path); // Update the image being shown right now
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // FIX 1: Force the beige background color explicitly
      backgroundColor: const Color(0xFFF9F6F0), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Ensure back arrow is black so it's visible on beige
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Edit Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // FIX 2: Clickable Image Picker UI
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: const Color(0xFFE7DCC3),
                    // Show the new image if picked, otherwise show the old one, otherwise null
                    backgroundImage: _displayImage != null ? FileImage(_displayImage!) : null,
                    child: _displayImage == null
                        ? const Icon(Icons.person, size: 70, color: Colors.white)
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Edit Text Fields (Using dark text color for visibility)
            _buildTextField("Name", nameController),
            const SizedBox(height: 20),
            // Member field is usually read-only, so we just show it
             Container(
               width: double.infinity,
               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
               decoration: BoxDecoration(
                 color: Colors.black.withOpacity(0.05), // Slightly darker background for read-only
                 borderRadius: BorderRadius.circular(15),
                 border: Border.all(color: Colors.black12)
               ),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Member Type (Read-only)", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 5),
                    Text(widget.member, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
               ),
             ),
            const SizedBox(height: 20),
            _buildTextField("Phone", phoneController),
            const SizedBox(height: 20),
            _buildTextField("Email", emailController),

            const SizedBox(height: 50),

            // Save Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                // FIX 3: Pass the updated data (including the new image) back to the previous screen
                Navigator.pop(context, {
                  'name': nameController.text,
                  'member': widget.member,
                  'phone': phoneController.text,
                  'email': emailController.text,
                  'image': _displayImage, // Pass the new file back
                });
              },
              child: const Text("Save Changes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
             const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.black), // Ensure input text is black
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
               borderRadius: BorderRadius.circular(15),
               borderSide: const BorderSide(color: Colors.black12),
            ),
            focusedBorder: OutlineInputBorder(
               borderRadius: BorderRadius.circular(15),
               borderSide: const BorderSide(color: Colors.orange),
            )
          ),
        ),
      ],
    );
  }
}