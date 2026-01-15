// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_schedule_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateScheduleDto _$UpdateScheduleDtoFromJson(Map<String, dynamic> json) =>
    UpdateScheduleDto(
      scheduleId: json['schedule_id'] as String,
      classModuleId: json['class_module_id'] as String?,
      trainerId: json['trainer_id'] as String?,
      availabilityId: json['availability_id'] as String?,
      roomId: (json['room_id'] as num?)?.toInt(),
      online: json['online'] as bool?,
      startDateTimestamp: _$JsonConverterFromJson<Object, DateTime>(
        json['start_date_timestamp'],
        const DateTimeConverter().fromJson,
      ),
      endDateTimestamp: _$JsonConverterFromJson<Object, DateTime>(
        json['end_date_timestamp'],
        const DateTimeConverter().fromJson,
      ),
    );

Map<String, dynamic> _$UpdateScheduleDtoToJson(UpdateScheduleDto instance) =>
    <String, dynamic>{
      'schedule_id': instance.scheduleId,
      'class_module_id': instance.classModuleId,
      'trainer_id': instance.trainerId,
      'availability_id': instance.availabilityId,
      'room_id': instance.roomId,
      'online': instance.online,
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
