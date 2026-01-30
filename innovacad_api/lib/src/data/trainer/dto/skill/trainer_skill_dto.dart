import 'package:innovacad_api/src/core/core.dart';
import 'package:vaden/vaden.dart' as vaden;
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'trainer_skill_dto.g.dart';

@vaden.DTO()
@annotation.JsonSerializable()
class TrainerSkillDto {
  @vaden.JsonKey('module_id')
  @annotation.JsonKey(name: 'module_id')
  final String moduleId;

  @vaden.JsonKey('competence_level')
  @annotation.JsonKey(name: 'competence_level')
  @NumberConverter()
  final int? competenceLevel;

  TrainerSkillDto({required this.moduleId, this.competenceLevel});

  factory TrainerSkillDto.fromJson(Map<String, dynamic> json) =>
      _$TrainerSkillDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TrainerSkillDtoToJson(this);
}
