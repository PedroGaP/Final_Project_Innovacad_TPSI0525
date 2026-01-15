import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';

abstract class ICourseRepository {
  Future<Result<List<OutputCourseDao>>> getAll();
  Future<Result<OutputCourseDao>> getById(String id);
  Future<Result<OutputCourseDao>> create(CreateCourseDto dto);
  Future<Result<OutputCourseDao>> update(UpdateCourseDto dto);
  Future<Result<OutputCourseDao>> delete(DeleteCourseDto dto);
}
