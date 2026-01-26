import 'package:vaden/vaden.dart' as vaden;
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'update_module_dto.g.dart';

@vaden.DTO()
@annotation.JsonSerializable()
class UpdateModuleDto {
  @annotation.JsonKey(name: 'name')
  final String? name;

  @annotation.JsonKey(name: 'duration')
  final int? duration;

  @annotation.JsonKey(name: 'has_computers')
  @vaden.JsonKey('has_computers')
  final bool? hasComputers;

  @annotation.JsonKey(name: 'has_projector')
  @vaden.JsonKey('has_projector')
  final bool? hasProjector;

  @annotation.JsonKey(name: 'has_whiteboard')
  @vaden.JsonKey('has_whiteboard')
  final bool? hasWhiteboard;

  @annotation.JsonKey(name: 'has_smartboard')
  @vaden.JsonKey('has_smartboard')
  final bool? hasSmartboard;

  UpdateModuleDto({
    this.name,
    this.duration,
    required this.hasComputers,
    required this.hasProjector,
    required this.hasWhiteboard,
    required this.hasSmartboard,
  });

  Map<String, dynamic> toJson() => _$UpdateModuleDtoToJson(this);

  factory UpdateModuleDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateModuleDtoFromJson(json);
}
