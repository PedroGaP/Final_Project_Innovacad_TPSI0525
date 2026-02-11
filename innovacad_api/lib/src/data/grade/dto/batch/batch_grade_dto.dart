import 'package:json_annotation/json_annotation.dart' as annotation;
import 'package:vaden/vaden.dart' as v;

part 'batch_grade_dto.g.dart';

@annotation.JsonSerializable()
@v.DTO()
class BatchGradeDto {
  @annotation.JsonKey(name: 'class_module_id')
  @v.JsonKey('class_module_id')
  final String classModuleId;

  final List<GradeItemDto> grades;

  BatchGradeDto({required this.classModuleId, required this.grades});

  factory BatchGradeDto.fromJson(Map<String, dynamic> json) =>
      _$BatchGradeDtoFromJson(json);
  Map<String, dynamic> toJson() => _$BatchGradeDtoToJson(this);
}

@annotation.JsonSerializable()
@v.DTO()
class GradeItemDto {
  @annotation.JsonKey(name: 'trainee_id')
  @v.JsonKey('trainee_id')
  final String traineeId;

  final double grade;

  @annotation.JsonKey(name: 'grade_type')
  @v.JsonKey('grade_type')
  final String gradeType;

  GradeItemDto({
    required this.traineeId,
    required this.grade,
    required this.gradeType,
  });

  factory GradeItemDto.fromJson(Map<String, dynamic> json) =>
      _$GradeItemDtoFromJson(json);
  Map<String, dynamic> toJson() => _$GradeItemDtoToJson(this);
}
