import 'package:innovacad_api/src/core/core.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'output_grade_dao.g.dart';

@DTO()
@annotation.JsonSerializable()
class OutputGradeDao {
  @annotation.JsonKey(name: 'grade_id')
  final String gradeId;

  @annotation.JsonKey(name: 'class_module_id')
  final String classModuleId;

  @annotation.JsonKey(name: 'trainee_id')
  final String traineeId;

  @annotation.JsonKey(name: 'grade')
  @DoubleConverter()
  final double grade;

  @annotation.JsonKey(name: 'grade_type')
  final String gradeType;

  @annotation.JsonKey(name: 'created_at')
  @DateTimeConverter()
  final DateTime createdAt;

  @annotation.JsonKey(name: 'updated_at')
  @DateTimeConverter()
  final DateTime updatedAt;

  OutputGradeDao({
    required this.gradeId,
    required this.classModuleId,
    required this.traineeId,
    required this.grade,
    required this.gradeType,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => _$OutputGradeDaoToJson(this);

  factory OutputGradeDao.fromJson(Map<String, dynamic> json) =>
      _$OutputGradeDaoFromJson(json);
}
