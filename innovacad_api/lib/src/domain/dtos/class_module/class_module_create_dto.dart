import 'package:vaden/vaden.dart';

@DTO()
class ClassModuleCreateDto {
  String class_id;
  String courses_modules_id;
  int current_duration;

  ClassModuleCreateDto({
    required this.class_id,
    required this.courses_modules_id,
    required this.current_duration,
  });
}
