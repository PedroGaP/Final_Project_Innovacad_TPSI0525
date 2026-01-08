import 'package:vaden/vaden.dart';

@DTO()
class CourseCreateDto {
  String identifier;
  String name;

  CourseCreateDto({required this.identifier, required this.name});
}
