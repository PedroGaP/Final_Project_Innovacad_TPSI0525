import 'package:innovacad_api/src/domain/dtos/module/module_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/module/module_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/module.dart';

abstract interface class IModuleService {
  Future<List<Module>?> getAll();
  Future<Module?> getById(String id);
  Future<Module?> create(ModuleCreateDto dto);
  Future<Module?> update(ModuleUpdateDto dto);
  Future<Module?> delete(String id);
}
