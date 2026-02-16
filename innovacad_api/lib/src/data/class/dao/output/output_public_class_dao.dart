import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/class_module/dao/output/output_public_class_module_dao.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;
import 'package:json_annotation/json_annotation.dart';

part 'output_public_class_dao.g.dart';

@DTO()
@annotation.JsonSerializable()
class OutputPublicClassDao {
  @annotation.JsonKey(name: 'course_identifier')
  final String courseIdentifier;

  @annotation.JsonKey(name: 'location')
  final String location;

  @annotation.JsonKey(name: 'identifier')
  final String identifier;

  @annotation.JsonEnum(valueField: 'status')
  final ClassStatusEnum status;

  @annotation.JsonKey(name: 'start_date_timestamp')
  @DateTimeConverter()
  final DateTime startDateTimestamp;

  @annotation.JsonKey(name: 'end_date_timestamp')
  @DateTimeConverter()
  final DateTime endDateTimestamp;

  @annotation.JsonKey(name: 'modules', fromJson: convertModules)
  //@ModuleListConverter()
  final List<OutputPublicClassModuleDao> modules;

  OutputPublicClassDao({
    required this.location,
    required this.identifier,
    required this.status,
    required this.startDateTimestamp,
    required this.endDateTimestamp,
    required this.modules,
    required this.courseIdentifier,
  });

  static convertModules(List<OutputPublicClassModuleDao> modules) {
    return modules
        .map((e) => OutputPublicClassModuleDao.fromJson(e.toJson()))
        .toList();
  }

  Map<String, dynamic> toJson() => _$OutputPublicClassDaoToJson(this);

  factory OutputPublicClassDao.fromJson(Map<String, dynamic> json) =>
      _$OutputPublicClassDaoFromJson(json);
}
