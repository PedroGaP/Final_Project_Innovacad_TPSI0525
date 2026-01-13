import 'package:innovacad_api/src/domain/dtos/grade/grade_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/grade/grade_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/grade.dart';
import 'package:innovacad_api/src/domain/repositories/grade_repository.dart';
import 'package:vaden/vaden.dart';

@Repository()
class GradeRepositoryImpl implements IGradeRepository {
  @override
  Future<List<Grade>?> getAll() {
    throw UnimplementedError();
  }

  @override
  Future<Grade?> getById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Grade?> create(GradeCreateDto dto) {
    throw UnimplementedError();
  }

  @override
  Future<Grade?> update(GradeUpdateDto dto) {
    throw UnimplementedError();
  }

  @override
  Future<Grade?> delete(String id) {
    throw UnimplementedError();
  }
}
