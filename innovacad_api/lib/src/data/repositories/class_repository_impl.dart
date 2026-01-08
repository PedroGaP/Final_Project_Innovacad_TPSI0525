import 'package:innovacad_api/src/domain/dtos/class_model/class_model_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/class_model/class_model_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/class_model.dart';
import 'package:innovacad_api/src/domain/repositories/class_repository.dart';
import 'package:vaden/vaden.dart';

@Repository()
class ClassRepositoryImpl implements IClassRepository {
  @override
  Future<List<ClassModel>?> getAll() {
    throw UnimplementedError();
  }

  @override
  Future<ClassModel?> getById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<ClassModel?> create(ClassModelCreateDto dto) {
    throw UnimplementedError();
  }

  @override
  Future<ClassModel?> update(ClassModelUpdateDto dto) {
    throw UnimplementedError();
  }

  @override
  Future<ClassModel?> delete(String id) {
    throw UnimplementedError();
  }
}
