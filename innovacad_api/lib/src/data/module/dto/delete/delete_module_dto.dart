import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'delete_module_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class DeleteModuleDto {
  @annotation.JsonKey(name: 'module_id')
  final String moduleId;

  DeleteModuleDto({required this.moduleId});

  Map<String, dynamic> toJson() => _$DeleteModuleDtoToJson(this);

  factory DeleteModuleDto.fromJson(Map<String, dynamic> json) =>
      _$DeleteModuleDtoFromJson(json);
}
