import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'delete_course_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class DeleteCourseDto {
  @annotation.JsonKey(name: 'course_id')
  final String courseId;

  DeleteCourseDto({required this.courseId});

  Map<String, dynamic> toJson() => _$DeleteCourseDtoToJson(this);

  factory DeleteCourseDto.fromJson(Map<String, dynamic> json) =>
      _$DeleteCourseDtoFromJson(json);
}
