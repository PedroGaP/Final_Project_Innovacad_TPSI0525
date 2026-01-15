import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/class_module/repository/i_class_module_repository.dart';
import 'package:innovacad_api/src/domain/class_module/service/i_class_module_service.dart';
import 'package:vaden/vaden.dart';

@Service()
class ClassModuleServiceImpl implements IClassModuleService {
  final IClassModuleRepository _repository;

  ClassModuleServiceImpl(this._repository);

  @override
  Future<Result<List<OutputClassModuleDao>>> getAll() async => _repository.getAll();

  @override
  Future<Result<OutputClassModuleDao>> getById(String id) async => _repository.getById(id);

  @override
  Future<Result<OutputClassModuleDao>> create(CreateClassModuleDto dto) async => _repository.create(dto);

  @override
  Future<Result<OutputClassModuleDao>> update(UpdateClassModuleDto dto) async => _repository.update(dto);

  @override
  Future<Result<OutputClassModuleDao>> delete(DeleteClassModuleDto dto) async => _repository.delete(dto);
}
