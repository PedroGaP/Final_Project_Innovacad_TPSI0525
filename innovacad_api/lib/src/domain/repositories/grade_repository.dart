import 'package:innovacad_api/src/domain/dtos/grade/grade_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/grade/grade_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/grade.dart';

abstract interface class IGradeRepository {
  Future<List<Grade>?> getAll();
  Future<Grade?> getById(String id);
  Future<Grade?> create(GradeCreateDto dto);
  Future<Grade?> update(GradeUpdateDto dto);
  Future<Grade?> delete(String id);
}
