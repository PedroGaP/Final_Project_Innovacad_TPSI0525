// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_module_attendance_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputModuleAttendanceDao _$OutputModuleAttendanceDaoFromJson(
  Map<String, dynamic> json,
) => OutputModuleAttendanceDao(
  traineeId: json['trainee_id'] as String,
  attendedHours: const DoubleConverter().fromJson(
    json['attended_hours'] as Object,
  ),
  totalHours: const DoubleConverter().fromJson(json['total_hours'] as Object),
);

Map<String, dynamic> _$OutputModuleAttendanceDaoToJson(
  OutputModuleAttendanceDao instance,
) => <String, dynamic>{
  'trainee_id': instance.traineeId,
  'attended_hours': const DoubleConverter().toJson(instance.attendedHours),
  'total_hours': const DoubleConverter().toJson(instance.totalHours),
};
