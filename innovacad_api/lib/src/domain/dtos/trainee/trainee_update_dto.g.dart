// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainee_update_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TraineeUpdateDto _$TraineeUpdateDtoFromJson(Map<String, dynamic> json) =>
    TraineeUpdateDto(
      user_id: json['user_id'] as String?,
      birthday_date: json['birthday_date'] == null
          ? null
          : DateTime.parse(json['birthday_date'] as String),
    );

Map<String, dynamic> _$TraineeUpdateDtoToJson(TraineeUpdateDto instance) =>
    <String, dynamic>{
      'user_id': instance.user_id,
      'birthday_date': instance.birthday_date?.toIso8601String(),
    };
