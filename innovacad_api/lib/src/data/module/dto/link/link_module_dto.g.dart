// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_module_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LinkModuleDto _$LinkModuleDtoFromJson(Map<String, dynamic> json) =>
    LinkModuleDto(
      moduleId: json['module_id'] as String,
      sequenceModuleId: json['sequence_course_module_id'] as String?,
    );

Map<String, dynamic> _$LinkModuleDtoToJson(LinkModuleDto instance) =>
    <String, dynamic>{
      'module_id': instance.moduleId,
      'sequence_course_module_id': instance.sequenceModuleId,
    };
