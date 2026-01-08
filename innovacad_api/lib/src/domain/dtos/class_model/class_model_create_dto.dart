import 'package:vaden/vaden.dart';

@DTO()
class ClassModelCreateDto {
  String course_id;
  String location;
  String identifier;
  String status;
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
}
