import 'package:vaden/vaden.dart';

@DTO()
class CourseModuleCreateDto {
  String course_id;
  String module_id;
  String? sequence_course_module_id;

  CourseModuleCreateDto({
    required this.course_id,
    required this.module_id,
    this.sequence_course_module_id,
  });
}
