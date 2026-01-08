import 'package:innovacad_api/src/domain/dtos/course_module/course_module_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/course_module/course_module_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/course_module.dart';
import 'package:innovacad_api/src/domain/repositories/course_module_repository.dart';
import 'package:vaden/vaden.dart';

@Repository()
class CourseModuleRepositoryImpl implements ICourseModuleRepository {
  @override
  Future<List<CourseModule>?> getAll() {
    throw UnimplementedError();
  }

  @override
  Future<CourseModule?> getById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<CourseModule?> create(CourseModuleCreateDto dto) {
    throw UnimplementedError();
  }

  @override
  Future<CourseModule?> update(CourseModuleUpdateDto dto) {
    throw UnimplementedError();
  }

  @override
  Future<CourseModule?> delete(String id) {
    throw UnimplementedError();
  }
}
