// lib/models/user.dart
class User {
  final int id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String? profileImage;
  final String role;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.address,
    this.profileImage,
    required this.role,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      profileImage: json['profile_image'],
      role: json['role'],
      isActive: json['is_active'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'address': address,
      'profile_image': profileImage,
      'role': role,
      'is_active': isActive ? 1 : 0,
    };
  }
}
