// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_signin_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSigninDto _$UserSigninDtoFromJson(Map<String, dynamic> json) =>
    UserSigninDto(
      username: json['username'] as String?,
      email: json['email'] as String?,
      password: json['password'] as String,
    );

Map<String, dynamic> _$UserSigninDtoToJson(UserSigninDto instance) =>
    <String, dynamic>{
      'username': instance.username,
      'email': instance.email,
      'password': instance.password,
    };
