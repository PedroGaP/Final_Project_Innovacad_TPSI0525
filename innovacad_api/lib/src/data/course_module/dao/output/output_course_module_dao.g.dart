// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_course_module_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputCourseModuleDao _$OutputCourseModuleDaoFromJson(
  Map<String, dynamic> json,
) => OutputCourseModuleDao(
  coursesModulesId: json['courses_modules_id'] as String,
  moduleId: json['module_id'] as String,
  sequenceCourseModuleId: json['sequence_course_module_id'] as String?,
  moduleName: json['module_name'] as String?,
  duration: _$JsonConverterFromJson<Object, int>(
    json['duration'],
    const NumberConverter().fromJson,
  ),
);

Map<String, dynamic> _$OutputCourseModuleDaoToJson(
  OutputCourseModuleDao instance,
) => <String, dynamic>{
  'courses_modules_id': instance.coursesModulesId,
  'module_id': instance.moduleId,
  'sequence_course_module_id': instance.sequenceCourseModuleId,
  'module_name': instance.moduleName,
  'duration': _$JsonConverterToJson<Object, int>(
    instance.duration,
    const NumberConverter().toJson,
  ),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
