import 'package:vaden/vaden.dart';

@DTO()
class GradeUpdateDto {
  String class_module_id;
  String trainee_id;
  double grade;
  String grade_type;

  GradeUpdateDto({
    required this.class_module_id,
    required this.trainee_id,
    required this.grade,
    required this.grade_type,
  });
}
