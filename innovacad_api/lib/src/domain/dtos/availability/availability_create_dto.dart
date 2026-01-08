import 'package:vaden/vaden.dart';

@DTO()
class AvailabilityCreateDto {
  String trainer_id;
  String status;
  DateTime start_date_timestamp;
  DateTime end_date_timestamp;

  AvailabilityCreateDto({
    required this.trainer_id,
    required this.status,
    required this.start_date_timestamp,
    required this.end_date_timestamp,
  });
}
