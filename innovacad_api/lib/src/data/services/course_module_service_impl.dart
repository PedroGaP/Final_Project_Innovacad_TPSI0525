import 'package:innovacad_api/src/data/repositories/course_module_repository_impl.dart';
import 'package:innovacad_api/src/domain/dtos/course_module/course_module_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/course_module/course_module_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/course_module.dart';
import 'package:innovacad_api/src/domain/services/course_module_service.dart';
import 'package:vaden/vaden.dart';

@Service()
class CourseModuleServiceImpl implements ICourseModuleService {
  final CourseModuleRepositoryImpl _repository;

  CourseModuleServiceImpl(this._repository);

  @override
  Future<List<CourseModule>?> getAll() async {
    return await _repository.getAll();
  }

  @override
  Future<CourseModule?> getById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<CourseModule?> create(CourseModuleCreateDto dto) async {
    return await _repository.create(dto);
  }

  @override
  Future<CourseModule?> update(CourseModuleUpdateDto dto) async {
    return await _repository.update(dto);
  }

  @override
  Future<CourseModule?> delete(String id) async {
    return await _repository.delete(id);
  }
}
