import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/enrollment/repository/i_enrollment_repository.dart';
import 'package:innovacad_api/src/domain/enrollment/service/i_enrollment_service.dart';
import 'package:vaden/vaden.dart';

@Service()
class EnrollmentServiceImpl implements IEnrollmentService {
  final IEnrollmentRepository _repository;

  EnrollmentServiceImpl(this._repository);

  @override
  Future<Result<List<OutputEnrollmentDao>>> getAll() async =>
      await _repository.getAll();

  @override
  Future<Result<OutputEnrollmentDao>> getById(String id) async =>
      await _repository.getById(id);

  @override
  Future<Result<OutputEnrollmentDao>> create(CreateEnrollmentDto dto) async =>
      await _repository.create(dto);

  @override
  Future<Result<OutputEnrollmentDao>> update(
    String id,
    UpdateEnrollmentDto dto,
  ) async => await _repository.update(id, dto);

  @override
  Future<Result<OutputEnrollmentDao>> delete(String id) async =>
      await _repository.delete(id);
}
