import 'package:vaden/vaden.dart';

@DTO()
class ClassModelUpdateDto {
  String course_id;
  String location;
  String identifier;
  String status;
  DateTime start_date_timestamp;
  DateTime end_date_timestamp;

  ClassModelUpdateDto({
    required this.course_id,
    required this.location,
    required this.identifier,
    required this.status,
    required this.start_date_timestamp,
    required this.end_date_timestamp,
  });
}
