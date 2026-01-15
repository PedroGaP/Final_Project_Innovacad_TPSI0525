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
  Future<Result<List<OutputEnrollmentDao>>> getAll() async => _repository.getAll();

  @override
  Future<Result<OutputEnrollmentDao>> getById(String id) async => _repository.getById(id);

  @override
  Future<Result<OutputEnrollmentDao>> create(CreateEnrollmentDto dto) async => _repository.create(dto);

  @override
  Future<Result<OutputEnrollmentDao>> update(UpdateEnrollmentDto dto) async => _repository.update(dto);

  @override
  Future<Result<OutputEnrollmentDao>> delete(DeleteEnrollmentDto dto) async => _repository.delete(dto);
}
