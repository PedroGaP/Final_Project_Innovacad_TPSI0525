import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'update_user_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class UpdateUserDto {
  @annotation.JsonKey(name: 'id')
  final String id;

  @annotation.JsonKey(name: 'name')
  final String? name;

  @annotation.JsonKey(name: 'username')
  final String? username;

  @annotation.JsonKey(name: 'password')
  final String? password;

  UpdateUserDto({
    required this.id,
    this.name,
    this.username,
    this.password,
  });

  Map<String, dynamic> toJson() => _$UpdateUserDtoToJson(this);

  factory UpdateUserDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserDtoFromJson(json);
}
