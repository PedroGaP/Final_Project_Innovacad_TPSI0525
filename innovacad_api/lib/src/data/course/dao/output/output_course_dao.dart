import 'package:innovacad_api/src/data/data.dart';
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

  @annotation.JsonKey(name: 'modules')
  final List<OutputCourseModuleDao>? coursesModules;

  OutputCourseDao({
    required this.courseId,
    required this.identifier,
    required this.name,
    this.coursesModules,
  });

  Map<String, dynamic> toJson() => _$OutputCourseDaoToJson(this);

  factory OutputCourseDao.fromJson(Map<String, dynamic> json) =>
      _$OutputCourseDaoFromJson(json);
}
