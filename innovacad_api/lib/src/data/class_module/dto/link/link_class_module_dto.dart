import 'package:json_annotation/json_annotation.dart' as annotation;
import 'package:vaden/vaden.dart' as v;

part 'link_class_module_dto.g.dart';

@annotation.JsonSerializable()
@v.DTO()
class LinkClassModuleDto {
  @v.JsonKey('course_module_id')
  @annotation.JsonKey(name: 'course_module_id')
  final String courseModuleId;

  @v.JsonKey('trainer_id')
  @annotation.JsonKey(name: 'trainer_id')
  final String? trainerId;

  LinkClassModuleDto({required this.courseModuleId, this.trainerId});

  factory LinkClassModuleDto.fromJson(Map<String, dynamic> json) =>
      _$LinkClassModuleDtoFromJson(json);
  Map<String, dynamic> toJson() => _$LinkClassModuleDtoToJson(this);
}
