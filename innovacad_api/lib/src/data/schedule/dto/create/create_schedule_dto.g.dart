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
      roomId: (json['room_id'] as num).toInt(),
      isOnline: json['is_online'] as bool,
      regimeType: (json['regime_type'] as num).toInt(),
      totalHours: (json['total_hours'] as num).toDouble(),
    );

Map<String, dynamic> _$CreateScheduleDtoToJson(CreateScheduleDto instance) =>
    <String, dynamic>{
      'class_module_id': instance.classModuleId,
      'trainer_id': instance.trainerId,
      'availability_id': instance.availabilityId,
      'room_id': instance.roomId,
      'is_online': instance.isOnline,
      'regime_type': instance.regimeType,
      'total_hours': instance.totalHours,
    };
