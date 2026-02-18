import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:amork/core/app_config.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
      final String? userId = prefs.getString('user_id');
      final String? token = prefs.getString('auth_token'); // ✅ get token

      if (userId == null) {
        setState(() => isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse('${AppConfig.profileEndpoint}/$userId'),
        headers: {'Authorization': 'Bearer $token'}, // ✅ send token
      );

      debugPrint('Profile fetch: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Color _getMemberColor(String? member) {
    switch (member?.toLowerCase()) {
      case 'vip':       return Colors.purple;
      case 'premium':   return Colors.blue;
      case 'regular':   return Colors.orange;
      default:          return Colors.grey;
    }
  }

  IconData _getMemberIcon(String? member) {
    switch (member?.toLowerCase()) {
      case 'vip':     return Icons.workspace_premium;
      case 'premium': return Icons.star;
      case 'regular': return Icons.shopping_bag;
      default:        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? imagePath = userData?['profile_image'];
    final String memberType = userData?['member_type'] ?? userData?['member'] ?? 'Regular';
    final int orderCount    = userData?['orderCount'] ?? 0;
    final Color memberColor = _getMemberColor(memberType);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : RefreshIndicator(
              onRefresh: _fetchProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // ── Header ──
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
                              backgroundImage: imagePath != null
                                  ? NetworkImage("${AppConfig.baseUrl}$imagePath")
                                  : null,
                              child: imagePath == null
                                  ? const Icon(Icons.person, size: 50)
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 60),

                    // Name
                    Text(
                      userData?['fullname'] ?? "User",
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // Membership Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: memberColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: memberColor, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getMemberIcon(memberType),
                              color: memberColor, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            memberType,
                            style: TextStyle(
                                color: memberColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      "$orderCount orders placed",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 8),
                      child: _buildMembershipProgress(memberType, orderCount),
                    ),

                    const SizedBox(height: 10),

                    // Info tiles
                    _buildInfoTile(Icons.phone, "Phone Number",
                        userData?['phone'] ?? "Not set"),
                    _buildInfoTile(Icons.email, "Email Address",
                        userData?['email'] ?? "Not set"),
                    _buildInfoTile(
                        Icons.card_membership, "Membership", memberType),
                    _buildInfoTile(Icons.receipt_long, "Total Orders",
                        "$orderCount orders"),
                    _buildInfoTile(Icons.calendar_today, "Member Since",
                        userData?['created_at'] != null
                            ? userData!['created_at'].toString().substring(0, 10)
                            : "N/A"),

                    const SizedBox(height: 30),

                    // Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: () async {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditProfileScreen(
                                    name:     userData?['fullname'] ?? "",
                                    phone:    userData?['phone']    ?? "",
                                    email:    userData?['email']    ?? "",
                                    member:   memberType,
                                    imageUrl: imagePath != null
                                        ? "${AppConfig.baseUrl}$imagePath"
                                        : null,
                                  ),
                                ),
                              );
                              // ✅ Refresh profile after editing
                              if (updated == true) _fetchProfile();
                            },
                            child: const Text("Edit Profile",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: _handleLogout,
                            child: const Text("Log Out",
                                style: TextStyle(
                                    color: Colors.red, fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMembershipProgress(String memberType, int orderCount) {
    String nextLevel = '';
    int target = 0;

    if (memberType.toLowerCase() == 'regular') {
      nextLevel = 'Premium';
      target    = 5;
    } else if (memberType.toLowerCase() == 'premium') {
      nextLevel = 'VIP';
      target    = 10;
    } else {
      return const Text("🏆 You are a VIP member!",
          style: TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.bold,
              fontSize: 13));
    }

    final double progress = (orderCount / target).clamp(0.0, 1.0);
    final int remaining   = (target - orderCount).clamp(0, target);

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            color: _getMemberColor(nextLevel),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "$remaining more order${remaining == 1 ? '' : 's'} to reach $nextLevel",
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
      ),
    );
  }
}