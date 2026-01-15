import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'update_grade_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class UpdateGradeDto {
  @annotation.JsonKey(name: 'grade_id')
  final String gradeId;

  @annotation.JsonKey(name: 'class_module_id')
  final String? classModuleId;

  @annotation.JsonKey(name: 'trainee_id')
  final String? traineeId;

  @annotation.JsonKey(name: 'grade')
  final double? grade;

  @annotation.JsonKey(name: 'grade_type')
  final String? gradeType;

  UpdateGradeDto({
    required this.gradeId,
    this.classModuleId,
    this.traineeId,
    this.grade,
    this.gradeType,
  });

  Map<String, dynamic> toJson() => _$UpdateGradeDtoToJson(this);

  factory UpdateGradeDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateGradeDtoFromJson(json);
}
