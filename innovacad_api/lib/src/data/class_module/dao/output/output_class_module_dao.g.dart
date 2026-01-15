// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_class_module_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputClassModuleDao _$OutputClassModuleDaoFromJson(
  Map<String, dynamic> json,
) => OutputClassModuleDao(
  classesModulesId: json['classes_modules_id'] as String,
  classId: json['class_id'] as String,
  coursesModulesId: json['courses_modules_id'] as String,
  currentDuration: (json['current_duration'] as num).toInt(),
);

Map<String, dynamic> _$OutputClassModuleDaoToJson(
  OutputClassModuleDao instance,
) => <String, dynamic>{
  'classes_modules_id': instance.classesModulesId,
  'class_id': instance.classId,
  'courses_modules_id': instance.coursesModulesId,
  'current_duration': instance.currentDuration,
};
