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

  CreateCourseDto({required this.identifier, required this.name});

  Map<String, dynamic> toJson() => _$CreateCourseDtoToJson(this);

  factory CreateCourseDto.fromJson(Map<String, dynamic> json) =>
      _$CreateCourseDtoFromJson(json);
}
