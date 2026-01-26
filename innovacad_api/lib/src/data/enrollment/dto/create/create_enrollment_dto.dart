import 'package:vaden/vaden.dart' as vaden;
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'create_enrollment_dto.g.dart';

@vaden.DTO()
@annotation.JsonSerializable()
class CreateEnrollmentDto {
  @annotation.JsonKey(name: 'class_id')
  @vaden.JsonKey('class_id')
  final String classId;

  @annotation.JsonKey(name: 'trainee_id')
  @vaden.JsonKey('trainee_id')
  final String traineeId;

  @annotation.JsonKey(name: 'final_grade')
  @vaden.JsonKey('final_grade')
  final String finalGrade;

  double get finalGradeDouble => double.parse(finalGrade);

  CreateEnrollmentDto({
    required this.classId,
    required this.traineeId,
    required this.finalGrade,
  });

  Map<String, dynamic> toJson() => _$CreateEnrollmentDtoToJson(this);

  factory CreateEnrollmentDto.fromJson(Map<String, dynamic> json) =>
      _$CreateEnrollmentDtoFromJson(json);
}
