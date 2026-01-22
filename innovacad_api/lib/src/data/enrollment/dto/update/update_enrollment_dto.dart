import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'update_enrollment_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class UpdateEnrollmentDto {
  @annotation.JsonKey(name: 'class_id')
  final String? classId;

  @annotation.JsonKey(name: 'trainee_id')
  final String? traineeId;

  @annotation.JsonKey(name: 'final_grade')
  final double? finalGrade;

  UpdateEnrollmentDto({this.classId, this.traineeId, this.finalGrade});

  Map<String, dynamic> toJson() => _$UpdateEnrollmentDtoToJson(this);

  factory UpdateEnrollmentDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateEnrollmentDtoFromJson(json);
}
