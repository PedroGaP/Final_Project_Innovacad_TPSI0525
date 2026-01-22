import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;
import 'package:json_annotation/json_annotation.dart';

part 'update_class_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class UpdateClassDto {
  @annotation.JsonKey(name: 'course_id')
  final String? courseId;

  @annotation.JsonKey(name: 'location')
  final String? location;

  @annotation.JsonKey(name: 'identifier')
  final String? identifier;

  @annotation.JsonKey(name: 'status')
  final ClassStatusEnum? status;

  @annotation.JsonKey(name: 'start_date_timestamp')
  @DateTimeConverter()
  final DateTime? startDateTimestamp;

  @annotation.JsonKey(name: 'end_date_timestamp')
  @DateTimeConverter()
  final DateTime? endDateTimestamp;

  UpdateClassDto({
    this.courseId,
    this.location,
    this.identifier,
    this.status,
    this.startDateTimestamp,
    this.endDateTimestamp,
  });

  Map<String, dynamic> toJson() => _$UpdateClassDtoToJson(this);

  factory UpdateClassDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateClassDtoFromJson(json);
}
