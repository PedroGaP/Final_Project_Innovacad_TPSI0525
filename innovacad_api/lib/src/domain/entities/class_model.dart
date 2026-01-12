import 'package:innovacad_api/src/domain/converters/date_time_converter.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart';

part 'class_model.g.dart';

enum ClassStatusEnum {
  @JsonValue('ongoing')
  ongoing,

  @JsonValue('starting')
  starting,

  @JsonValue('finished')
  finished,
}

@Component()
@JsonSerializable()
class ClassModel {
  String class_id;
  String course_id;
  String location;
  String identifier;
  ClassStatusEnum status;
  @DateTimeConverter()
  DateTime start_date_timestamp;
  @DateTimeConverter()
  DateTime end_date_timestamp;

  ClassModel({
    required this.class_id,
    required this.course_id,
    required this.location,
    required this.identifier,
    required this.status,
    required this.start_date_timestamp,
    required this.end_date_timestamp,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) =>
      _$ClassModelFromJson(json);

  Map<String, dynamic> toJson() => _$ClassModelToJson(this);
}
