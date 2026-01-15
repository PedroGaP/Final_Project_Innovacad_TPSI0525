import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'update_course_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class UpdateCourseDto {
  @annotation.JsonKey(name: 'course_id')
  final String courseId;

  @annotation.JsonKey(name: 'identifier')
  final String? identifier;

  @annotation.JsonKey(name: 'name')
  final String? name;

  UpdateCourseDto({
    required this.courseId,
    this.identifier,
    this.name,
  });

  Map<String, dynamic> toJson() => _$UpdateCourseDtoToJson(this);

  factory UpdateCourseDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateCourseDtoFromJson(json);
}
