import 'package:json_annotation/json_annotation.dart';
import 'package:vaden/vaden.dart' as v;

part 'link_module_dto.g.dart';

@v.DTO()
@JsonSerializable()
class LinkModuleDto {
  final String moduleId;
  final String? sequenceModuleId;

  LinkModuleDto({required this.moduleId, this.sequenceModuleId});

  Map<String, dynamic> toJson() => _$LinkModuleDtoToJson(this);
  factory LinkModuleDto.fromJson(Map<String, dynamic> json) =>
      _$LinkModuleDtoFromJson(json);
}
