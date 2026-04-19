import 'dart:convert';

class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String? role;

  User(
      {required this.id,
      required this.name,
      required this.email,
      this.phone,
      this.avatarUrl,
      this.role});

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        avatarUrl: json['avatar_url'] ?? json['avatar'] as String?,
        role: json['role'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'avatar_url': avatarUrl,
        'role': role
      };
  String toJsonString() => json.encode(toJson());
}
