import 'package:json_annotation/json_annotation.dart';
import 'package:vaden/vaden.dart' as v;

part 'link_module_dto.g.dart';

@v.DTO()
@JsonSerializable()
class LinkModuleDto {
  @JsonKey(name: 'module_id')
  @v.JsonKey('module_id')
  final String moduleId;

  @JsonKey(name: 'sequence_course_module_id')
  @v.JsonKey('sequence_course_module_id')
  final String? sequenceModuleId;

  LinkModuleDto({required this.moduleId, this.sequenceModuleId});

  Map<String, dynamic> toJson() => _$LinkModuleDtoToJson(this);
  factory LinkModuleDto.fromJson(Map<String, dynamic> json) =>
      _$LinkModuleDtoFromJson(json);
}
