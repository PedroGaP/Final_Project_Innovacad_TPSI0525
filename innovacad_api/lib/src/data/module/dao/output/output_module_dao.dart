import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'output_module_dao.g.dart';

@DTO()
@annotation.JsonSerializable()
class OutputModuleDao {
  @annotation.JsonKey(name: 'module_id')
  final String moduleId;

  @annotation.JsonKey(name: 'name')
  final String name;

  @annotation.JsonKey(name: 'duration')
  final int duration;

  @annotation.JsonKey(name: 'has_computers')
  final bool hasComputers;

  @annotation.JsonKey(name: 'has_projector')
  final bool hasProjector;

  @annotation.JsonKey(name: 'has_whiteboard')
  final bool hasWhiteboard;

  @annotation.JsonKey(name: 'has_smartboard')
  final bool hasSmartboard;

  OutputModuleDao({
    required this.moduleId,
    required this.name,
    required this.duration,
    required this.hasComputers,
    required this.hasProjector,
    required this.hasWhiteboard,
    required this.hasSmartboard,
  });

  Map<String, dynamic> toJson() => _$OutputModuleDaoToJson(this);

  factory OutputModuleDao.fromJson(Map<String, dynamic> json) =>
      _$OutputModuleDaoFromJson(json);
}
