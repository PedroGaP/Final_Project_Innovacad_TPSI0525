import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';

abstract class ICourseModuleRepository {
  Future<Result<List<OutputCourseModuleDao>>> getAll();
  Future<Result<OutputCourseModuleDao>> getById(String id);
  Future<Result<OutputCourseModuleDao>> create(CreateCourseModuleDto dto);
  Future<Result<OutputCourseModuleDao>> update(
    String id,
    UpdateCourseModuleDto dto,
  );
  Future<Result<OutputCourseModuleDao>> delete(String id);
}
