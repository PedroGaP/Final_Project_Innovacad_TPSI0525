import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/course_module/repository/i_course_module_repository.dart';
import 'package:innovacad_api/src/domain/course_module/service/i_course_module_service.dart';
import 'package:vaden/vaden.dart';

@Service()
class CourseModuleServiceImpl implements ICourseModuleService {
  final ICourseModuleRepository _repository;

  CourseModuleServiceImpl(this._repository);

  @override
  Future<Result<List<OutputCourseModuleDao>>> getAll() async =>
      _repository.getAll();

  @override
  Future<Result<OutputCourseModuleDao>> getById(String id) async =>
      _repository.getById(id);

  @override
  Future<Result<OutputCourseModuleDao>> create(
    CreateCourseModuleDto dto,
  ) async => _repository.create(dto);

  @override
  Future<Result<OutputCourseModuleDao>> update(
    String id,
    UpdateCourseModuleDto dto,
  ) async => _repository.update(id, dto);

  @override
  Future<Result<OutputCourseModuleDao>> delete(String id) async =>
      _repository.delete(id);
}
