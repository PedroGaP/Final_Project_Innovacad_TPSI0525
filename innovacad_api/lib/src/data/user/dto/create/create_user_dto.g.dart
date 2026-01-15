// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateUserDto _$CreateUserDtoFromJson(Map<String, dynamic> json) =>
    CreateUserDto(
      name: json['name'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$CreateUserDtoToJson(CreateUserDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'username': instance.username,
      'password': instance.password,
    };
