import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'output_enrollment_dao.g.dart';

@DTO()
@annotation.JsonSerializable()
class OutputEnrollmentDao {
  @annotation.JsonKey(name: 'enrollment_id')
  final String enrollmentId;

  @annotation.JsonKey(name: 'class_id')
  final String classId;

  @annotation.JsonKey(name: 'trainee_id')
  final String traineeId;

  @annotation.JsonKey(name: 'final_grade')
  final String finalGrade;

  OutputEnrollmentDao({
    required this.enrollmentId,
    required this.classId,
    required this.traineeId,
    required this.finalGrade,
  });

  Map<String, dynamic> toJson() => _$OutputEnrollmentDaoToJson(this);

  factory OutputEnrollmentDao.fromJson(Map<String, dynamic> json) =>
      _$OutputEnrollmentDaoFromJson(json);
}
