import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'delete_course_module_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class DeleteCourseModuleDto {
  @annotation.JsonKey(name: 'courses_modules_id')
  final String coursesModulesId;

  DeleteCourseModuleDto({required this.coursesModulesId});

  Map<String, dynamic> toJson() => _$DeleteCourseModuleDtoToJson(this);

  factory DeleteCourseModuleDto.fromJson(Map<String, dynamic> json) =>
      _$DeleteCourseModuleDtoFromJson(json);
}
