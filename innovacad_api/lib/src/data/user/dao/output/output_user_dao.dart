import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;
import "package:innovacad_api/src/core/core.dart";
part 'output_user_dao.g.dart';

@DTO()
@annotation.JsonSerializable()
class OutputUserDao {
  @annotation.JsonKey(name: 'id')
  final String id;

  @annotation.JsonKey(name: 'name')
  final String name;

  @annotation.JsonKey(name: 'email')
  final String email;

  @annotation.JsonKey(name: 'username')
  final String username;

  @annotation.JsonKey(name: 'role')
  final String role;

  @annotation.JsonKey(name: 'createdAt')
  @DateTimeConverter()
  final DateTime createdAt;

  @annotation.JsonKey(name: 'image')
  final String? image;

  @annotation.JsonKey(name: 'token')
  final String? token;

  @annotation.JsonKey(name: 'session_token')
  final String? sessionToken;

  @annotation.JsonKey(name: 'emailVerified')
  final bool verified;

  OutputUserDao({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    required this.createdAt,
    required this.role,
    required this.verified,
    this.image,
    this.token,
    this.sessionToken,
  });

  Map<String, dynamic> toJson() => _$OutputUserDaoToJson(this);

  factory OutputUserDao.fromJson(Map<String, dynamic> json) =>
      _$OutputUserDaoFromJson(json);
}
