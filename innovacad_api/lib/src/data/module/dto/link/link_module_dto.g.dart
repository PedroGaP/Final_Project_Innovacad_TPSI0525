// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_module_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LinkModuleDto _$LinkModuleDtoFromJson(Map<String, dynamic> json) =>
    LinkModuleDto(
      moduleId: json['moduleId'] as String,
      sequenceModuleId: json['sequenceModuleId'] as String?,
    );

Map<String, dynamic> _$LinkModuleDtoToJson(LinkModuleDto instance) =>
    <String, dynamic>{
      'moduleId': instance.moduleId,
      'sequenceModuleId': instance.sequenceModuleId,
    };
