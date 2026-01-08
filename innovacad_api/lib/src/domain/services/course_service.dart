import 'package:innovacad_api/src/domain/dtos/course/course_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/course/course_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/course.dart';

abstract interface class ICourseService {
  Future<List<Course>?> getAll();
  Future<Course?> getById(String id);
  Future<Course?> create(CourseCreateDto dto);
  Future<Course?> update(CourseUpdateDto dto);
  Future<Course?> delete(String id);
}
