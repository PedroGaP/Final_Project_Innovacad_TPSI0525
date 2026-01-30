// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_trainer_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateTrainerDto _$CreateTrainerDtoFromJson(Map<String, dynamic> json) =>
    CreateTrainerDto(
      name: json['name'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      birthdayDate: const DateTimeConverter().fromJson(
        json['birthday_date'] as Object,
      ),
      skillsToAdd: (json['skills_to_add'] as List<dynamic>?)
          ?.map((e) => TrainerSkillDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CreateTrainerDtoToJson(CreateTrainerDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'username': instance.username,
      'password': instance.password,
      'birthday_date': const DateTimeConverter().toJson(instance.birthdayDate),
      'skills_to_add': instance.skillsToAdd,
    };
