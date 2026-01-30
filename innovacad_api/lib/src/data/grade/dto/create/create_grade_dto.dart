import 'package:innovacad_api/src/core/converters/double_converter.dart';
import 'package:vaden/vaden.dart' as v;
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'create_grade_dto.g.dart';

@v.DTO()
@annotation.JsonSerializable()
class CreateGradeDto {
  @annotation.JsonKey(name: 'class_module_id')
  @v.JsonKey('class_module_id')
  final String classModuleId;

  @annotation.JsonKey(name: 'trainee_id')
  @v.JsonKey('trainee_id')
  final String traineeId;

  @annotation.JsonKey(name: 'grade')
  @v.JsonKey('grade')
  @DoubleConverter()
  final String grade;

  @annotation.JsonKey(name: 'grade_type')
  @v.JsonKey('grade_type')
  final String gradeType;

  CreateGradeDto({
    required this.classModuleId,
    required this.traineeId,
    required this.grade,
    required this.gradeType,
  });

  Map<String, dynamic> toJson() => _$CreateGradeDtoToJson(this);

  factory CreateGradeDto.fromJson(Map<String, dynamic> json) =>
      _$CreateGradeDtoFromJson(json);
}
