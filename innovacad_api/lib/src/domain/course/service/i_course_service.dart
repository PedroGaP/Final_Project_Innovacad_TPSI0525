import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/course/dao/output/output_public_course_dao.dart';
import 'package:innovacad_api/src/data/data.dart';

abstract class ICourseService {
  Future<Result<List<OutputCourseDao>>> getAll();
  Future<Result<List<OutputPublicCourseDao>>> getAllPublic();
  Future<Result<OutputCourseDao>> getById(String id);
  Future<Result<OutputCourseDao>> create(CreateCourseDto dto);
  Future<Result<OutputCourseDao>> update(String id, UpdateCourseDto dto);
  Future<Result<OutputCourseDao>> delete(String id);
}
