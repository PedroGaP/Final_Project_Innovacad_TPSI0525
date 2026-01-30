// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_class_module_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputClassModuleDao _$OutputClassModuleDaoFromJson(
  Map<String, dynamic> json,
) => OutputClassModuleDao(
  coursesModulesId: json['courses_modules_id'] as String,
  classesModulesId: json['classes_modules_id'] as String,
  currentDuration: const NumberConverter().fromJson(
    json['current_duration'] as Object,
  ),
);

Map<String, dynamic> _$OutputClassModuleDaoToJson(
  OutputClassModuleDao instance,
) => <String, dynamic>{
  'courses_modules_id': instance.coursesModulesId,
  'classes_modules_id': instance.classesModulesId,
  'current_duration': const NumberConverter().toJson(instance.currentDuration),
};
