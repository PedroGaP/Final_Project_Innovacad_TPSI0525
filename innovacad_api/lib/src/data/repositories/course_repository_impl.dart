import 'package:innovacad_api/src/domain/dtos/course/course_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/course/course_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/course.dart';
import 'package:innovacad_api/src/domain/repositories/course_repository.dart';
import 'package:vaden/vaden.dart';

@Repository()
class CourseRepositoryImpl implements ICourseRepository {
  @override
  Future<List<Course>?> getAll() {
    throw UnimplementedError();
  }

  @override
  Future<Course?> getById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Course?> create(CourseCreateDto dto) {
    throw UnimplementedError();
  }

  @override
  Future<Course?> update(CourseUpdateDto dto) {
    throw UnimplementedError();
  }

  @override
  Future<Course?> delete(String id) {
    throw UnimplementedError();
  }
}
