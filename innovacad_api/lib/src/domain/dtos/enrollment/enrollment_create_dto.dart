import 'package:vaden/vaden.dart';

@DTO()
class EnrollmentCreateDto {
  String class_id;
  String trainee_id;
  double final_grade;

  EnrollmentCreateDto({
    required this.class_id,
    required this.trainee_id,
    required this.final_grade,
  });
}
