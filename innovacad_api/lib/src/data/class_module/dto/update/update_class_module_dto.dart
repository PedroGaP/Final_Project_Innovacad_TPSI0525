import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'update_class_module_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class UpdateClassModuleDto {
  @annotation.JsonKey(name: 'class_id')
  final String? classId;

  @annotation.JsonKey(name: 'courses_modules_id')
  final String? coursesModulesId;

  @annotation.JsonKey(name: 'current_duration')
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
