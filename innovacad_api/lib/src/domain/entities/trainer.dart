import 'package:vaden/vaden.dart';

@Component()
class Trainer {
  String id;
  String first_name;
  String last_name;
  DateTime birthday_date;

  Trainer({
    required this.id,
    required this.first_name,
    required this.last_name,
    required this.birthday_date,
  });
}
