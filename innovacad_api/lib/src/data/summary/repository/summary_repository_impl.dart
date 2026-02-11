import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/core/extensions/mysql_utils_extension.dart';
import 'package:innovacad_api/src/data/summary/dao/output_summary_grid_dao.dart';
import 'package:innovacad_api/src/data/summary/dto/save_summary_dto.dart';
import 'package:innovacad_api/src/domain/summary/repository/i_summary_repository.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:vaden/vaden.dart';

@Repository()
class SummaryRepositoryImpl implements ISummaryRepository {
  @override
  Future<Result<OutputSummaryGridDao>> getGridBySchedule(
    String scheduleId,
  ) async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final summaryRes = await db.getOne(
          table: 'summaries',
          where: {'schedule_id': scheduleId},
        );

        final summaryId = summaryRes.isNotEmpty
            ? summaryRes['summary_id']
            : null;
        final contents = summaryRes.isNotEmpty ? summaryRes['contents'] : '';

        final query = """
          SELECT 
            t.trainee_id, 
            u.name, 
            u.image,
            COALESCE(att.is_absent, 0) as is_absent
          FROM schedules s
          JOIN classes_modules cm ON s.class_module_id = cm.classes_modules_id
          JOIN enrollments e ON cm.class_id = e.class_id
          JOIN trainees t ON e.trainee_id = t.trainee_id
          JOIN user u ON t.user_id = u.id
          LEFT JOIN summaries sum ON s.schedule_id = sum.schedule_id
          LEFT JOIN attendances att ON sum.summary_id = att.summary_id AND att.trainee_id = t.trainee_id
          WHERE s.schedule_id = ?
          ORDER BY u.name ASC
        """;

        final studentsRes = await db.query(
          query,
          whereValues: [scheduleId],
          isStmt: true,
        );

        final students = studentsRes.rowsAssoc.map((row) {
          final data = row.assoc();
          return StudentAttendanceDao(
            traineeId: data['trainee_id'].toString(),
            name: data['name'].toString(),
            image: data['image']?.toString(),
            isAbsent: (data['is_absent'].toString() == '1'),
          );
        }).toList();

        return Result.success(
          OutputSummaryGridDao(
            scheduleId: scheduleId,
            summaryId: summaryId?.toString(),
            contents: contents?.toString(),
            students: students,
          ),
        );
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          e.toString(),
          details: {'stack': s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<bool>> saveSummary(SaveSummaryDto dto) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.getConnection();

      // Transação curta e rápida
      await db.transaction((txn) async {
        // 1. Upsert Summary
        final existing = await txn.getOne(
          table: 'summaries',
          where: {'schedule_id': dto.scheduleId},
        );
        String summaryId;

        if (existing.isEmpty) {
          summaryId = Uuid().v4();
          await txn.insert(
            table: 'summaries',
            insertData: {
              'summary_id': summaryId,
              'schedule_id': dto.scheduleId,
              'contents': dto.contents,
            },
          );
        } else {
          summaryId = existing['summary_id'];
          await txn.update(
            table: 'summaries',
            updateData: {'contents': dto.contents},
            where: {'summary_id': summaryId},
          );
        }

        // 2. Batch Upsert Attendances (OTIMIZAÇÃO CRÍTICA)
        if (dto.attendances.isNotEmpty) {
          List<String> valueSets = [];

          for (var att in dto.attendances) {
            // Geramos ID novo, mas se bater na Unique Key (summary_id + trainee_id), faz update
            final attId = Uuid().v4();
            final isAbsentVal = att.isAbsent ? 1 : 0;
            // Construção segura da string de valores
            valueSets.add(
              "('$attId', '$summaryId', '${att.traineeId}', $isAbsentVal)",
            );
          }

          // Executa TUDO numa única query.
          // O DB só bloqueia a tabela uma vez, escreve tudo e liberta.
          final sql =
              """
            INSERT INTO attendances (attendance_id, summary_id, trainee_id, is_absent)
            VALUES ${valueSets.join(',')}
            ON DUPLICATE KEY UPDATE is_absent = VALUES(is_absent)
          """;

          await txn.query(sql);
        }
      });

      return Result.success(true);
    } catch (e, s) {
      print("Save Summary Error: $e");
      // Se der Lock Wait Timeout, o erro será apanhado aqui
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Failed to save summary: $e",
          details: {"stack": s.toString()},
        ),
      );
    } finally {
      // Garante SEMPRE que a conexão fecha, mesmo se houver erro
      await MysqlConfiguration.closeConnection(db);
    }
  }
}
