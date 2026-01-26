// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_module_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputModuleDao _$OutputModuleDaoFromJson(Map<String, dynamic> json) =>
    OutputModuleDao(
      moduleId: json['module_id'] as String,
      name: json['name'] as String,
      duration: (json['duration'] as num).toInt(),
      hasComputers: json['has_computers'] as bool,
      hasProjector: json['has_projector'] as bool,
      hasWhiteboard: json['has_whiteboard'] as bool,
      hasSmartboard: json['has_smartboard'] as bool,
    );

Map<String, dynamic> _$OutputModuleDaoToJson(OutputModuleDao instance) =>
    <String, dynamic>{
      'module_id': instance.moduleId,
      'name': instance.name,
      'duration': instance.duration,
      'has_computers': instance.hasComputers,
      'has_projector': instance.hasProjector,
      'has_whiteboard': instance.hasWhiteboard,
      'has_smartboard': instance.hasSmartboard,
    };
