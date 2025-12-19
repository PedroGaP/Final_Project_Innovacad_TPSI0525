import 'package:stormberry/stormberry.dart';
import 'package:uuid/uuid.dart';

@Model()
abstract class Trainer {
  @PrimaryKey()
  Uuid get id;
  String get first_name;
  String get last_name;
  DateTime get birthday_date;
}
