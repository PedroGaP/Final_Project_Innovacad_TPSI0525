import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'skill_output_dao.g.dart';

@DTO()
@annotation.JsonSerializable()
class SkillOutputDao {
  @annotation.JsonKey(name: 'name')
  final String name;

  @annotation.JsonKey(name: 'competence_level')
  final int? competenceLevel;

  SkillOutputDao({required this.name, this.competenceLevel});

  factory SkillOutputDao.fromJson(Map<String, dynamic> json) =>
      _$SkillOutputDaoFromJson(json);

  Map<String, dynamic> toJson() => _$SkillOutputDaoToJson(this);
}
