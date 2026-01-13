// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_signup_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSignupDto _$UserSignupDtoFromJson(Map<String, dynamic> json) =>
    UserSignupDto(
      username: json['username'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$UserSignupDtoToJson(UserSignupDto instance) =>
    <String, dynamic>{
      'username': instance.username,
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
    };
