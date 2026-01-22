import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:vaden/vaden.dart';

@Service()
class ClassServiceImpl implements IClassService {
  final IClassRepository _repository;

  ClassServiceImpl(this._repository);

  @override
  Future<Result<List<OutputClassDao>>> getAll() async => _repository.getAll();

  @override
  Future<Result<OutputClassDao>> getById(String id) async =>
      _repository.getById(id);

  @override
  Future<Result<OutputClassDao>> create(CreateClassDto dto) async =>
      _repository.create(dto);

  @override
  Future<Result<OutputClassDao>> update(String id, UpdateClassDto dto) async =>
      _repository.update(id, dto);

  @override
  Future<Result<OutputClassDao>> delete(String id) async =>
      _repository.delete(id);
}
