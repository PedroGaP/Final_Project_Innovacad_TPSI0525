import 'package:vaden/vaden.dart' as vaden;
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'update_enrollment_dto.g.dart';

@vaden.DTO()
@annotation.JsonSerializable()
class UpdateEnrollmentDto {
  @annotation.JsonKey(name: 'class_id')
  @vaden.JsonKey('class_id')
  final String? classId;

  @annotation.JsonKey(name: 'trainee_id')
  @vaden.JsonKey('trainee_id')
  final String? traineeId;

  @annotation.JsonKey(name: 'final_grade')
  @vaden.JsonKey('final_grade')
  final String? finalGrade;

  double get finalGradeDouble => double.parse(finalGrade!);

  UpdateEnrollmentDto({this.classId, this.traineeId, this.finalGrade});

  Map<String, dynamic> toJson() => _$UpdateEnrollmentDtoToJson(this);

  factory UpdateEnrollmentDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateEnrollmentDtoFromJson(json);
}
