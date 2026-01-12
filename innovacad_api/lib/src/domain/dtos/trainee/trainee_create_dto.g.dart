// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainee_create_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TraineeCreateDto _$TraineeCreateDtoFromJson(Map<String, dynamic> json) =>
    TraineeCreateDto(
      first_name: json['first_name'] as String,
      last_name: json['last_name'] as String,
      birthday_date: DateTime.parse(json['birthday_date'] as String),
    );

Map<String, dynamic> _$TraineeCreateDtoToJson(TraineeCreateDto instance) =>
    <String, dynamic>{
      'first_name': instance.first_name,
      'last_name': instance.last_name,
      'birthday_date': instance.birthday_date.toIso8601String(),
    };
