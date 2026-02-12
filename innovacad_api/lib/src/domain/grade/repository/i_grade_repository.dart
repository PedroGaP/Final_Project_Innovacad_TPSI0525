import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/data/grade/dto/batch/batch_grade_dto.dart';

abstract class IGradeRepository {
  Future<Result<List<OutputGradeDao>>> getAll();
  Future<Result<OutputGradeDao>> getById(String id);
  Future<Result<List<OutputGradeDao>>> getByClassModule(String classModuleId);
  Future<Result<OutputGradeDao>> create(CreateGradeDto dto);
  Future<Result<bool>> batchUpsert(BatchGradeDto dto, ExtendedUserDetails user);
  Future<Result<OutputGradeDao>> update(String id, UpdateGradeDto dto);
  Future<Result<OutputGradeDao>> delete(String id);
  Future<bool> canEditGrades({
    required String userId,
    required String userRole,
    required String classModuleId,
  });
  Future<bool> canFinalizeGrades({
    required String userId,
    required String userRole,
    required String classModuleId,
  });
  Future<Result<bool>> finalizeGrades(String classModuleId);
  Future<Result<List<OutputGradeDao>>> fetchGradesByTraineeId(String traineeId);
}
