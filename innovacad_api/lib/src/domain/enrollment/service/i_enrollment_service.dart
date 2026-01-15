import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/enrollment/dao/output/output_enrollment_dao.dart';
import 'package:innovacad_api/src/data/enrollment/dto/create/create_enrollment_dto.dart';
import 'package:innovacad_api/src/data/enrollment/dto/delete/delete_enrollment_dto.dart';
import 'package:innovacad_api/src/data/enrollment/dto/update/update_enrollment_dto.dart';

abstract class IEnrollmentService {
  Future<Result<List<OutputEnrollmentDao>>> getAll();
  Future<Result<OutputEnrollmentDao>> getById(String id);
  Future<Result<OutputEnrollmentDao>> create(CreateEnrollmentDto dto);
  Future<Result<OutputEnrollmentDao>> update(UpdateEnrollmentDto dto);
  Future<Result<OutputEnrollmentDao>> delete(DeleteEnrollmentDto dto);
}
