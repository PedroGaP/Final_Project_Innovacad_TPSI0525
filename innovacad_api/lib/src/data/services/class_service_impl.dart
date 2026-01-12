import 'package:innovacad_api/src/domain/dtos/class_model/class_model_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/class_model/class_model_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/class_model.dart';
import 'package:innovacad_api/src/domain/repositories/class_repository.dart';
import 'package:innovacad_api/src/domain/services/class_service.dart';
import 'package:vaden/vaden.dart';

@Service()
class ClassServiceImpl implements IClassService {
  final IClassRepository _repository;

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
  Future<ClassModel?> update(String id, ClassModelUpdateDto dto) async {
    return await _repository.update(id, dto);
  }

  @override
  Future<ClassModel?> delete(String id) async {
    return await _repository.delete(id);
  }
}
