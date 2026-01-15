import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'delete_class_module_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class DeleteClassModuleDto {
  @annotation.JsonKey(name: 'classes_modules_id')
  final String classesModulesId;

  DeleteClassModuleDto({required this.classesModulesId});

  Map<String, dynamic> toJson() => _$DeleteClassModuleDtoToJson(this);

  factory DeleteClassModuleDto.fromJson(Map<String, dynamic> json) =>
      _$DeleteClassModuleDtoFromJson(json);
}
