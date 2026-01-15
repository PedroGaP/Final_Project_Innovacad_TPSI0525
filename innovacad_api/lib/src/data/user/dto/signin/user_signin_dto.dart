import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'user_signin_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class UserSigninDto {
  @annotation.JsonKey(name: 'email')
  final String? email;

  @annotation.JsonKey(name: 'username')
  final String? username;

  @annotation.JsonKey(name: 'password')
  final String password;

  UserSigninDto({this.email, this.username, required this.password});

  Map<String, dynamic> toJson() => _$UserSigninDtoToJson(this);

  factory UserSigninDto.fromJson(Map<String, dynamic> json) =>
      _$UserSigninDtoFromJson(json);
}
