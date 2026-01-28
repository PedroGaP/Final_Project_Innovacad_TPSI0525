// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_course_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputCourseDao _$OutputCourseDaoFromJson(Map<String, dynamic> json) =>
    OutputCourseDao(
      courseId: json['course_id'] as String,
      identifier: json['identifier'] as String,
      name: json['name'] as String,
      coursesModules: (json['modules'] as List<dynamic>?)
          ?.map(
            (e) => OutputCourseModuleDao.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$OutputCourseDaoToJson(OutputCourseDao instance) =>
    <String, dynamic>{
      'course_id': instance.courseId,
      'identifier': instance.identifier,
      'name': instance.name,
      'modules': instance.coursesModules,
    };
