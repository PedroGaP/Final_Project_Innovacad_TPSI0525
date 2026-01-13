import 'package:innovacad_api/src/data/repositories/enrollment_repository_impl.dart';
import 'package:innovacad_api/src/domain/dtos/enrollment/enrollment_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/enrollment/enrollment_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/enrollment.dart';
import 'package:innovacad_api/src/domain/services/enrollment_service.dart';
import 'package:vaden/vaden.dart';

@Service()
class EnrollmentServiceImpl implements IEnrollmentService {
  final EnrollmentRepositoryImpl _repository;

  EnrollmentServiceImpl(this._repository);

  @override
  Future<List<Enrollment>?> getAll() async {
    return await _repository.getAll();
  }

  @override
  Future<Enrollment?> getById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<Enrollment?> create(EnrollmentCreateDto dto) async {
    return await _repository.create(dto);
  }

  @override
  Future<Enrollment?> update(EnrollmentUpdateDto dto) async {
    return await _repository.update(dto);
  }

  @override
  Future<Enrollment?> delete(String id) async {
    return await _repository.delete(id);
  }
}
