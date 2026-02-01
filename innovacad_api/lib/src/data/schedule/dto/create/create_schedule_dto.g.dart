// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_schedule_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateScheduleDto _$CreateScheduleDtoFromJson(Map<String, dynamic> json) =>
    CreateScheduleDto(
      classModuleId: json['class_module_id'] as String,
      trainerId: json['trainer_id'] as String,
      roomId: (json['room_id'] as num?)?.toInt(),
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      forceTrainerChange: json['force_trainer_change'] as bool? ?? false,
    );

Map<String, dynamic> _$CreateScheduleDtoToJson(CreateScheduleDto instance) =>
    <String, dynamic>{
      'class_module_id': instance.classModuleId,
      'trainer_id': instance.trainerId,
      'room_id': instance.roomId,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime.toIso8601String(),
      'force_trainer_change': instance.forceTrainerChange,
    };
