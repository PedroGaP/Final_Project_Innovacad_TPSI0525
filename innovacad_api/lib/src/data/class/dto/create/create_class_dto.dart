import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;
import 'package:json_annotation/json_annotation.dart';

part 'create_class_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class CreateClassDto {
  @annotation.JsonKey(name: 'course_id')
  final String courseId;

  @annotation.JsonKey(name: 'location')
  final String location;

  @annotation.JsonKey(name: 'identifier')
  final String identifier;

  @annotation.JsonKey(name: 'status')
  final ClassStatusEnum status;

  @annotation.JsonKey(name: 'start_date_timestamp')
  @DateTimeConverter()
  final DateTime startDateTimestamp;

  @annotation.JsonKey(name: 'end_date_timestamp')
  @DateTimeConverter()
  final DateTime endDateTimestamp;

  CreateClassDto({
    required this.courseId,
    required this.location,
    required this.identifier,
    required this.status,
    required this.startDateTimestamp,
    required this.endDateTimestamp,
  });

  Map<String, dynamic> toJson() => _$CreateClassDtoToJson(this);

  factory CreateClassDto.fromJson(Map<String, dynamic> json) =>
      _$CreateClassDtoFromJson(json);
}
