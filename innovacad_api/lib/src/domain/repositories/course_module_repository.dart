import 'package:innovacad_api/src/domain/dtos/course_module/course_module_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/course_module/course_module_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/course_module.dart';

abstract interface class ICourseModuleRepository {
  Future<List<CourseModule>?> getAll();
  Future<CourseModule?> getById(String id);
  Future<CourseModule?> create(CourseModuleCreateDto dto);
  Future<CourseModule?> update(CourseModuleUpdateDto dto);
  Future<CourseModule?> delete(String id);
}
