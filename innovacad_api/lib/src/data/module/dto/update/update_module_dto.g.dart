// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_module_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateModuleDto _$UpdateModuleDtoFromJson(Map<String, dynamic> json) =>
    UpdateModuleDto(
      moduleId: json['module_id'] as String,
      name: json['name'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UpdateModuleDtoToJson(UpdateModuleDto instance) =>
    <String, dynamic>{
      'module_id': instance.moduleId,
      'name': instance.name,
      'duration': instance.duration,
    };
