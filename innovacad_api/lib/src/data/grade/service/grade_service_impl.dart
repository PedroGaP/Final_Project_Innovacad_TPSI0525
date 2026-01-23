import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:vaden/vaden.dart';

@Service()
class GradeServiceImpl implements IGradeService {
  final IGradeRepository _repository;

  GradeServiceImpl(this._repository);

  @override
  Future<Result<List<OutputGradeDao>>> getAll() async =>
      await _repository.getAll();

  @override
  Future<Result<OutputGradeDao>> getById(String id) async =>
      await _repository.getById(id);

  @override
  Future<Result<OutputGradeDao>> create(CreateGradeDto dto) async =>
      await _repository.create(dto);

  @override
  Future<Result<OutputGradeDao>> update(String id, UpdateGradeDto dto) async =>
      await _repository.update(id, dto);

  @override
  Future<Result<OutputGradeDao>> delete(String id) async =>
      await _repository.delete(id);
}
