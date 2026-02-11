import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/data/grade/dto/batch/batch_grade_dto.dart';
import 'package:innovacad_api/src/data/grade/dto/finalize/finalize_grade_dto.dart';

abstract class IGradeService {
  Future<Result<List<OutputGradeDao>>> getAll();
  Future<Result<OutputGradeDao>> getById(String id);
  Future<Result<OutputGradeDao>> create(CreateGradeDto dto);
  Future<Result<OutputGradeDao>> update(String id, UpdateGradeDto dto);
  Future<Result<OutputGradeDao>> delete(String id);
  Future<Result<bool>> batchUpsert(BatchGradeDto dto, ExtendedUserDetails user);
  Future<Result<bool>> finalizeGrades(
    FinalizeGradeDto dto,
    ExtendedUserDetails user,
  );
  Future<Result<List<OutputGradeDao>>> getByClassModule(String classModuleId);
}
