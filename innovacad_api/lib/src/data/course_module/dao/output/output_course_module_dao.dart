import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'output_course_module_dao.g.dart';

@DTO()
@annotation.JsonSerializable()
class OutputCourseModuleDao {
  @annotation.JsonKey(name: 'courses_modules_id')
  final String coursesModulesId;

  @annotation.JsonKey(name: 'course_id')
  final String courseId;

  @annotation.JsonKey(name: 'module_id')
  final String moduleId;

  @annotation.JsonKey(name: 'sequence_course_module_id')
  final String? sequenceCourseModuleId;

  OutputCourseModuleDao({
    required this.coursesModulesId,
    required this.courseId,
    required this.moduleId,
    this.sequenceCourseModuleId,
  });

  Map<String, dynamic> toJson() => _$OutputCourseModuleDaoToJson(this);

  factory OutputCourseModuleDao.fromJson(Map<String, dynamic> json) =>
      _$OutputCourseModuleDaoFromJson(json);
}
