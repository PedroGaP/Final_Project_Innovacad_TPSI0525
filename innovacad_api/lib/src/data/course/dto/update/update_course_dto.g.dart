// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_course_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateCourseDto _$UpdateCourseDtoFromJson(Map<String, dynamic> json) =>
    UpdateCourseDto(
      identifier: json['identifier'] as String?,
      name: json['name'] as String?,
      addCoursesModules: (json['add_modules_ids'] as List<dynamic>?)
          ?.map((e) => LinkModuleDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      removeCoursesModules: (json['remove_modules_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$UpdateCourseDtoToJson(UpdateCourseDto instance) =>
    <String, dynamic>{
      'identifier': instance.identifier,
      'name': instance.name,
      'add_modules_ids': instance.addCoursesModules,
      'remove_modules_ids': instance.removeCoursesModules,
    };
