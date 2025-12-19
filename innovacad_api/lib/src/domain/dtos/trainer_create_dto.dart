import 'package:vaden/vaden.dart';

@DTO()
class TrainerCreateDto {
  String first_name;
  String last_name;
  DateTime birthday_date;

  TrainerCreateDto({
    required this.first_name,
    required this.last_name,
    required this.birthday_date,
  });
}
