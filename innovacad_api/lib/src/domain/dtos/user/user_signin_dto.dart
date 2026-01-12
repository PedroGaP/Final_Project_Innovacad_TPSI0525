import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as js;

part 'user_signin_dto.g.dart';

@DTO()
@js.JsonSerializable()
class UserSigninDto {
  @js.JsonKey(name: 'username')
  final String? username;

  @js.JsonKey(name: 'email')
  final String? email;

  @js.JsonKey(name: 'password')
  final String password;

  UserSigninDto({this.username, this.email, required this.password});

  Map<String, dynamic> toJson() => _$UserSigninDtoToJson(this);
}
