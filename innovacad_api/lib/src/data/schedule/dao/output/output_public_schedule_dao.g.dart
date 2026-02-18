// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_public_schedule_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputPublicScheduleDao _$OutputPublicScheduleDaoFromJson(
  Map<String, dynamic> json,
) => OutputPublicScheduleDao(
  moduleName: json['module_name'] as String?,
  trainerName: json['trainer_name'] as String?,
  startTime: _$JsonConverterFromJson<Object, Duration>(
    json['start_time'],
    const DurationConverter().fromJson,
  ),
  endTime: _$JsonConverterFromJson<Object, Duration>(
    json['end_time'],
    const DurationConverter().fromJson,
  ),
  isOnline: json['is_online'] as bool?,
  dateDay: _$JsonConverterFromJson<Object, DateTime>(
    json['date_day'],
    const DateTimeConverter().fromJson,
  ),
  regimeType: json['regime_type'] as String?,
  roomName: json['room_name'] as String?,
  className: json['class_name'] as String?,
  currentDuration: (json['current_duration'] as num?)?.toDouble(),
  totalDuration: (json['total_duration'] as num?)?.toDouble(),
  trainerEmail: json['trainer_email'] as String?,
);

Map<String, dynamic> _$OutputPublicScheduleDaoToJson(
  OutputPublicScheduleDao instance,
) => <String, dynamic>{
  'regime_type': instance.regimeType,
  'module_name': instance.moduleName,
  'trainer_name': instance.trainerName,
  'trainer_email': instance.trainerEmail,
  'date_day': _$JsonConverterToJson<Object, DateTime>(
    instance.dateDay,
    const DateTimeConverter().toJson,
  ),
  'start_time': _$JsonConverterToJson<Object, Duration>(
    instance.startTime,
    const DurationConverter().toJson,
  ),
  'end_time': _$JsonConverterToJson<Object, Duration>(
    instance.endTime,
    const DurationConverter().toJson,
  ),
  'is_online': instance.isOnline,
  'room_name': instance.roomName,
  'class_name': instance.className,
  'current_duration': instance.currentDuration,
  'total_duration': instance.totalDuration,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
