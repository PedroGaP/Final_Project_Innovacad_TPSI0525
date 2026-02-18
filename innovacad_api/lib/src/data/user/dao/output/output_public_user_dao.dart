import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;
import "package:innovacad_api/src/core/core.dart";

part 'output_public_user_dao.g.dart';

@DTO()
@annotation.JsonSerializable()
class OutputPublicUserDao {
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

  @annotation.JsonKey(name: 'is_coordinator', readValue: convertBoolean)
  @NumberConverter()
  final bool? isCoordinator;

  @annotation.JsonKey(name: 'coordinated_class_ids')
  final Map<String, String>? coordinatedClassIds;

  OutputPublicUserDao({
    required this.username,
    required this.email,
    required this.name,
    required this.createdAt,
    required this.role,
    this.isCoordinator,
    this.coordinatedClassIds,
    this.image,
  });

  static bool convertBoolean(Map map, String s) {
    if (map[s] is bool) return map[s];
    if (map[s] is int) return map[s] == null ? false : map[s] == 1;
    return false;
  }

  Map<String, dynamic> toJson() => _$OutputPublicUserDaoToJson(this);

  factory OutputPublicUserDao.fromJson(Map<String, dynamic> json) =>
      _$OutputPublicUserDaoFromJson(json);
}
