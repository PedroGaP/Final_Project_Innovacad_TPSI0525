import 'package:json_annotation/json_annotation.dart' as annotation;
import 'package:vaden/vaden.dart' as v;

part 'finalize_grade_dto.g.dart';

@annotation.JsonSerializable()
@v.DTO()
class FinalizeGradeDto {
  @annotation.JsonKey(name: 'class_module_id')
  @v.JsonKey('class_module_id')
  final String classModuleId; 

  FinalizeGradeDto({required this.classModuleId});

  factory FinalizeGradeDto.fromJson(Map<String, dynamic> json) =>
      _$FinalizeGradeDtoFromJson(json);
  Map<String, dynamic> toJson() => _$FinalizeGradeDtoToJson(this);
}
