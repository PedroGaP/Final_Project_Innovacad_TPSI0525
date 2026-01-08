import 'package:innovacad_api/src/data/repositories/grade_repository_impl.dart';
import 'package:innovacad_api/src/domain/dtos/grade/grade_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/grade/grade_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/grade.dart';
import 'package:innovacad_api/src/domain/services/grade_service.dart';
import 'package:vaden/vaden.dart';

@Service()
class GradeServiceImpl implements IGradeService {
  final GradeRepositoryImpl _repository;

  GradeServiceImpl(this._repository);

  @override
  Future<List<Grade>?> getAll() async {
    return await _repository.getAll();
  }

  @override
  Future<Grade?> getById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<Grade?> create(GradeCreateDto dto) async {
    return await _repository.create(dto);
  }

  @override
  Future<Grade?> update(GradeUpdateDto dto) async {
    return await _repository.update(dto);
  }

  @override
  Future<Grade?> delete(String id) async {
    return await _repository.delete(id);
  }
}
