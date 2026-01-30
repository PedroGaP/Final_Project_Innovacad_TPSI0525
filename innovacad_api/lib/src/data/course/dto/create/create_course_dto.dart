import 'package:innovacad_api/src/data/module/dto/link/link_module_dto.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'create_course_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class CreateCourseDto {
  @annotation.JsonKey(name: 'identifier')
  final String identifier;

  @annotation.JsonKey(name: 'name')
  final String name;

  @annotation.JsonKey(name: 'add_courses_modules')
  @JsonKey('add_modules_ids')
  final List<LinkModuleDto>? addModulesIds;

  @annotation.JsonKey(name: 'remove_courses_modules')
  @JsonKey('remove_modules_ids')
  final List<String>? removeCoursesModulesIds;

  CreateCourseDto({
    required this.identifier,
    required this.name,
    this.addModulesIds,
    this.removeCoursesModulesIds,
  });

  Map<String, dynamic> toJson() => _$CreateCourseDtoToJson(this);

  factory CreateCourseDto.fromJson(Map<String, dynamic> json) =>
      _$CreateCourseDtoFromJson(json);
}
