// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_schedule_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputScheduleDao _$OutputScheduleDaoFromJson(Map<String, dynamic> json) =>
    OutputScheduleDao(
      scheduleId: json['schedule_id'] as String?,
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
      isOnline: json['is_online'] as String?,
      dateDay: _$JsonConverterFromJson<Object, DateTime>(
        json['date_day'],
        const DateTimeConverter().fromJson,
      ),
      regimeType: json['regime_type'] as String?,
      roomName: json['room_name'] as String?,
    );

Map<String, dynamic> _$OutputScheduleDaoToJson(OutputScheduleDao instance) =>
    <String, dynamic>{
      'schedule_id': instance.scheduleId,
      'regime_type': instance.regimeType,
      'module_name': instance.moduleName,
      'trainer_name': instance.trainerName,
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
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
