import 'package:innovacad_api/src/data/module/dto/link/link_module_dto.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'update_course_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class UpdateCourseDto {
  @annotation.JsonKey(name: 'identifier')
  final String? identifier;

  @annotation.JsonKey(name: 'name')
  final String? name;

  @annotation.JsonKey(name: 'add_modules_ids')
  @JsonKey('add_modules_ids')
  final List<LinkModuleDto>? addCoursesModules;

  @annotation.JsonKey(name: 'remove_modules_ids')
  @JsonKey('remove_modules_ids')
  final List<String>? removeCoursesModules;

  UpdateCourseDto({
    this.identifier,
    this.name,
    this.addCoursesModules,
    this.removeCoursesModules,
  });

  Map<String, dynamic> toJson() => _$UpdateCourseDtoToJson(this);

  factory UpdateCourseDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateCourseDtoFromJson(json);
}
