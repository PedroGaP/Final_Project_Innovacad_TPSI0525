import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'create_user_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class CreateUserDto {
  @annotation.JsonKey(name: 'name')
  final String name;

  @annotation.JsonKey(name: 'email')
  final String email;

  @annotation.JsonKey(name: 'username')
  final String username;

  @annotation.JsonKey(name: 'password')
  final String password;

  CreateUserDto({
    required this.name,
    required this.email,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => _$CreateUserDtoToJson(this);

  factory CreateUserDto.fromJson(Map<String, dynamic> json) =>
      _$CreateUserDtoFromJson(json);
}
