import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:vaden/vaden.dart' as v;
import 'package:json_annotation/json_annotation.dart';

part 'update_class_dto.g.dart';

@v.DTO()
@JsonSerializable()
class UpdateClassDto {
  @JsonKey(name: 'course_id')
  final String? courseId;

  @JsonKey(name: 'location')
  final String? location;

  @JsonKey(name: 'identifier')
  final String? identifier;

  @JsonEnum(valueField: 'status')
  final ClassStatusEnum? status;

  @JsonKey(name: 'start_date_timestamp')
  @DateTimeConverter()
  final DateTime? startDateTimestamp;

  @JsonKey(name: 'end_date_timestamp')
  @DateTimeConverter()
  final DateTime? endDateTimestamp;

  @JsonKey(name: 'add_modules_ids')
  final List<String>? addModulesIds;

  @JsonKey(name: 'remove_classes_modules_ids')
  final List<String>? removeClassesModulesIds;

  UpdateClassDto({
    this.courseId,
    this.location,
    this.identifier,
    this.status,
    this.startDateTimestamp,
    this.endDateTimestamp,
    this.addModulesIds,
    this.removeClassesModulesIds,
  });

  Map<String, dynamic> toJson() => _$UpdateClassDtoToJson(this);

  factory UpdateClassDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateClassDtoFromJson(json);
}
