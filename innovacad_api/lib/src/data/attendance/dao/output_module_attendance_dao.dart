import 'package:innovacad_api/src/core/converters/double_converter.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'output_module_attendance_dao.g.dart';

@DTO()
@annotation.JsonSerializable()
class OutputModuleAttendanceDao {
  @annotation.JsonKey(name: 'trainee_id')
  final String traineeId;

  @annotation.JsonKey(name: 'attended_hours')
  @DoubleConverter()
  final double attendedHours;

  @annotation.JsonKey(name: 'total_hours')
  @DoubleConverter()
  final double totalHours;

  OutputModuleAttendanceDao({
    required this.traineeId,
    required this.attendedHours,
    required this.totalHours,
  });

  factory OutputModuleAttendanceDao.fromJson(Map<String, dynamic> json) =>
      _$OutputModuleAttendanceDaoFromJson(json);

  Map<String, dynamic> toJson() => _$OutputModuleAttendanceDaoToJson(this);
}
