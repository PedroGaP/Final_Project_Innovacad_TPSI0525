import 'package:innovacad_api/src/core/core.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'output_course_module_dao.g.dart';

@DTO()
@annotation.JsonSerializable()
class OutputCourseModuleDao {
  @annotation.JsonKey(name: 'courses_modules_id')
  final String coursesModulesId;

  @annotation.JsonKey(name: 'module_id')
  final String moduleId;

  @annotation.JsonKey(name: 'sequence_course_module_id')
  final String? sequenceCourseModuleId;

  @annotation.JsonKey(name: 'module_name')
  final String? moduleName;

  @annotation.JsonKey(name: 'duration')
  @NumberConverter()
  final int? duration;

  OutputCourseModuleDao({
    required this.coursesModulesId,
    required this.moduleId,
    this.sequenceCourseModuleId,
    this.moduleName,
    this.duration,
  });

  Map<String, dynamic> toJson() => _$OutputCourseModuleDaoToJson(this);

  factory OutputCourseModuleDao.fromJson(Map<String, dynamic> json) =>
      _$OutputCourseModuleDaoFromJson(json);
}
