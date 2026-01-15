import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/module/repository/i_module_repository.dart';
import 'package:innovacad_api/src/domain/module/service/i_module_service.dart';
import 'package:vaden/vaden.dart';

@Service()
class ModuleServiceImpl implements IModuleService {
  final IModuleRepository _repository;

  ModuleServiceImpl(this._repository);

  @override
  Future<Result<List<OutputModuleDao>>> getAll() async => _repository.getAll();

  @override
  Future<Result<OutputModuleDao>> getById(String id) async => _repository.getById(id);

  @override
  Future<Result<OutputModuleDao>> create(CreateModuleDto dto) async => _repository.create(dto);

  @override
  Future<Result<OutputModuleDao>> update(UpdateModuleDto dto) async => _repository.update(dto);

  @override
  Future<Result<OutputModuleDao>> delete(DeleteModuleDto dto) async => _repository.delete(dto);
}
