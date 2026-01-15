// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_trainee_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateTraineeDto _$UpdateTraineeDtoFromJson(Map<String, dynamic> json) =>
    UpdateTraineeDto(
      id: json['id'] as String,
      name: json['name'] as String?,
      username: json['username'] as String?,
      trainerId: json['trainer_id'] as String,
      birthdayDate: _$JsonConverterFromJson<Object, DateTime>(
        json['birthday_date'],
        const DateTimeConverter().fromJson,
      ),
    );

Map<String, dynamic> _$UpdateTraineeDtoToJson(UpdateTraineeDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'username': instance.username,
      'birthday_date': _$JsonConverterToJson<Object, DateTime>(
        instance.birthdayDate,
        const DateTimeConverter().toJson,
      ),
      'trainer_id': instance.trainerId,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
