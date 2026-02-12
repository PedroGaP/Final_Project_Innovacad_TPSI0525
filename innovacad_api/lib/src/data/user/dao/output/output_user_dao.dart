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

  @annotation.JsonKey(name: 'emailVerified', readValue: convertBoolean)
  @NumberConverter()
  final bool? verified;

  @annotation.JsonKey(
    name: 'twoFactorEnabled',
    defaultValue: false,
    readValue: convertBoolean,
  )
  @NumberConverter()
  final bool? twoFactorEnabled;

  @annotation.JsonKey(name: 'is_coordinator', readValue: convertBoolean)
  @NumberConverter()
  final bool? isCoordinator;

  @annotation.JsonKey(name: 'coordinated_class_ids')
  final List<String>? coordinatedClassIds;

  OutputUserDao({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    required this.createdAt,
    required this.role,
    required this.verified,
    required this.twoFactorEnabled,
    this.isCoordinator,
    this.coordinatedClassIds,
    this.image,
    this.token,
    this.sessionToken,
  });

  static bool convertBoolean(Map map, String s) {
    print("CONVERT BOOLEAN ($s): ${map[s]} > $map");
    if (map[s] is bool) return map[s];
    if (map[s] is int) return map[s] == null ? false : map[s] == 1;
    return false;
  }

  Map<String, dynamic> toJson() => _$OutputUserDaoToJson(this);

  factory OutputUserDao.fromJson(Map<String, dynamic> json) =>
      _$OutputUserDaoFromJson(json);
}
