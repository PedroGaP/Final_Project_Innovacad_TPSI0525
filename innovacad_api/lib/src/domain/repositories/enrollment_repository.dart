import 'package:innovacad_api/src/domain/dtos/enrollment/enrollment_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/enrollment/enrollment_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/enrollment.dart';

abstract interface class IEnrollmentRepository {
  Future<List<Enrollment>?> getAll();
  Future<Enrollment?> getById(String id);
  Future<Enrollment?> create(EnrollmentCreateDto dto);
  Future<Enrollment?> update(EnrollmentUpdateDto dto);
  Future<Enrollment?> delete(String id);
}
