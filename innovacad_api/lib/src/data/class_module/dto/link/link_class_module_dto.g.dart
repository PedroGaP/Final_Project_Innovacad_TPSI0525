// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_class_module_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LinkClassModuleDto _$LinkClassModuleDtoFromJson(Map<String, dynamic> json) =>
    LinkClassModuleDto(
      courseModuleId: json['course_module_id'] as String,
      trainerId: json['trainer_id'] as String?,
    );

Map<String, dynamic> _$LinkClassModuleDtoToJson(LinkClassModuleDto instance) =>
    <String, dynamic>{
      'course_module_id': instance.courseModuleId,
      'trainer_id': instance.trainerId,
    };
