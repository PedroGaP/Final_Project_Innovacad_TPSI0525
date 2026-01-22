// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_availability_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateAvailabilityDto _$UpdateAvailabilityDtoFromJson(
  Map<String, dynamic> json,
) => UpdateAvailabilityDto(
  trainerId: json['trainer_id'] as String?,
  status: json['status'] as String?,
  startDateTimestamp: _$JsonConverterFromJson<Object, DateTime>(
    json['start_date_timestamp'],
    const DateTimeConverter().fromJson,
  ),
  endDateTimestamp: _$JsonConverterFromJson<Object, DateTime>(
    json['end_date_timestamp'],
    const DateTimeConverter().fromJson,
  ),
);

Map<String, dynamic> _$UpdateAvailabilityDtoToJson(
  UpdateAvailabilityDto instance,
) => <String, dynamic>{
  'trainer_id': instance.trainerId,
  'status': instance.status,
  'start_date_timestamp': _$JsonConverterToJson<Object, DateTime>(
    instance.startDateTimestamp,
    const DateTimeConverter().toJson,
  ),
  'end_date_timestamp': _$JsonConverterToJson<Object, DateTime>(
    instance.endDateTimestamp,
    const DateTimeConverter().toJson,
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
