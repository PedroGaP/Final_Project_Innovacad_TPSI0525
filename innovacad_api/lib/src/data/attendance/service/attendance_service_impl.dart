import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/attendance/dao/output_module_attendance_dao.dart';
import 'package:innovacad_api/src/domain/attendance/repository/i_attendance_repository.dart';
import 'package:innovacad_api/src/domain/attendance/service/i_attendance_service.dart';
import 'package:vaden/vaden.dart';

@Service()
class AttendanceServiceImpl extends IAttendanceService {
  final IAttendanceRepository repository;

  AttendanceServiceImpl(this.repository);

  @override
  Future<Result<List<OutputModuleAttendanceDao>>> getModuleAttendance(
    String classModuleId,
  ) async {
    return await repository.getModuleAttendance(classModuleId);
  }
}
