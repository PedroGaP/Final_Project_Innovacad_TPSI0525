// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_trainer_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateTrainerDto _$UpdateTrainerDtoFromJson(Map<String, dynamic> json) =>
    UpdateTrainerDto(
      name: json['name'] as String?,
      image: json['image'] as String?,
      birthdayDate: _$JsonConverterFromJson<Object, DateTime>(
        json['birthday_date'],
        const DateTimeConverter().fromJson,
      ),
      specialization: json['specialization'] as String?,
    );

Map<String, dynamic> _$UpdateTrainerDtoToJson(UpdateTrainerDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'image': instance.image,
      'birthday_date': _$JsonConverterToJson<Object, DateTime>(
        instance.birthdayDate,
        const DateTimeConverter().toJson,
      ),
      'specialization': instance.specialization,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
