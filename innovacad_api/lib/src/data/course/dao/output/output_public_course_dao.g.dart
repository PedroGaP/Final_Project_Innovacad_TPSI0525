// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_public_course_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputPublicCourseDao _$OutputPublicCourseDaoFromJson(
  Map<String, dynamic> json,
) => OutputPublicCourseDao(
  identifier: json['identifier'] as String,
  name: json['name'] as String,
  area: json['area'] as String,
  coursesModules: OutputPublicCourseDao.convertModules(
    json['modules'] as List<OutputCourseModuleDao>,
  ),
);

Map<String, dynamic> _$OutputPublicCourseDaoToJson(
  OutputPublicCourseDao instance,
) => <String, dynamic>{
  'identifier': instance.identifier,
  'name': instance.name,
  'area': instance.area,
  'modules': instance.coursesModules,
};
