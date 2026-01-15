// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_trainee_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateTraineeDto _$CreateTraineeDtoFromJson(Map<String, dynamic> json) =>
    CreateTraineeDto(
      name: json['name'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      birthdayDate: const DateTimeConverter().fromJson(
        json['birthday_date'] as Object,
      ),
    );

Map<String, dynamic> _$CreateTraineeDtoToJson(CreateTraineeDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'username': instance.username,
      'password': instance.password,
      'birthday_date': const DateTimeConverter().toJson(instance.birthdayDate),
    };
