// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_create_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainerCreateDto _$TrainerCreateDtoFromJson(Map<String, dynamic> json) =>
    TrainerCreateDto(
      email: json['email'] as String,
      name: json['name'] as String,
      password: json['password'] as String,
      username: json['username'] as String,
      birthdayDate: DateTime.parse(json['birthday_date'] as String),
      specialization: json['specialization'] as String,
    );

Map<String, dynamic> _$TrainerCreateDtoToJson(TrainerCreateDto instance) =>
    <String, dynamic>{
      'username': instance.username,
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'birthday_date': instance.birthdayDate.toIso8601String(),
      'specialization': instance.specialization,
    };
