import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'output_summary_grid_dao.g.dart';

@DTO()
@annotation.JsonSerializable()
class OutputSummaryGridDao {
  @annotation.JsonKey(name: 'summary_id')
  final String? summaryId;

  @annotation.JsonKey(name: 'schedule_id')
  final String scheduleId;

  @annotation.JsonKey(name: 'contents')
  final String? contents;

  @annotation.JsonKey(name: 'students')
  final List<StudentAttendanceDao> students;

  OutputSummaryGridDao({
    this.summaryId,
    required this.scheduleId,
    this.contents,
    required this.students,
  });

  Map<String, dynamic> toJson() => _$OutputSummaryGridDaoToJson(this);
  factory OutputSummaryGridDao.fromJson(Map<String, dynamic> json) =>
      _$OutputSummaryGridDaoFromJson(json);
}

@annotation.JsonSerializable()
class StudentAttendanceDao {
  @annotation.JsonKey(name: 'trainee_id')
  final String traineeId;

  @annotation.JsonKey(name: 'name')
  final String name;

  @annotation.JsonKey(name: 'image')
  final String? image;

  @annotation.JsonKey(name: 'is_absent')
  final bool isAbsent;

  StudentAttendanceDao({
    required this.traineeId,
    required this.name,
    this.image,
    required this.isAbsent,
  });

  Map<String, dynamic> toJson() => _$StudentAttendanceDaoToJson(this);
  factory StudentAttendanceDao.fromJson(Map<String, dynamic> json) =>
      _$StudentAttendanceDaoFromJson(json);
}
