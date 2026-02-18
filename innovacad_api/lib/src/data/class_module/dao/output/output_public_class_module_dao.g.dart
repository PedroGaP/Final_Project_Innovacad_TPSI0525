// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_public_class_module_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputPublicClassModuleDao _$OutputPublicClassModuleDaoFromJson(
  Map<String, dynamic> json,
) => OutputPublicClassModuleDao(
  currentDuration: const NumberConverter().fromJson(json['current_duration']),
  moduleName: json['module_name'] as String,
  totalDuration: const NumberConverter().fromJson(json['total_duration']),
  trainerName: json['trainer_name'] as String?,
);

Map<String, dynamic> _$OutputPublicClassModuleDaoToJson(
  OutputPublicClassModuleDao instance,
) => <String, dynamic>{
  'trainer_name': instance.trainerName,
  'total_duration': const NumberConverter().toJson(instance.totalDuration),
  'module_name': instance.moduleName,
  'current_duration': const NumberConverter().toJson(instance.currentDuration),
};
