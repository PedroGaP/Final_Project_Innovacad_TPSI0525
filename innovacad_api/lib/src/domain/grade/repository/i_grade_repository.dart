import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';

abstract class IGradeRepository {
  Future<Result<List<OutputGradeDao>>> getAll();
  Future<Result<OutputGradeDao>> getById(String id);
  Future<Result<OutputGradeDao>> create(CreateGradeDto dto);
  Future<Result<OutputGradeDao>> update(String id, UpdateGradeDto dto);
  Future<Result<OutputGradeDao>> delete(String id);
}
