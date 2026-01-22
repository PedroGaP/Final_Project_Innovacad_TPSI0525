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

  UpdateCourseDto({this.identifier, this.name});

  Map<String, dynamic> toJson() => _$UpdateCourseDtoToJson(this);

  factory UpdateCourseDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateCourseDtoFromJson(json);
}
