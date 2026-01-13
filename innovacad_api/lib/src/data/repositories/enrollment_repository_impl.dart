import 'package:innovacad_api/src/domain/dtos/enrollment/enrollment_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/enrollment/enrollment_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/enrollment.dart';
import 'package:innovacad_api/src/domain/repositories/enrollment_repository.dart';
import 'package:vaden/vaden.dart';

@Repository()
class EnrollmentRepositoryImpl implements IEnrollmentRepository {
  @override
  Future<List<Enrollment>?> getAll() {
    throw UnimplementedError();
  }

  @override
  Future<Enrollment?> getById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Enrollment?> create(EnrollmentCreateDto dto) {
    throw UnimplementedError();
  }

  @override
  Future<Enrollment?> update(EnrollmentUpdateDto dto) {
    throw UnimplementedError();
  }

  @override
  Future<Enrollment?> delete(String id) {
    throw UnimplementedError();
  }
}
