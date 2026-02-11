// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_skill_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainerSkillDto _$TrainerSkillDtoFromJson(Map<String, dynamic> json) =>
    TrainerSkillDto(
      moduleId: json['module_id'] as String,
      competenceLevel: const NumberConverter().fromJson(
        json['competence_level'],
      ),
    );

Map<String, dynamic> _$TrainerSkillDtoToJson(TrainerSkillDto instance) =>
    <String, dynamic>{
      'module_id': instance.moduleId,
      'competence_level': _$JsonConverterToJson<Object?, int>(
        instance.competenceLevel,
        const NumberConverter().toJson,
      ),
    };

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
