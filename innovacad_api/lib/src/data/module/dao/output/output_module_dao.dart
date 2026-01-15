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

  OutputModuleDao({
    required this.moduleId,
    required this.name,
    required this.duration,
  });

  Map<String, dynamic> toJson() => _$OutputModuleDaoToJson(this);

  factory OutputModuleDao.fromJson(Map<String, dynamic> json) =>
      _$OutputModuleDaoFromJson(json);
}
