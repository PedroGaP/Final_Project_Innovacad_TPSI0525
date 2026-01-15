import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'delete_enrollment_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class DeleteEnrollmentDto {
  @annotation.JsonKey(name: 'enrollment_id')
  final String enrollmentId;

  DeleteEnrollmentDto({required this.enrollmentId});

  Map<String, dynamic> toJson() => _$DeleteEnrollmentDtoToJson(this);

  factory DeleteEnrollmentDto.fromJson(Map<String, dynamic> json) =>
      _$DeleteEnrollmentDtoFromJson(json);
}
