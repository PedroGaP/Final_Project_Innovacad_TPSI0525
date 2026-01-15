import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'update_module_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class UpdateModuleDto {
  @annotation.JsonKey(name: 'module_id')
  final String moduleId;

  @annotation.JsonKey(name: 'name')
  final String? name;

  @annotation.JsonKey(name: 'duration')
  final int? duration;

  UpdateModuleDto({
    required this.moduleId,
    this.name,
    this.duration,
  });

  Map<String, dynamic> toJson() => _$UpdateModuleDtoToJson(this);

  factory UpdateModuleDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateModuleDtoFromJson(json);
}
