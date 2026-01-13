import 'package:vaden/vaden.dart';

@Component()
class Availability {
  String availability_id;
  String trainer_id;
  String status;
  DateTime start_date_timestamp;
  DateTime end_date_timestamp;

  Availability({
    required this.availability_id,
    required this.trainer_id,
    required this.status,
    required this.start_date_timestamp,
    required this.end_date_timestamp,
  });
}
