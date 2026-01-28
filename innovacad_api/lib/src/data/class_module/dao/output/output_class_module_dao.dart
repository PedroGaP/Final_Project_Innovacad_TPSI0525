import 'package:innovacad_api/src/core/converters/number_converter.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'output_class_module_dao.g.dart';

@DTO()
@annotation.JsonSerializable()
class OutputClassModuleDao {
  @annotation.JsonKey(name: 'courses_modules_id')
  final String coursesModulesId;

  @annotation.JsonKey(name: 'current_duration')
  @NumberConverter()
  final int currentDuration;

  OutputClassModuleDao({
    required this.coursesModulesId,
    required this.currentDuration,
  });

  Map<String, dynamic> toJson() => _$OutputClassModuleDaoToJson(this);

  factory OutputClassModuleDao.fromJson(Map<String, dynamic> json) =>
      _$OutputClassModuleDaoFromJson(json);
}
