import 'package:innovacad_api/src/core/core.dart';
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
  @NumberConverter()
  final int duration;

  @annotation.JsonKey(name: 'has_computers', readValue: convertBoolean)
  final bool hasComputers;

  @annotation.JsonKey(name: 'has_projector', readValue: convertBoolean)
  final bool hasProjector;

  @annotation.JsonKey(name: 'has_whiteboard', readValue: convertBoolean)
  final bool hasWhiteboard;

  @annotation.JsonKey(name: 'has_smartboard', readValue: convertBoolean)
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

  static bool convertBoolean(Map map, String s) {
    print("CONVERT BOOLEAN ($s): ${map[s]} > $map");
    if (map[s] is bool) return map[s];
    if (map[s] is int) return map[s] == null ? false : map[s] == 1;
    return false;
  }

  Map<String, dynamic> toJson() => _$OutputModuleDaoToJson(this);

  factory OutputModuleDao.fromJson(Map<String, dynamic> json) =>
      _$OutputModuleDaoFromJson(json);
}
