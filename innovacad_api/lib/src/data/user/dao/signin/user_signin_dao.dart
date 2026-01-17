import 'package:innovacad_api/src/core/converters/date_time_converter.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'user_signin_dao.g.dart';

@DTO()
@annotation.JsonSerializable()
class UserSigninDao extends OutputUserDao {
  UserSigninDao({
    required super.id,
    required super.username,
    required super.email,
    required super.name,
    required super.createdAt,
    required super.role,
    required super.verified,
    super.image,
    super.token,
  });

  factory UserSigninDao.fromJson(Map<String, dynamic> json) =>
      _$UserSigninDaoFromJson(json);

  Map<String, dynamic> toJson() => _$UserSigninDaoToJson(this);
}
