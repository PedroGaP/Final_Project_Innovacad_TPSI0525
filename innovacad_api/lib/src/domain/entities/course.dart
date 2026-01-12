import 'package:vaden/vaden.dart';

@Component()
class Course {
  String course_id;
  String identifier;
  String name;

  Course({
    required this.course_id,
    required this.identifier,
    required this.name,
  });
}
