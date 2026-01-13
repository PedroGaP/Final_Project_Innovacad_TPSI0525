import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as js;

part 'user_signup_dto.g.dart';

@DTO()
@js.JsonSerializable()
class UserSignupDto {
  @js.JsonKey(name: 'username')
  final String username;

  @js.JsonKey(name: 'name')
  final String name;

  @js.JsonKey(name: 'email')
  final String email;

  @js.JsonKey(name: 'password')
  final String password;

  UserSignupDto({
    required this.username,
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => _$UserSignupDtoToJson(this);
}
