import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'delete_class_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class DeleteClassDto {
  @annotation.JsonKey(name: 'class_id')
  final String classId;

  DeleteClassDto({required this.classId});

  Map<String, dynamic> toJson() => _$DeleteClassDtoToJson(this);

  factory DeleteClassDto.fromJson(Map<String, dynamic> json) =>
      _$DeleteClassDtoFromJson(json);
}
