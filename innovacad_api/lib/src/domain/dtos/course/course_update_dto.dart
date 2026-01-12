import 'package:vaden/vaden.dart';

@DTO()
class CourseUpdateDto {
  String identifier;
  String name;

  CourseUpdateDto({required this.identifier, required this.name});
}
