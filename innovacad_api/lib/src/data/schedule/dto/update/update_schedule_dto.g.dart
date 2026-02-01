// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_schedule_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateScheduleDto _$UpdateScheduleDtoFromJson(Map<String, dynamic> json) =>
    UpdateScheduleDto(
      trainerId: json['trainer_id'] as String?,
      roomId: (json['room_id'] as num?)?.toInt(),
      isOnline: json['is_online'] as bool?,
      regimeType: (json['regime_type'] as num?)?.toInt(),
      startTime: _$JsonConverterFromJson<Object, DateTime>(
        json['start_time'],
        const DateTimeConverter().fromJson,
      ),
      endTime: _$JsonConverterFromJson<Object, DateTime>(
        json['end_time'],
        const DateTimeConverter().fromJson,
      ),
    );

Map<String, dynamic> _$UpdateScheduleDtoToJson(UpdateScheduleDto instance) =>
    <String, dynamic>{
      'trainer_id': instance.trainerId,
      'room_id': instance.roomId,
      'is_online': instance.isOnline,
      'regime_type': instance.regimeType,
      'start_time': _$JsonConverterToJson<Object, DateTime>(
        instance.startTime,
        const DateTimeConverter().toJson,
      ),
      'end_time': _$JsonConverterToJson<Object, DateTime>(
        instance.endTime,
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
