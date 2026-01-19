import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'update_user_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class UpdateUserDto {
  @annotation.JsonKey(name: 'name')
  final String? name;

  @annotation.JsonKey(name: 'username')
  final String? username;

  @annotation.JsonKey(name: 'old_password')
  final String? oldPassword;

  @annotation.JsonKey(name: 'new_password')
  final String? newPassword;

  @annotation.JsonKey(name: 'image')
  final String? image;

  @annotation.JsonKey(name: 'session_token')
  final String? sessionToken;

  UpdateUserDto({
    this.name,
    this.username,
    this.oldPassword,
    this.newPassword,
    this.image,
    this.sessionToken,
  });

  Map<String, dynamic> toJson() => _$UpdateUserDtoToJson(this);

  factory UpdateUserDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserDtoFromJson(json);
}
