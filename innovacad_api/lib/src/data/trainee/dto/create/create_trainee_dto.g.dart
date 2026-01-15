// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_trainee_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateTraineeDto _$CreateTraineeDtoFromJson(Map<String, dynamic> json) =>
    CreateTraineeDto(
      email: json['email'] as String,
      username: json['username'] as String,
      name: json['name'] as String,
      password: json['password'] as String,
      birthdayDate: const DateTimeConverter().fromJson(
        json['birthday_date'] as Object,
      ),
    );

Map<String, dynamic> _$CreateTraineeDtoToJson(CreateTraineeDto instance) =>
    <String, dynamic>{
      'email': instance.email,
      'username': instance.username,
      'name': instance.name,
      'password': instance.password,
      'birthday_date': const DateTimeConverter().toJson(instance.birthdayDate),
    };
