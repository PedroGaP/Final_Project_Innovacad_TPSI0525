import 'package:vaden/vaden.dart';

@Component()
class Grade {
  String grade_id;
  String class_module_id;
  String trainee_id;
  double grade;
  String grade_type;
  DateTime created_at;
  DateTime updated_at;

  Grade({
    required this.grade_id,
    required this.class_module_id,
    required this.trainee_id,
    required this.grade,
    required this.grade_type,
    required this.created_at,
    required this.updated_at,
  });
}
