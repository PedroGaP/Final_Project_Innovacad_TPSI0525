import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/attendance/dao/output_module_attendance_dao.dart';
import 'package:innovacad_api/src/domain/attendance/repository/i_attendance_repository.dart';
import 'package:vaden/vaden.dart';

@Repository()
class AttendanceRepositoryImpl extends IAttendanceRepository {
  @override
  Future<Result<List<OutputModuleAttendanceDao>>> getModuleAttendance(
    String classModuleId,
  ) async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final query = """
          SELECT 
            a.trainee_id,
            SUM(CASE WHEN a.is_absent = 0 THEN sch.total_hours ELSE 0 END) as attended_hours,
            SUM(sch.total_hours) as total_hours
          FROM schedules sch
          JOIN summaries s ON s.schedule_id = sch.schedule_id
          JOIN attendances a ON a.summary_id = s.summary_id
          WHERE sch.class_module_id = ?
          GROUP BY a.trainee_id
        """;

        final results = await db.query(
          query,
          whereValues: [classModuleId],
          isStmt: true,
        );

        final list = results.rowsAssoc.map((row) {
          final data = row.assoc();
          print(data);
          return OutputModuleAttendanceDao.fromJson(data);
        }).toList();

        return Result.success(list);
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          e.toString(),
          details: {"error": e.toString(), "stack": s.toString()},
        ),
      );
    }
  }
}
