import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'create_module_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class CreateModuleDto {
  @annotation.JsonKey(name: 'name')
  final String name;

  @annotation.JsonKey(name: 'duration')
  final int duration;

  CreateModuleDto({required this.name, required this.duration});

  Map<String, dynamic> toJson() => _$CreateModuleDtoToJson(this);

  factory CreateModuleDto.fromJson(Map<String, dynamic> json) =>
      _$CreateModuleDtoFromJson(json);
}
