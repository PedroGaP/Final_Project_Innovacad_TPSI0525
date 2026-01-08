import 'package:innovacad_api/src/data/repositories/class_module_repository_impl.dart';
import 'package:innovacad_api/src/domain/dtos/class_module/class_module_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/class_module/class_module_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/class_module.dart';
import 'package:innovacad_api/src/domain/services/class_module_service.dart';
import 'package:vaden/vaden.dart';

@Service()
class ClassModuleServiceImpl implements IClassModuleService {
  final ClassModuleRepositoryImpl _repository;

  ClassModuleServiceImpl(this._repository);

  @override
  Future<List<ClassModule>?> getAll() async {
    return await _repository.getAll();
  }

  @override
  Future<ClassModule?> getById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<ClassModule?> create(ClassModuleCreateDto dto) async {
    return await _repository.create(dto);
  }

  @override
  Future<ClassModule?> update(ClassModuleUpdateDto dto) async {
    return await _repository.update(dto);
  }

  @override
  Future<ClassModule?> delete(String id) async {
    return await _repository.delete(id);
  }
}
