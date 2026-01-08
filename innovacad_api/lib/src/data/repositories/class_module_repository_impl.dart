import 'package:innovacad_api/src/domain/dtos/class_module/class_module_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/class_module/class_module_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/class_module.dart';
import 'package:innovacad_api/src/domain/repositories/class_module_repository.dart';
import 'package:vaden/vaden.dart';

@Repository()
class ClassModuleRepositoryImpl implements IClassModuleRepository {
  @override
  Future<List<ClassModule>?> getAll() {
    throw UnimplementedError();
  }

  @override
  Future<ClassModule?> getById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<ClassModule?> create(ClassModuleCreateDto dto) {
    throw UnimplementedError();
  }

  @override
  Future<ClassModule?> update(ClassModuleUpdateDto dto) {
    throw UnimplementedError();
  }

  @override
  Future<ClassModule?> delete(String id) {
    throw UnimplementedError();
  }
}
