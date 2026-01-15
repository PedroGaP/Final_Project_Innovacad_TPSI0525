import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'output_course_dao.g.dart';

@DTO()
@annotation.JsonSerializable()
class OutputCourseDao {
  @annotation.JsonKey(name: 'course_id')
  final String courseId;

  @annotation.JsonKey(name: 'identifier')
  final String identifier;

  @annotation.JsonKey(name: 'name')
  final String name;

  // Assuming createdAt might be useful or standard, but sticking to old Course fields + standard if revealed later.
  // Old Course only had course_id, identifier, name.

  OutputCourseDao({
    required this.courseId,
    required this.identifier,
    required this.name,
  });

  Map<String, dynamic> toJson() => _$OutputCourseDaoToJson(this);

  factory OutputCourseDao.fromJson(Map<String, dynamic> json) =>
      _$OutputCourseDaoFromJson(json);
}
