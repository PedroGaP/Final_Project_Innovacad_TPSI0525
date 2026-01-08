import 'package:vaden/vaden.dart';

@Component()
class ClassModule {
  String classes_modules_id;
  String class_id;
  String courses_modules_id;
  int current_duration;

  ClassModule({
    required this.classes_modules_id,
    required this.class_id,
    required this.courses_modules_id,
    required this.current_duration,
  });
}
