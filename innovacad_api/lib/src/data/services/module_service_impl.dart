import 'package:innovacad_api/src/data/repositories/module_repository_impl.dart';
import 'package:innovacad_api/src/domain/dtos/module/module_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/module/module_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/module.dart';
import 'package:innovacad_api/src/domain/services/module_service.dart';
import 'package:vaden/vaden.dart';

@Service()
class ModuleServiceImpl implements IModuleService {
  final ModuleRepositoryImpl _repository;

  ModuleServiceImpl(this._repository);

  @override
  Future<List<Module>?> getAll() async {
    return await _repository.getAll();
  }

  @override
  Future<Module?> getById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<Module?> create(ModuleCreateDto dto) async {
    return await _repository.create(dto);
  }

  @override
  Future<Module?> update(ModuleUpdateDto dto) async {
    return await _repository.update(dto);
  }

  @override
  Future<Module?> delete(String id) async {
    return await _repository.delete(id);
  }
}
