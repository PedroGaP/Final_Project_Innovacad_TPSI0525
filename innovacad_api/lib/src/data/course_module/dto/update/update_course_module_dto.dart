import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'update_course_module_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class UpdateCourseModuleDto {
  @annotation.JsonKey(name: 'courses_modules_id')
  final String coursesModulesId;

  @annotation.JsonKey(name: 'course_id')
  final String? courseId;

  @annotation.JsonKey(name: 'module_id')
  final String? moduleId;

  @annotation.JsonKey(name: 'sequence_course_module_id')
  final String? sequenceCourseModuleId;

  UpdateCourseModuleDto({
    required this.coursesModulesId,
    this.courseId,
    this.moduleId,
    this.sequenceCourseModuleId,
  });

  Map<String, dynamic> toJson() => _$UpdateCourseModuleDtoToJson(this);

  factory UpdateCourseModuleDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateCourseModuleDtoFromJson(json);
}
