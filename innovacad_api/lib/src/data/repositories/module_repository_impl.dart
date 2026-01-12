import 'package:innovacad_api/src/domain/dtos/module/module_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/module/module_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/module.dart';
import 'package:innovacad_api/src/domain/repositories/module_repository.dart';
import 'package:vaden/vaden.dart';

@Repository()
class ModuleRepositoryImpl implements IModuleRepository {
  @override
  Future<List<Module>?> getAll() {
    throw UnimplementedError();
  }

  @override
  Future<Module?> getById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Module?> create(ModuleCreateDto dto) {
    throw UnimplementedError();
  }

  @override
  Future<Module?> update(ModuleUpdateDto dto) {
    throw UnimplementedError();
  }

  @override
  Future<Module?> delete(String id) {
    throw UnimplementedError();
  }
}
