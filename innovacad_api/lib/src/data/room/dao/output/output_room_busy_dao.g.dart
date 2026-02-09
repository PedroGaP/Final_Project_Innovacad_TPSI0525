// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_room_busy_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputRoomBusyDao _$OutputRoomBusyDaoFromJson(Map<String, dynamic> json) =>
    OutputRoomBusyDao(
      scheduleId: json['schedule_id'] as String,
      startTime: const DateTimeConverter().fromJson(
        json['start_time'] as Object,
      ),
      endTime: const DateTimeConverter().fromJson(json['end_time'] as Object),
      moduleName: json['module_name'] as String?,
    );

Map<String, dynamic> _$OutputRoomBusyDaoToJson(OutputRoomBusyDao instance) =>
    <String, dynamic>{
      'schedule_id': instance.scheduleId,
      'start_time': const DateTimeConverter().toJson(instance.startTime),
      'end_time': const DateTimeConverter().toJson(instance.endTime),
      'module_name': instance.moduleName,
    };
