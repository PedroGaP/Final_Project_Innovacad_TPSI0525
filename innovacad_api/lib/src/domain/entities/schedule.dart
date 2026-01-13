import 'package:vaden/vaden.dart';

@Component()
class Schedule {
  String schedule_id;
  String class_module_id;
  String trainer_id;
  String availability_id;
  int? room_id;
  bool online;
  DateTime start_date_timestamp;
  DateTime end_date_timestamp;

  Schedule({
    required this.schedule_id,
    required this.class_module_id,
    required this.trainer_id,
    required this.availability_id,
    this.room_id,
    required this.online,
    required this.start_date_timestamp,
    required this.end_date_timestamp,
  });
}
