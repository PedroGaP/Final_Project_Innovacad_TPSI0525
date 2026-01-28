// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_course_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateCourseDto _$CreateCourseDtoFromJson(Map<String, dynamic> json) =>
    CreateCourseDto(
      identifier: json['identifier'] as String,
      name: json['name'] as String,
      addModulesIds: (json['add_modules_ids'] as List<dynamic>?)
          ?.map((e) => LinkModuleDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      removeCoursesModulesIds:
          (json['remove_courses_modules_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
    );

Map<String, dynamic> _$CreateCourseDtoToJson(CreateCourseDto instance) =>
    <String, dynamic>{
      'identifier': instance.identifier,
      'name': instance.name,
      'add_modules_ids': instance.addModulesIds,
      'remove_courses_modules_ids': instance.removeCoursesModulesIds,
    };
