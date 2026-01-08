import 'package:vaden/vaden.dart';

@Component()
class Enrollment {
  String enrollment_id;
  String class_id;
  String trainee_id;
  double final_grade;

  Enrollment({
    required this.enrollment_id,
    required this.class_id,
    required this.trainee_id,
    required this.final_grade,
  });
}
