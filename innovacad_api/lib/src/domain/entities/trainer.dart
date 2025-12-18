import 'package:stormberry/stormberry.dart';
import 'package:uuid/uuid.dart';

@Model()
abstract class Trainer {
  @PrimaryKey()
  Uuid get id;
  String get name;
}
