import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:vaden/vaden.dart';

@Service()
class ClassModuleServiceImpl implements IClassModuleService {
  final IClassModuleRepository _repository;

  ClassModuleServiceImpl(this._repository);

  @override
  Future<Result<List<OutputClassModuleDao>>> getAll() async =>
      await _repository.getAll();

  @override
  Future<Result<OutputClassModuleDao>> getById(String id) async =>
      await _repository.getById(id);

  @override
  Future<Result<OutputClassModuleDao>> create(CreateClassModuleDto dto) async =>
      await _repository.create(dto);

  @override
  Future<Result<OutputClassModuleDao>> update(
    String id,
    UpdateClassModuleDto dto,
  ) async => await _repository.update(id, dto);

  @override
  Future<Result<OutputClassModuleDao>> delete(String id) async =>
      await _repository.delete(id);
}
