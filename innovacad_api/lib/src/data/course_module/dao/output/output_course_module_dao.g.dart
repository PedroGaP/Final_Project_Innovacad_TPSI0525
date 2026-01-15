// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_course_module_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputCourseModuleDao _$OutputCourseModuleDaoFromJson(
  Map<String, dynamic> json,
) => OutputCourseModuleDao(
  coursesModulesId: json['courses_modules_id'] as String,
  courseId: json['course_id'] as String,
  moduleId: json['module_id'] as String,
  sequenceCourseModuleId: json['sequence_course_module_id'] as String?,
);

Map<String, dynamic> _$OutputCourseModuleDaoToJson(
  OutputCourseModuleDao instance,
) => <String, dynamic>{
  'courses_modules_id': instance.coursesModulesId,
  'course_id': instance.courseId,
  'module_id': instance.moduleId,
  'sequence_course_module_id': instance.sequenceCourseModuleId,
};
