import 'package:innovacad_api/src/domain/dtos/course/course_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/course/course_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/course.dart';
import 'package:innovacad_api/src/domain/repositories/course_repository.dart';
import 'package:innovacad_api/src/domain/services/course_service.dart';
import 'package:vaden/vaden.dart';

@Service()
class CourseServiceImpl implements ICourseService {
  final ICourseRepository _repository;

  CourseServiceImpl(this._repository);

  @override
  Future<List<Course>?> getAll() async {
    return await _repository.getAll();
  }

  @override
  Future<Course?> getById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<Course?> create(CourseCreateDto dto) async {
    return await _repository.create(dto);
  }

  @override
  Future<Course?> update(CourseUpdateDto dto) async {
    return await _repository.update(dto);
  }

  @override
  Future<Course?> delete(String id) async {
    return await _repository.delete(id);
  }
}
