import 'package:vaden/vaden.dart';

@DTO()
class TraineeCreateDto {
  String first_name;
  String last_name;
  DateTime birthday_date;

  TraineeCreateDto({
    required this.first_name,
    required this.last_name,
    required this.birthday_date,
  });
}
