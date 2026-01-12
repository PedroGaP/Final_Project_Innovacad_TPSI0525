import 'package:vaden/vaden.dart';

@DTO()
class AvailabilityUpdateDto {
  String trainer_id;
  String status;
  DateTime start_date_timestamp;
  DateTime end_date_timestamp;

  AvailabilityUpdateDto({
    required this.trainer_id,
    required this.status,
    required this.start_date_timestamp,
    required this.end_date_timestamp,
  });
}
