// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_schedule_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateScheduleDto _$UpdateScheduleDtoFromJson(Map<String, dynamic> json) =>
    UpdateScheduleDto(
      classModuleId: json['class_module_id'] as String?,
      trainerId: json['trainer_id'] as String?,
      roomId: (json['room_id'] as num?)?.toInt(),
      isOnline: json['is_online'] as bool?,
      regimeType: (json['regime_type'] as num?)?.toInt(),
      totalHours: (json['total_hours'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UpdateScheduleDtoToJson(UpdateScheduleDto instance) =>
    <String, dynamic>{
      'class_module_id': instance.classModuleId,
      'trainer_id': instance.trainerId,
      'room_id': instance.roomId,
      'is_online': instance.isOnline,
      'regime_type': instance.regimeType,
      'total_hours': instance.totalHours,
    };
