import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';

abstract class IEnrollmentService {
  Future<Result<List<OutputEnrollmentDao>>> getAll();
  Future<Result<OutputEnrollmentDao>> getById(String id);
  Future<Result<OutputEnrollmentDao>> create(CreateEnrollmentDto dto);
  Future<Result<OutputEnrollmentDao>> update(
    String id,
    UpdateEnrollmentDto dto,
  );
  Future<Result<OutputEnrollmentDao>> delete(String id);
}
