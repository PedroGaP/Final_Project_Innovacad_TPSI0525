// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_schedule_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateScheduleDto _$CreateScheduleDtoFromJson(Map<String, dynamic> json) =>
    CreateScheduleDto(
      classModuleId: json['class_module_id'] as String,
      trainerId: json['trainer_id'] as String,
      availabilityId: json['availability_id'] as String,
      roomId: (json['room_id'] as num?)?.toInt(),
      online: json['online'] as bool,
      startDateTimestamp: const DateTimeConverter().fromJson(
        json['start_date_timestamp'] as Object,
      ),
      endDateTimestamp: const DateTimeConverter().fromJson(
        json['end_date_timestamp'] as Object,
      ),
    );

Map<String, dynamic> _$CreateScheduleDtoToJson(CreateScheduleDto instance) =>
    <String, dynamic>{
      'class_module_id': instance.classModuleId,
      'trainer_id': instance.trainerId,
      'availability_id': instance.availabilityId,
      'room_id': instance.roomId,
      'online': instance.online,
      'start_date_timestamp': const DateTimeConverter().toJson(
        instance.startDateTimestamp,
      ),
      'end_date_timestamp': const DateTimeConverter().toJson(
        instance.endDateTimestamp,
      ),
    };
