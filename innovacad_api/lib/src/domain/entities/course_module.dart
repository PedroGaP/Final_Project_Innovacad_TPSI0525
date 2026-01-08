import 'package:vaden/vaden.dart';

@Component()
class CourseModule {
  String courses_modules_id;
  String course_id;
  String module_id;
  String? sequence_course_module_id;

  CourseModule({
    required this.courses_modules_id,
    required this.course_id,
    required this.module_id,
    this.sequence_course_module_id,
  });
}
