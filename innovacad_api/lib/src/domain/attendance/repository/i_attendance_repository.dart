import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/attendance/dao/output_module_attendance_dao.dart';

abstract class IAttendanceRepository {
  Future<Result<List<OutputModuleAttendanceDao>>> getModuleAttendance(
    String classModuleId,
  );
}
