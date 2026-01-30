import 'package:innovacad_api/src/core/converters/double_converter.dart';
import 'package:vaden/vaden.dart' as v;
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'update_grade_dto.g.dart';

@v.DTO()
@annotation.JsonSerializable()
class UpdateGradeDto {
  @annotation.JsonKey(name: 'class_module_id')
  @v.JsonKey('class_module_id')
  final String? classModuleId;

  @annotation.JsonKey(name: 'trainee_id')
  @v.JsonKey('trainee_id')
  final String? traineeId;

  @annotation.JsonKey(name: 'grade')
  @v.JsonKey('grade')
  @DoubleConverter()
  final double? grade;

  @annotation.JsonKey(name: 'grade_type')
  @v.JsonKey('grade_type')
  final String? gradeType;

  UpdateGradeDto({
    this.classModuleId,
    this.traineeId,
    this.grade,
    this.gradeType,
  });

  Map<String, dynamic> toJson() => _$UpdateGradeDtoToJson(this);

  factory UpdateGradeDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateGradeDtoFromJson(json);
}
