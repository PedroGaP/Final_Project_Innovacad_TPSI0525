// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_course_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateCourseDto _$UpdateCourseDtoFromJson(Map<String, dynamic> json) =>
    UpdateCourseDto(
      courseId: json['course_id'] as String,
      identifier: json['identifier'] as String?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$UpdateCourseDtoToJson(UpdateCourseDto instance) =>
    <String, dynamic>{
      'course_id': instance.courseId,
      'identifier': instance.identifier,
      'name': instance.name,
    };
