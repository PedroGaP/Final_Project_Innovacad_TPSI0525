import 'package:vaden/vaden.dart' as vaden;
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'update_class_module_dto.g.dart';

@vaden.DTO()
@annotation.JsonSerializable()
class UpdateClassModuleDto {
  @annotation.JsonKey(name: 'class_id')
  @vaden.JsonKey('class_id')
  final String? classId;

  @annotation.JsonKey(name: 'courses_modules_id')
  @vaden.JsonKey('courses_modules_id')
  final String? coursesModulesId;

  @annotation.JsonKey(name: 'current_duration')
  @vaden.JsonKey('current_duration')
  final int? currentDuration;

  UpdateClassModuleDto({
    this.classId,
    this.coursesModulesId,
    this.currentDuration,
  });

  Map<String, dynamic> toJson() => _$UpdateClassModuleDtoToJson(this);

  factory UpdateClassModuleDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateClassModuleDtoFromJson(json);
}
