import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/grade/dao/output/output_grade_dao.dart';
import 'package:innovacad_api/src/data/grade/dto/create/create_grade_dto.dart';
import 'package:innovacad_api/src/data/grade/dto/delete/delete_grade_dto.dart';
import 'package:innovacad_api/src/data/grade/dto/update/update_grade_dto.dart';

abstract class IGradeRepository {
  Future<Result<List<OutputGradeDao>>> getAll();
  Future<Result<OutputGradeDao>> getById(String id);
  Future<Result<OutputGradeDao>> create(CreateGradeDto dto);
  Future<Result<OutputGradeDao>> update(UpdateGradeDto dto);
  Future<Result<OutputGradeDao>> delete(DeleteGradeDto dto);
}
