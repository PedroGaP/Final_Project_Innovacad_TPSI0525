import 'package:innovacad_api/src/domain/entities/class_model.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart';

part 'class_model_update_dto.g.dart';

@DTO()
@JsonSerializable()
class ClassModelUpdateDto {
  String? course_id;
  String? location;
  String? identifier;
  ClassStatusEnum? status;
  DateTime? start_date_timestamp;
  DateTime? end_date_timestamp;

  ClassModelUpdateDto({
    this.course_id,
    this.location,
    this.identifier,
    this.status,
    this.start_date_timestamp,
    this.end_date_timestamp,
  });

  Map<String, dynamic> toJson() => _$ClassModelUpdateDtoToJson(this);
}
