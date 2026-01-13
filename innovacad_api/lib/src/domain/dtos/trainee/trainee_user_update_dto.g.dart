// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainee_user_update_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TraineeUserUpdateDto _$TraineeUserUpdateDtoFromJson(
  Map<String, dynamic> json,
) => TraineeUserUpdateDto(
  name: json['name'] as String?,
  image: json['image'] as String?,
  role: json['role'] as String?,
  username: json['username'] as String?,
  email: json['email'] as String?,
  birthdayDate: _$JsonConverterFromJson<Object, DateTime>(
    json['birthday_date'],
    dateTimePreserveConverter.fromJson,
  ),
);

Map<String, dynamic> _$TraineeUserUpdateDtoToJson(
  TraineeUserUpdateDto instance,
) => <String, dynamic>{
  'name': instance.name,
  'image': instance.image,
  'role': instance.role,
  'username': instance.username,
  'email': instance.email,
  'birthday_date': _$JsonConverterToJson<Object, DateTime>(
    instance.birthdayDate,
    dateTimePreserveConverter.toJson,
  ),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
