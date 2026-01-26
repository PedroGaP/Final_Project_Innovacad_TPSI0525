import 'package:vaden/vaden.dart' as vaden;
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'create_module_dto.g.dart';

@vaden.DTO()
@annotation.JsonSerializable()
class CreateModuleDto {
  @annotation.JsonKey(name: 'name')
  final String name;

  @annotation.JsonKey(name: 'duration')
  final int duration;

  @annotation.JsonKey(name: 'has_computers')
  @vaden.JsonKey('has_computers')
  final bool hasComputers;

  @annotation.JsonKey(name: 'has_projector')
  @vaden.JsonKey('has_projector')
  final bool hasProjector;

  @annotation.JsonKey(name: 'has_whiteboard')
  @vaden.JsonKey('has_whiteboard')
  final bool hasWhiteboard;

  @annotation.JsonKey(name: 'has_smartboard')
  @vaden.JsonKey('has_smartboard')
  final bool hasSmartboard;

  CreateModuleDto({
    required this.name,
    required this.duration,
    required this.hasComputers,
    required this.hasProjector,
    required this.hasWhiteboard,
    required this.hasSmartboard,
  });

  Map<String, dynamic> toJson() => _$CreateModuleDtoToJson(this);

  factory CreateModuleDto.fromJson(Map<String, dynamic> json) =>
      _$CreateModuleDtoFromJson(json);
}
