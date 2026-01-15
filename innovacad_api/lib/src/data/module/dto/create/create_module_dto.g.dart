// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_module_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateModuleDto _$CreateModuleDtoFromJson(Map<String, dynamic> json) =>
    CreateModuleDto(
      name: json['name'] as String,
      duration: (json['duration'] as num).toInt(),
    );

Map<String, dynamic> _$CreateModuleDtoToJson(CreateModuleDto instance) =>
    <String, dynamic>{'name': instance.name, 'duration': instance.duration};
