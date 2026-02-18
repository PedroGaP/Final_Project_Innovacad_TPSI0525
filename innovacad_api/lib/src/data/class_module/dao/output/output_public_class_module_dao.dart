import 'package:innovacad_api/src/core/converters/number_converter.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'output_public_class_module_dao.g.dart';

@DTO()
@annotation.JsonSerializable()
class OutputPublicClassModuleDao {
  @annotation.JsonKey(name: 'trainer_name')
  final String? trainerName;

  @annotation.JsonKey(name: 'total_duration')
  @NumberConverter()
  final int totalDuration;

  @annotation.JsonKey(name: 'module_name')
  final String moduleName;

  @annotation.JsonKey(name: 'current_duration')
  @NumberConverter()
  final int currentDuration;

  OutputPublicClassModuleDao({
    required this.currentDuration,
    required this.moduleName,
    required this.totalDuration,
    this.trainerName,
  });

  Map<String, dynamic> toJson() => _$OutputPublicClassModuleDaoToJson(this);

  factory OutputPublicClassModuleDao.fromJson(Map<String, dynamic> json) =>
      _$OutputPublicClassModuleDaoFromJson(json);
}
