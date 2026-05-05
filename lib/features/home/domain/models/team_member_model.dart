import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';

class TeamMemberModel {
  final int id;
  final String name;
  final String position;
  final String photoUrl;

  TeamMemberModel({
    required this.id,
    required this.name,
    required this.position,
    required this.photoUrl,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      id: ParserUtils.parseInt(json['id']),
      name: json['name'] as String? ?? '',
      position: json['position'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? json['photo_url'] as String? ?? '',
    );
  }
}
