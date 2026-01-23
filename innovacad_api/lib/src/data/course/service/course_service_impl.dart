import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/course/repository/i_course_repository.dart';
import 'package:innovacad_api/src/domain/course/service/i_course_service.dart';
import 'package:vaden/vaden.dart';

@Service()
class CourseServiceImpl implements ICourseService {
  final ICourseRepository _repository;

  CourseServiceImpl(this._repository);

  @override
  Future<Result<List<OutputCourseDao>>> getAll() async =>
      await _repository.getAll();

  @override
  Future<Result<OutputCourseDao>> getById(String id) async =>
      await _repository.getById(id);

  @override
  Future<Result<OutputCourseDao>> create(CreateCourseDto dto) async =>
      await _repository.create(dto);

  @override
  Future<Result<OutputCourseDao>> update(
    String id,
    UpdateCourseDto dto,
  ) async => await _repository.update(id, dto);

  @override
  Future<Result<OutputCourseDao>> delete(String id) async =>
      await _repository.delete(id);
}
