// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_class_module_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateClassModuleDto _$UpdateClassModuleDtoFromJson(
  Map<String, dynamic> json,
) => UpdateClassModuleDto(
  classId: json['class_id'] as String?,
  coursesModulesId: json['courses_modules_id'] as String?,
  currentDuration: (json['current_duration'] as num?)?.toInt(),
);

Map<String, dynamic> _$UpdateClassModuleDtoToJson(
  UpdateClassModuleDto instance,
) => <String, dynamic>{
  'class_id': instance.classId,
  'courses_modules_id': instance.coursesModulesId,
  'current_duration': instance.currentDuration,
};
