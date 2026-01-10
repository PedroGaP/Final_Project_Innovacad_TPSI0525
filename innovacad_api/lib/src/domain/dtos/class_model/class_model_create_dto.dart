import 'package:innovacad_api/src/domain/entities/class_model.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart';

part 'class_model_create_dto.g.dart';

@DTO()
@JsonSerializable()
class ClassModelCreateDto {
  String course_id;
  String location;
  String identifier;
  ClassStatusEnum status;
  DateTime start_date_timestamp;
  DateTime end_date_timestamp;

  ClassModelCreateDto({
    required this.course_id,
    required this.location,
    required this.identifier,
    required this.status,
    required this.start_date_timestamp,
    required this.end_date_timestamp,
  });

  Map<String, dynamic> toJson() => _$ClassModelCreateDtoToJson(this);
}
