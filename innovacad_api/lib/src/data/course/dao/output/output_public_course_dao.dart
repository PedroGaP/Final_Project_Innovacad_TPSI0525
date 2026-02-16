import 'package:innovacad_api/src/data/data.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'output_public_course_dao.g.dart';

@annotation.JsonSerializable()
class OutputPublicCourseDao {
  @annotation.JsonKey(name: 'identifier')
  final String identifier;

  @annotation.JsonKey(name: 'name')
  final String name;

  @annotation.JsonKey(name: 'area')
  final String area;

  @annotation.JsonKey(name: 'modules')
  final List<OutputCourseModuleDao>? coursesModules;

  OutputPublicCourseDao({
    required this.identifier,
    required this.name,
    required this.area,
    this.coursesModules,
  });

  Map<String, dynamic> toJson() => _$OutputPublicCourseDaoToJson(this);

  factory OutputPublicCourseDao.fromJson(Map<String, dynamic> json) =>
      _$OutputPublicCourseDaoFromJson(json);
}
