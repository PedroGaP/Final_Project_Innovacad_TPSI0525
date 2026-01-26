import 'package:vaden/vaden.dart' as vaden;
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'create_course_module_dto.g.dart';

@vaden.DTO()
@annotation.JsonSerializable()
class CreateCourseModuleDto {
  @annotation.JsonKey(name: 'course_id')
  @vaden.JsonKey('course_id')
  final String courseId;

  @annotation.JsonKey(name: 'module_id')
  @vaden.JsonKey('module_id')
  final String moduleId;

  @annotation.JsonKey(name: 'sequence_course_module_id')
  @vaden.JsonKey('sequence_course_module_id')
  final String? sequenceCourseModuleId;

  CreateCourseModuleDto({
    required this.courseId,
    required this.moduleId,
    this.sequenceCourseModuleId,
  });

  Map<String, dynamic> toJson() => _$CreateCourseModuleDtoToJson(this);

  factory CreateCourseModuleDto.fromJson(Map<String, dynamic> json) =>
      _$CreateCourseModuleDtoFromJson(json);
}
