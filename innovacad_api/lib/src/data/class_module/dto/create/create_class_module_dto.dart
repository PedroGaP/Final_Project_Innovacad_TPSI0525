import 'package:vaden/vaden.dart' as vaden;
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'create_class_module_dto.g.dart';

@vaden.DTO()
@annotation.JsonSerializable()
class CreateClassModuleDto {
  @annotation.JsonKey(name: 'class_id')
  @vaden.JsonKey('class_id')
  final String classId;

  @annotation.JsonKey(name: 'courses_modules_id')
  @vaden.JsonKey('courses_modules_id')
  final String coursesModulesId;

  @annotation.JsonKey(name: 'current_duration')
  @vaden.JsonKey('current_duration')
  final int currentDuration;

  CreateClassModuleDto({
    required this.classId,
    required this.coursesModulesId,
    required this.currentDuration,
  });

  Map<String, dynamic> toJson() => _$CreateClassModuleDtoToJson(this);

  factory CreateClassModuleDto.fromJson(Map<String, dynamic> json) =>
      _$CreateClassModuleDtoFromJson(json);
}
