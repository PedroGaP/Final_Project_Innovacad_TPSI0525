// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_class_module_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateClassModuleDto _$UpdateClassModuleDtoFromJson(
  Map<String, dynamic> json,
) => UpdateClassModuleDto(
  classesModulesId: json['classes_modules_id'] as String,
  classId: json['class_id'] as String?,
  coursesModulesId: json['courses_modules_id'] as String?,
  currentDuration: (json['current_duration'] as num?)?.toInt(),
);

Map<String, dynamic> _$UpdateClassModuleDtoToJson(
  UpdateClassModuleDto instance,
) => <String, dynamic>{
  'classes_modules_id': instance.classesModulesId,
  'class_id': instance.classId,
  'courses_modules_id': instance.coursesModulesId,
  'current_duration': instance.currentDuration,
};
