import 'package:equatable/equatable.dart';
import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final DateTime? emailVerifiedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.emailVerifiedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: ParserUtils.parseInt(json['id']),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      avatarUrl: (json['avatar_url'] ?? json['avatarUrl']) as String?,
      emailVerifiedAt: DateTime.tryParse((json['email_verified_at'] ?? json['emailVerifiedAt'])?.toString() ?? '') ,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'avatar_url': avatarUrl,
        'email_verified_at': emailVerifiedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, name, email, phone, avatarUrl, emailVerifiedAt];
}
