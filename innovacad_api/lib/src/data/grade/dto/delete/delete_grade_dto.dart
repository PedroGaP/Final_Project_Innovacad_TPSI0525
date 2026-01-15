import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'delete_grade_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class DeleteGradeDto {
  @annotation.JsonKey(name: 'grade_id')
  final String gradeId;

  DeleteGradeDto({required this.gradeId});

  Map<String, dynamic> toJson() => _$DeleteGradeDtoToJson(this);

  factory DeleteGradeDto.fromJson(Map<String, dynamic> json) =>
      _$DeleteGradeDtoFromJson(json);
}
