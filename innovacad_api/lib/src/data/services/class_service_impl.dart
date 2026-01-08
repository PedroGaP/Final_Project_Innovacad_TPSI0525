import 'package:innovacad_api/src/data/repositories/class_repository_impl.dart';
import 'package:innovacad_api/src/domain/dtos/class_model/class_model_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/class_model/class_model_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/class_model.dart';
import 'package:innovacad_api/src/domain/services/class_service.dart';
import 'package:vaden/vaden.dart';

@Service()
class ClassServiceImpl implements IClassService {
  final ClassRepositoryImpl _repository;

  ClassServiceImpl(this._repository);

  @override
  Future<List<ClassModel>?> getAll() async {
    return await _repository.getAll();
  }

  @override
  Future<ClassModel?> getById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<ClassModel?> create(ClassModelCreateDto dto) async {
    return await _repository.create(dto);
  }

  @override
  Future<ClassModel?> update(ClassModelUpdateDto dto) async {
    return await _repository.update(dto);
  }

  @override
  Future<ClassModel?> delete(String id) async {
    return await _repository.delete(id);
  }
}
