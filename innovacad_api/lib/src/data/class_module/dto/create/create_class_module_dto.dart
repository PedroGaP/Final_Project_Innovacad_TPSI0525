import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'create_class_module_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class CreateClassModuleDto {
  @annotation.JsonKey(name: 'class_id')
  final String classId;

  @annotation.JsonKey(name: 'courses_modules_id')
  final String coursesModulesId;

  @annotation.JsonKey(name: 'current_duration')
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
