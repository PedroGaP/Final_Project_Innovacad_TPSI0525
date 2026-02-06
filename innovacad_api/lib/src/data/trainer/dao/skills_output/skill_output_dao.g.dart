// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill_output_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SkillOutputDao _$SkillOutputDaoFromJson(Map<String, dynamic> json) =>
    SkillOutputDao(
      name: json['name'] as String,
      competenceLevel: (json['competence_level'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SkillOutputDaoToJson(SkillOutputDao instance) =>
    <String, dynamic>{
      'name': instance.name,
      'competence_level': instance.competenceLevel,
    };
