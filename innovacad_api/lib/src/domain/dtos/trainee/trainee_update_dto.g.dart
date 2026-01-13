// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainee_update_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TraineeUpdateDto _$TraineeUpdateDtoFromJson(Map<String, dynamic> json) =>
    TraineeUpdateDto(
      birthdayDate: json['birthday_date'] == null
          ? null
          : DateTime.parse(json['birthday_date'] as String),
    );

Map<String, dynamic> _$TraineeUpdateDtoToJson(TraineeUpdateDto instance) =>
    <String, dynamic>{
      'birthday_date': instance.birthdayDate?.toIso8601String(),
    };
