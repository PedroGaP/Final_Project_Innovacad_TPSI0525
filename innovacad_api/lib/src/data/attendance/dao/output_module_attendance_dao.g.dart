// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_module_attendance_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputModuleAttendanceDao _$OutputModuleAttendanceDaoFromJson(
  Map<String, dynamic> json,
) => OutputModuleAttendanceDao(
  traineeId: json['trainee_id'] as String,
  attendedHours: (json['attended_hours'] as num).toDouble(),
  totalHours: (json['total_hours'] as num).toDouble(),
);

Map<String, dynamic> _$OutputModuleAttendanceDaoToJson(
  OutputModuleAttendanceDao instance,
) => <String, dynamic>{
  'trainee_id': instance.traineeId,
  'attended_hours': instance.attendedHours,
  'total_hours': instance.totalHours,
};
