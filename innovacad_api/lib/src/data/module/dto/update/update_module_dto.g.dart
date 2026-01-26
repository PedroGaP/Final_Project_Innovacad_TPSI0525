// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_module_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateModuleDto _$UpdateModuleDtoFromJson(Map<String, dynamic> json) =>
    UpdateModuleDto(
      name: json['name'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      hasComputers: json['has_computers'] as bool?,
      hasProjector: json['has_projector'] as bool?,
      hasWhiteboard: json['has_whiteboard'] as bool?,
      hasSmartboard: json['has_smartboard'] as bool?,
    );

Map<String, dynamic> _$UpdateModuleDtoToJson(UpdateModuleDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'duration': instance.duration,
      'has_computers': instance.hasComputers,
      'has_projector': instance.hasProjector,
      'has_whiteboard': instance.hasWhiteboard,
      'has_smartboard': instance.hasSmartboard,
    };
