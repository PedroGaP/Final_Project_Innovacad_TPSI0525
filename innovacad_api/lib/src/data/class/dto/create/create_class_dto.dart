import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/data/class/enum/class_status_enum.dart';
export 'package:innovacad_api/src/data/class/enum/class_status_enum.dart';
import 'package:vaden/vaden.dart' as v;
import 'package:json_annotation/json_annotation.dart' as annotation;
import 'package:json_annotation/json_annotation.dart';

part 'create_class_dto.g.dart';

@v.DTO()
@annotation.JsonSerializable()
class CreateClassDto {
  @annotation.JsonKey(name: 'course_id')
  @v.JsonKey('course_id')
  final String courseId;

  @annotation.JsonKey(name: 'location')
  final String location;

  @annotation.JsonKey(name: 'identifier')
  final String identifier;

  @annotation.JsonKey(name: 'status')
  final ClassStatusEnum status;

  @annotation.JsonKey(name: 'start_date_timestamp')
  @v.JsonKey('start_date_timestamp')
  @DateTimeConverter()
  final DateTime startDateTimestamp;

  @annotation.JsonKey(name: 'end_date_timestamp')
  @v.JsonKey('end_date_timestamp')
  @DateTimeConverter()
  final DateTime endDateTimestamp;

  @annotation.JsonKey(name: 'modules')
  @v.JsonKey('modules_ids')
  final List<String>? modulesIds;

  CreateClassDto({
    required this.courseId,
    required this.location,
    required this.identifier,
    required this.status,
    required this.startDateTimestamp,
    required this.endDateTimestamp,
    this.modulesIds,
  });

  Map<String, dynamic> toJson() => _$CreateClassDtoToJson(this);

  factory CreateClassDto.fromJson(Map<String, dynamic> json) =>
      _$CreateClassDtoFromJson(json);
}
