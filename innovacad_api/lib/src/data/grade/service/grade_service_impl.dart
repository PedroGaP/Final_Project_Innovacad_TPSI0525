import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/grade/repository/i_grade_repository.dart';
import 'package:innovacad_api/src/domain/grade/service/i_grade_service.dart';
import 'package:vaden/vaden.dart';

@Service()
class GradeServiceImpl implements IGradeService {
  final IGradeRepository _repository;

  GradeServiceImpl(this._repository);

  @override
  Future<Result<List<OutputGradeDao>>> getAll() async => _repository.getAll();

  @override
  Future<Result<OutputGradeDao>> getById(String id) async => _repository.getById(id);

  @override
  Future<Result<OutputGradeDao>> create(CreateGradeDto dto) async => _repository.create(dto);

  @override
  Future<Result<OutputGradeDao>> update(UpdateGradeDto dto) async => _repository.update(dto);

  @override
  Future<Result<OutputGradeDao>> delete(DeleteGradeDto dto) async => _repository.delete(dto);
}
