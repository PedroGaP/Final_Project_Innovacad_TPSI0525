// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaveSummaryDto _$SaveSummaryDtoFromJson(Map<String, dynamic> json) =>
    SaveSummaryDto(
      scheduleId: json['schedule_id'] as String,
      contents: json['contents'] as String,
      attendances: (json['attendances'] as List<dynamic>)
          .map((e) => AttendanceItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SaveSummaryDtoToJson(SaveSummaryDto instance) =>
    <String, dynamic>{
      'schedule_id': instance.scheduleId,
      'contents': instance.contents,
      'attendances': instance.attendances,
    };

AttendanceItemDto _$AttendanceItemDtoFromJson(Map<String, dynamic> json) =>
    AttendanceItemDto(
      traineeId: json['trainee_id'] as String,
      isAbsent: json['is_absent'] as bool,
    );

Map<String, dynamic> _$AttendanceItemDtoToJson(AttendanceItemDto instance) =>
    <String, dynamic>{
      'trainee_id': instance.traineeId,
      'is_absent': instance.isAbsent,
    };
