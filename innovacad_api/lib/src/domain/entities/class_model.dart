import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart';

part 'class_model.g.dart';

class DateTimeConverter implements JsonConverter<DateTime, Object> {
  const DateTimeConverter();

  @override
  DateTime fromJson(Object json) {
    if (json is DateTime) return json;
    if (json is String)
      return DateTime.fromMillisecondsSinceEpoch(int.parse(json));

    throw ArgumentError('Expected String or DateTime, got ${json.runtimeType}');
  }

  @override
  String toJson(DateTime object) {
    return object.millisecondsSinceEpoch.toString();
  }
}

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
