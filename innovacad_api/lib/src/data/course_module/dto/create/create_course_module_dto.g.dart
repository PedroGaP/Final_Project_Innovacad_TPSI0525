// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_course_module_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateCourseModuleDto _$CreateCourseModuleDtoFromJson(
  Map<String, dynamic> json,
) => CreateCourseModuleDto(
  courseId: json['course_id'] as String,
  moduleId: json['module_id'] as String,
  sequenceCourseModuleId: json['sequence_course_module_id'] as String?,
);

Map<String, dynamic> _$CreateCourseModuleDtoToJson(
  CreateCourseModuleDto instance,
) => <String, dynamic>{
  'course_id': instance.courseId,
  'module_id': instance.moduleId,
  'sequence_course_module_id': instance.sequenceCourseModuleId,
};
