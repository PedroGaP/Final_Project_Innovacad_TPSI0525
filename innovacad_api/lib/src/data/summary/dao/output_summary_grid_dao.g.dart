// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_summary_grid_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputSummaryGridDao _$OutputSummaryGridDaoFromJson(
  Map<String, dynamic> json,
) => OutputSummaryGridDao(
  summaryId: json['summary_id'] as String?,
  scheduleId: json['schedule_id'] as String,
  contents: json['contents'] as String?,
  students: (json['students'] as List<dynamic>)
      .map((e) => StudentAttendanceDao.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OutputSummaryGridDaoToJson(
  OutputSummaryGridDao instance,
) => <String, dynamic>{
  'summary_id': instance.summaryId,
  'schedule_id': instance.scheduleId,
  'contents': instance.contents,
  'students': instance.students,
};

StudentAttendanceDao _$StudentAttendanceDaoFromJson(
  Map<String, dynamic> json,
) => StudentAttendanceDao(
  traineeId: json['trainee_id'] as String,
  name: json['name'] as String,
  image: json['image'] as String?,
  isAbsent: json['is_absent'] as bool,
);

Map<String, dynamic> _$StudentAttendanceDaoToJson(
  StudentAttendanceDao instance,
) => <String, dynamic>{
  'trainee_id': instance.traineeId,
  'name': instance.name,
  'image': instance.image,
  'is_absent': instance.isAbsent,
};
