import 'package:vaden/vaden.dart';

@DTO()
class CourseModuleUpdateDto {
  String course_id;
  String module_id;
  String? sequence_course_module_id;

  CourseModuleUpdateDto({
    required this.course_id,
    required this.module_id,
    this.sequence_course_module_id,
  });
}
