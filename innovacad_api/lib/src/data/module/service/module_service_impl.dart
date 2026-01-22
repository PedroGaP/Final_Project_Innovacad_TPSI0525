import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:vaden/vaden.dart';

@Service()
class ModuleServiceImpl implements IModuleService {
  final IModuleRepository _repository;

  ModuleServiceImpl(this._repository);

  @override
  Future<Result<List<OutputModuleDao>>> getAll() async =>
      await _repository.getAll();

  @override
  Future<Result<OutputModuleDao>> getById(String id) async =>
      await _repository.getById(id);

  @override
  Future<Result<OutputModuleDao>> create(CreateModuleDto dto) async =>
      await _repository.create(dto);

  @override
  Future<Result<OutputModuleDao>> update(
    String id,
    UpdateModuleDto dto,
  ) async => await _repository.update(id, dto);

  @override
  Future<Result<OutputModuleDao>> delete(String id) async =>
      await _repository.delete(id);
}
