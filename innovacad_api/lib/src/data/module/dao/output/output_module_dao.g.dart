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
    );

Map<String, dynamic> _$OutputModuleDaoToJson(OutputModuleDao instance) =>
    <String, dynamic>{
      'module_id': instance.moduleId,
      'name': instance.name,
      'duration': instance.duration,
    };
