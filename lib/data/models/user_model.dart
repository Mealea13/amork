class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String membershipStatus;
  final String? profileImage;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.membershipStatus = 'Member',
    this.profileImage,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'membershipStatus': membershipStatus,
      'profileImage': profileImage,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      membershipStatus: json['membershipStatus'] ?? 'Member',
      profileImage: json['profileImage'],
    );
  }
}