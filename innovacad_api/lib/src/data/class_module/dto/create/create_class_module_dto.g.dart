// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_class_module_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateClassModuleDto _$CreateClassModuleDtoFromJson(
  Map<String, dynamic> json,
) => CreateClassModuleDto(
  classId: json['class_id'] as String,
  coursesModulesId: json['courses_modules_id'] as String,
  currentDuration: (json['current_duration'] as num).toInt(),
);

Map<String, dynamic> _$CreateClassModuleDtoToJson(
  CreateClassModuleDto instance,
) => <String, dynamic>{
  'class_id': instance.classId,
  'courses_modules_id': instance.coursesModulesId,
  'current_duration': instance.currentDuration,
};
