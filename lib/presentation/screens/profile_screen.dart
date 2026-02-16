import 'dart:io';
import 'package:flutter/material.dart';
import 'edit_profile_screen.dart'; // Make sure this matches your file name!

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "Him Somealea";
  String member = "VIP";
  String phone = "+855 967710045";
  String email = "Loopy@gmail.com";
  File? profileImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE7DCC3),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 180,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE7DCC3),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(100),
                        bottomRight: Radius.circular(100),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        "Profile",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProfileScreen(
                              name: name,
                              member: member,
                              phone: phone,
                              email: email,
                              image: profileImage,
                            ),
                          ),
                        );

                        if (result != null) {
                          setState(() {
                            name = result['name'];
                            member = result['member'];
                            phone = result['phone'];
                            email = result['email'];
                            profileImage = result['image'];
                          });
                        }
                      },
                    ),
                  ),
                  Positioned(
                    bottom: -60,
                    left: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: profileImage != null
                            ? FileImage(profileImage!)
                            : null,
                        child: profileImage == null
                            ? const Icon(Icons.person, size: 60)
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 90),
              profileItem(Icons.person, "Name", name),
              profileItem(Icons.business, "Member", member),
              profileItem(Icons.phone, "Phone no.", phone),
              profileItem(Icons.email, "E-Mail", email),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget profileItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(value, style: const TextStyle(fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }
}