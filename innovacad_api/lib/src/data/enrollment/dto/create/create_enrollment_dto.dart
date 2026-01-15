import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'create_enrollment_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class CreateEnrollmentDto {
  @annotation.JsonKey(name: 'class_id')
  final String classId;

  @annotation.JsonKey(name: 'trainee_id')
  final String traineeId;

  @annotation.JsonKey(name: 'final_grade')
  final double finalGrade;

  CreateEnrollmentDto({
    required this.classId,
    required this.traineeId,
    required this.finalGrade,
  });

  Map<String, dynamic> toJson() => _$CreateEnrollmentDtoToJson(this);

  factory CreateEnrollmentDto.fromJson(Map<String, dynamic> json) =>
      _$CreateEnrollmentDtoFromJson(json);
}
