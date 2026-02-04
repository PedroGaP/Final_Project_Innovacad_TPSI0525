import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/statistics/dto/statistics_dto.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:vaden/vaden.dart';

@Repository()
class StatisticsRepository {
  Future<Result<StatisticsDto>> getStatistics() async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();

      final countFinished = await db.query(
        "SELECT COUNT(*) as total FROM classes WHERE status = 'finished'",
      );
      final countOngoing = await db.query(
        "SELECT COUNT(*) as total FROM classes WHERE status = 'ongoing'",
      );

      final countTrainees = await db.query(
        "SELECT COUNT(DISTINCT e.trainee_id) as total "
        "FROM enrollments e "
        "JOIN classes c ON e.class_id = c.class_id "
        "WHERE c.status = 'ongoing'",
      );

      final areasResult = await db.query(
        "SELECT area, COUNT(*) as count FROM courses GROUP BY area ORDER BY count DESC",
      );

      final trainersResult = await db.query(
        "SELECT u.name, SUM(s.total_hours) as total_hours "
        "FROM schedules s "
        "JOIN trainers t ON s.trainer_id = t.trainer_id "
        "JOIN user u ON t.user_id = u.id "
        "GROUP BY s.trainer_id "
        "ORDER BY total_hours DESC "
        "LIMIT 10",
      );

      return Result.success(
        StatisticsDto(
          totalFinishedClasses: int.parse(
            countFinished.rows.first['total'].toString(),
          ),
          totalOngoingClasses: int.parse(
            countOngoing.rows.first['total'].toString(),
          ),
          totalActiveTrainees: int.parse(
            countTrainees.rows.first['total'].toString(),
          ),
          coursesByArea: areasResult.rowsAssoc
              .map((r) => r.assoc() as Map<String, dynamic>)
              .toList(),
          topTrainers: trainersResult.rowsAssoc
              .map((r) => r.assoc() as Map<String, dynamic>)
              .toList(),
        ),
      );
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    } finally {
      await db?.close();
    }
  }
}
