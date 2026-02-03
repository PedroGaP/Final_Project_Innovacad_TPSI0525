import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/core/extensions/mysql_utils_extension.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/data/schedule/dto/auto/auto_schedule_dto.dart';
import 'package:innovacad_api/src/domain/schedule/repository/i_schedule_repository.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:vaden/vaden.dart';

@Repository()
class ScheduleRepositoryImpl implements IScheduleRepository {
  final String schedulesTable = "schedules";
  final String schedulesSlotsTable = "schedule_slots";
  final String scheduleQuerySql = """SELECT 
      s.schedule_id, 
      IF(s.regime_type = 0, 'daytime', 'post-work') AS regime_type, 
      m.name AS module_name, 
      u.name AS trainer_name, 
      s.start_date_timestamp,
      s.end_date_timestamp,
      IF(s.is_online, 'online', r.room_name) AS room_name,
      s.class_module_id, s.trainer_id, s.room_id, s.is_online, s.regime_type, s.total_hours
      FROM schedules s
      JOIN classes_modules classm ON s.class_module_id = classm.classes_modules_id
      JOIN courses_modules coursem ON classm.courses_modules_id = coursem.courses_modules_id
      JOIN modules m ON coursem.module_id = m.module_id
      JOIN trainers t ON s.trainer_id = t.trainer_id
      JOIN user u ON t.user_id = u.id
      LEFT JOIN rooms r ON s.room_id = r.room_id""";

  String _toSqlDate(DateTime dt) {
    return dt.toIso8601String().replaceAll('T', ' ').substring(0, 19);
  }

  DateTime _combineDateAndTime(DateTime date, String timeStr) {
    final parts = timeStr.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  Future<bool> checkTrainerAvailability(
    MysqlUtils db,
    String trainerId,
    DateTime start,
    DateTime end,
  ) async {
    final query = """
      SELECT a.date_day, rs.start_time, rs.end_time
      FROM availabilities a
      JOIN ref_slots rs ON a.slot_number = rs.slot_number
      WHERE a.trainer_id = ? 
      AND DATE(a.date_day) = DATE(?) 
      AND a.is_booked = 0 
      ORDER BY rs.start_time ASC
    """;

    final results = await db.query(
      query,
      whereValues: [trainerId, start.toIso8601String()],
      isStmt: true,
    );

    if (results.rows.isEmpty) return false;

    List<Map<String, DateTime>> availableSlots = [];

    for (var row in results.rowsAssoc) {
      final data = row.assoc();
      DateTime dateDay = DateTime.parse(data['date_day'].toString());

      DateTime slotStart = _combineDateAndTime(dateDay, data['start_time']);
      DateTime slotEnd = _combineDateAndTime(dateDay, data['end_time']);

      if (slotStart.isBefore(end) && slotEnd.isAfter(start)) {
        availableSlots.add({'start': slotStart, 'end': slotEnd});
      }
    }

    if (availableSlots.isEmpty) return false;

    DateTime currentCoverageEnd = start;

    for (var slot in availableSlots) {
      DateTime slotStart = slot['start']!;
      DateTime slotEnd = slot['end']!;

      if (slotStart.isAfter(currentCoverageEnd)) {
        return false;
      }

      if (slotEnd.isAfter(currentCoverageEnd)) {
        currentCoverageEnd = slotEnd;
      }

      if (currentCoverageEnd.isAfter(end) ||
          currentCoverageEnd.isAtSameMomentAs(end)) {
        return true;
      }
    }

    return currentCoverageEnd.isAfter(end) ||
        currentCoverageEnd.isAtSameMomentAs(end);
  }

  @override
  Future<Result<List<OutputScheduleDao>>> getAll() async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      final results = await db.query(scheduleQuerySql);

      final items = results.rowsAssoc.map((data) {
        return _mapRowToDao(data.assoc());
      }).toList();

      return Result.success(items);
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Error fetching schedules",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<List<OutputScheduleDao>>> getById(String classId) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();

      final result = await db.query(
        "$scheduleQuerySql WHERE classm.class_id = ? ORDER BY s.start_date_timestamp ASC",
        isStmt: true,
        whereValues: [classId],
      );

      if (result.numOfRows <= 0) {
        return Result.success([]);
      }

      final list = result.rowsAssoc
          .map((row) => _mapRowToDao(row.assoc()))
          .toList();

      return Result.success(list);
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Error fetching schedules for class",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  Future<Result<OutputScheduleDao>> _getSingleScheduleById(
    String scheduleId,
  ) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      final result = await db.query(
        "$scheduleQuerySql WHERE s.schedule_id = ?",
        isStmt: true,
        whereValues: [scheduleId],
      );
      if (result.numOfRows < 1)
        return Result.failure(AppError(AppErrorType.notFound, "Not found"));
      return Result.success(_mapRowToDao(result.rowsAssoc.first.assoc()));
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputScheduleDao>> create(CreateScheduleDto dto) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      if (dto.startTime.isAfter(dto.endTime) ||
          dto.startTime.isAtSameMomentAs(dto.endTime)) {
        return Result.failure(
          AppError(
            AppErrorType.badRequest,
            "A hora de fim deve ser superior à de início.",
          ),
        );
      }

      final trainerCheckSql =
          "SELECT DISTINCT trainer_id FROM schedules WHERE class_module_id = ? LIMIT 1";
      final trainerResult = await db.query(
        trainerCheckSql,
        whereValues: [dto.classModuleId],
        isStmt: true,
      );

      if (trainerResult.numOfRows > 0) {
        final assignedTrainerId = trainerResult.rowsAssoc.first
            .assoc()['trainer_id'];
        if (assignedTrainerId != dto.trainerId && !dto.forceTrainerChange) {
          return Result.failure(
            AppError(
              AppErrorType.conflict,
              "Módulo já iniciado por outro formador. Use 'Substituição' para forçar.",
            ),
          );
        }
      }

      final availabilitySql = """
        SELECT rs.start_time, rs.end_time, a.availability_id, a.is_booked
        FROM availabilities a
        JOIN ref_slots rs ON a.slot_number = rs.slot_number
        WHERE a.trainer_id = ? 
        AND DATE(a.date_day) = DATE(?) 
        ORDER BY rs.start_time ASC
      """;

      final availResults = await db.query(
        availabilitySql,
        whereValues: [dto.trainerId, dto.startTime],
        isStmt: true,
      );

      if (availResults.numOfRows < 1) {
        return Result.failure(
          AppError(
            AppErrorType.conflict,
            "Formador sem disponibilidade definida para este dia.",
          ),
        );
      }

      List<Map<String, dynamic>> matchingAvailabilities = [];

      List<Map<String, dynamic>> slotRanges = [];

      for (var row in availResults.rowsAssoc) {
        final data = row.assoc();
        final isBooked = (data['is_booked'] == 1 || data['is_booked'] == true);

        final sStart = _combineDateAndTime(dto.startTime, data['start_time']);
        final sEnd = _combineDateAndTime(dto.startTime, data['end_time']);

        if (sStart.isBefore(dto.endTime) && sEnd.isAfter(dto.startTime)) {
          if (isBooked) continue;

          slotRanges.add({
            'start': sStart,
            'end': sEnd,
            'id': data['availability_id'],
          });
        }
      }

      final isAvailable = await checkTrainerAvailability(
        db,
        dto.trainerId,
        dto.startTime,
        dto.endTime,
      );

      if (!isAvailable && dto.forceTrainerChange != true) {
        return Result.failure(
          AppError(
            AppErrorType.conflict,
            "Horário fora da disponibilidade do formador ou ocupado.",
          ),
        );
      }

      matchingAvailabilities = slotRanges
          .map((e) => {'availability_id': e['id']})
          .toList();

      final conflictTrainer = await db.query(
        """
        SELECT schedule_id FROM schedules 
        WHERE trainer_id = ? 
        AND (
            (start_date_timestamp < ? AND end_date_timestamp > ?) OR 
            (start_date_timestamp < ? AND end_date_timestamp > ?) OR 
            (start_date_timestamp >= ? AND end_date_timestamp <= ?)
        )
      """,
        whereValues: [
          dto.trainerId,
          dto.endTime.toIso8601String(),
          dto.startTime.toIso8601String(),
          dto.endTime.toIso8601String(),
          dto.startTime.toIso8601String(),
          dto.startTime.toIso8601String(),
          dto.endTime.toIso8601String(),
        ],
        isStmt: true,
      );

      if (conflictTrainer.numOfRows > 0) {
        return Result.failure(
          AppError(
            AppErrorType.conflict,
            "O Formador já tem aula marcada neste horário.",
          ),
        );
      }

      final classInfo = await db.getOne(
        table: 'classes_modules',
        where: {'classes_modules_id': dto.classModuleId},
      );
      final classId = classInfo['class_id'];

      final conflictClass = await db.query(
        """
        SELECT s.schedule_id FROM schedules s
        JOIN classes_modules cm ON s.class_module_id = cm.classes_modules_id
        WHERE cm.class_id = ?
        AND (
            (s.start_date_timestamp < ? AND s.end_date_timestamp > ?) OR
            (s.start_date_timestamp < ? AND s.end_date_timestamp > ?) OR
            (s.start_date_timestamp >= ? AND s.end_date_timestamp <= ?)
        )
      """,
        whereValues: [
          classId,
          dto.endTime.toIso8601String(),
          dto.startTime.toIso8601String(),
          dto.endTime.toIso8601String(),
          dto.startTime.toIso8601String(),
          dto.startTime.toIso8601String(),
          dto.endTime.toIso8601String(),
        ],
        isStmt: true,
      );

      if (conflictClass.numOfRows > 0) {
        return Result.failure(
          AppError(
            AppErrorType.conflict,
            "A Turma já tem aula marcada neste horário.",
          ),
        );
      }

      final scheduleId = Uuid().v4();

      await db.transaction((txn) async {
        await txn.insert(
          table: 'schedules',
          insertData: {
            'schedule_id': scheduleId,
            'class_module_id': dto.classModuleId,
            'trainer_id': dto.trainerId,
            'room_id': dto.roomId,
            'start_date_timestamp': _toSqlDate(dto.startTime),
            'end_date_timestamp': _toSqlDate(dto.endTime),
            'total_hours':
                dto.endTime.difference(dto.startTime).inMinutes / 60.0,
            'regime_type': 0,
            'is_online': 0,
          },
        );

        for (final avail in matchingAvailabilities) {
          final availId = avail['availability_id'];

          await txn.insert(
            table: 'schedule_slots',
            insertData: {
              'slot_id': Uuid().v4(),
              'schedule_id': scheduleId,
              'availability_id': availId,
              'slot_status': 1,
            },
          );

          await txn.query(
            "UPDATE availabilities SET is_booked = 1 WHERE availability_id = ?",
            whereValues: [availId],
            isStmt: true,
          );
        }

        final duration = dto.endTime.difference(dto.startTime).inMinutes / 60.0;
        await txn.query(
          "UPDATE classes_modules SET current_duration = current_duration + ? WHERE classes_modules_id = ?",
          whereValues: [duration, dto.classModuleId],
          isStmt: true,
        );
      });

      return await _getSingleScheduleById(scheduleId);
    } catch (e, s) {
      print("Schedule Create Error: $e");
      print(s);
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputScheduleDao>> update(
    String id,
    UpdateScheduleDto dto,
  ) async {
    MysqlUtils? db;

    try {
      final currentResult = await _getSingleScheduleById(id);
      if (currentResult.isFailure) return currentResult;

      db = await MysqlConfiguration.connect();
      final rawCurrent = await db.getOne(
        table: schedulesTable,
        where: {'schedule_id': id},
      );

      final String oldTrainerId = rawCurrent['trainer_id'];
      final DateTime oldStartTime = DateTime.parse(
        rawCurrent['start_date_timestamp'].toString(),
      );
      final DateTime oldEndTime = DateTime.parse(
        rawCurrent['end_date_timestamp'].toString(),
      );

      final bool isTrainerChanged =
          dto.trainerId != null && dto.trainerId != oldTrainerId;
      final bool isTimeChanged =
          dto.startTime != null &&
          dto.endTime != null &&
          (dto.startTime != oldStartTime || dto.endTime != oldEndTime);

      await db.transaction((txn) async {
        final updateData = <String, dynamic>{};

        if (dto.roomId != null) updateData['room_id'] = dto.roomId;
        if (dto.isOnline != null)
          updateData['is_online'] = dto.isOnline! ? 1 : 0;
        if (dto.regimeType != null) updateData['regime_type'] = dto.regimeType;

        if (isTrainerChanged || isTimeChanged) {
          final targetTrainerId = dto.trainerId ?? oldTrainerId;
          final targetStart = dto.startTime ?? oldStartTime;
          final targetEnd = dto.endTime ?? oldEndTime;

          final oldSlots = await txn.query(
            "SELECT availability_id FROM schedule_slots WHERE schedule_id = ?",
            whereValues: [id],
          );
          for (var row in oldSlots.rows) {
            await txn.query(
              "UPDATE availabilities SET is_booked = 0 WHERE availability_id = ?",
              whereValues: [row['availability_id']],
            );
          }
          await txn.delete(
            table: schedulesSlotsTable,
            where: {'schedule_id': id},
          );

          final availSql = """
              SELECT rs.start_time, rs.end_time, a.availability_id, a.is_booked
              FROM availabilities a
              JOIN ref_slots rs ON a.slot_number = rs.slot_number
              WHERE a.trainer_id = ? 
              AND DATE(a.date_day) = DATE(?)
              AND a.is_booked = 0
              ORDER BY rs.start_time ASC
          """;

          final availResult = await txn.query(
            availSql,
            whereValues: [targetTrainerId, targetStart],
          );

          List<String> newAvailabilityIds = [];

          for (var row in availResult.rowsAssoc) {
            final data = row.assoc();

            final sStart = _combineDateAndTime(targetStart, data['start_time']);
            final sEnd = _combineDateAndTime(targetStart, data['end_time']);

            if (sStart.isBefore(targetEnd) && sEnd.isAfter(targetStart)) {
              newAvailabilityIds.add(data['availability_id']);
            }
          }

          if (newAvailabilityIds.isEmpty) {
            throw AppError(
              AppErrorType.conflict,
              "Não há slots disponíveis para o novo horário/formador.",
            );
          }

          for (String availId in newAvailabilityIds) {
            await txn.query(
              "UPDATE availabilities SET is_booked = 1 WHERE availability_id = ?",
              whereValues: [availId],
            );
            await txn.insert(
              table: schedulesSlotsTable,
              insertData: {
                'slot_id': Uuid().v4(),
                'schedule_id': id,
                'availability_id': availId,
                'slot_status': 1,
              },
            );
          }

          if (isTrainerChanged) updateData['trainer_id'] = targetTrainerId;
          if (isTimeChanged) {
            updateData['start_date_timestamp'] = _toSqlDate(targetStart);
            updateData['end_date_timestamp'] = _toSqlDate(targetEnd);
            updateData['total_hours'] =
                targetEnd.difference(targetStart).inMinutes / 60.0;
          }
        }

        if (updateData.isNotEmpty) {
          await txn.update(
            table: schedulesTable,
            updateData: updateData,
            where: {'schedule_id': id},
          );
        }
      });

      return await _getSingleScheduleById(id);
    } catch (e, s) {
      if (e is AppError) return Result.failure(e);

      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Update failed",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<List<OutputScheduleDao>>> getByUser(String userId) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();

      final result = await db.query(
        "$scheduleQuerySql WHERE u.id = ? ORDER BY s.start_date_timestamp ASC",
        isStmt: true,
        whereValues: [userId],
      );

      if (result.numOfRows <= 0) {
        return Result.success([]);
      }

      final list = result.rowsAssoc
          .map((row) => _mapRowToDao(row.assoc()))
          .toList();

      return Result.success(list);
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Error fetching user schedules",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputScheduleDao>> delete(String id) async {
    MysqlUtils? db;

    try {
      final existingResult = await _getSingleScheduleById(id);
      if (existingResult.isFailure) return existingResult;

      final scheduleData = existingResult.data!;

      db = await MysqlConfiguration.connect();
      final rawData = await db.getOne(
        table: schedulesTable,
        where: {'schedule_id': id},
      );
      final classModuleId = rawData['class_module_id'];
      final double hoursToRemove =
          double.tryParse(rawData['total_hours'].toString()) ?? 0.0;

      await db.transaction((txn) async {
        final slots = await txn.query(
          "SELECT availability_id FROM schedule_slots WHERE schedule_id = ?",
          whereValues: [id],
        );

        for (var row in slots.rows) {
          final availId = row['availability_id'];
          await txn.query(
            "UPDATE availabilities SET is_booked = 0 WHERE availability_id = ?",
            whereValues: [availId],
          );
        }

        await txn.delete(table: schedulesTable, where: {"schedule_id": id});

        await txn.query(
          "UPDATE classes_modules SET current_duration = current_duration - ? WHERE classes_modules_id = ?",
          whereValues: [hoursToRemove, classModuleId],
        );
      });

      return existingResult;
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Delete failed",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  OutputScheduleDao _mapRowToDao(Map<String, dynamic> row) {
    final rawStart = row['start_date_timestamp']?.toString();
    final rawEnd = row['end_date_timestamp']?.toString();

    final startDt = (rawStart != null && rawStart != 'null')
        ? DateTime.parse(rawStart)
        : DateTime.now();

    final endDt = (rawEnd != null && rawEnd != 'null')
        ? DateTime.parse(rawEnd)
        : startDt.add(Duration(hours: 1));

    return OutputScheduleDao(
      scheduleId: row['schedule_id'].toString(),
      moduleName: row['module_name'].toString(),
      trainerName: row['trainer_name'].toString(),
      roomName: row['room_name']?.toString() ?? 'N/A',
      dateDay: DateTime(startDt.year, startDt.month, startDt.day),
      startTime: Duration(hours: startDt.hour, minutes: startDt.minute),
      endTime: Duration(hours: endDt.hour, minutes: endDt.minute),
      isOnline:
          (row['is_online'].toString() == '1' || row['is_online'] == true),
      regimeType: row['regime_type'].toString() == 'post-work'
          ? 'Pós-laboral'
          : 'Diurno',
    );
  }

  @override
  Future<Result<bool>> generateAutomaticSchedule(AutoScheduleDto dto) async {
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.connect();

      String timeCondition;

      if (dto.regimeType == 0)
        timeCondition =
            "start_time >= '08:00:00' "
            "AND start_time <= '14:00:00' "
            "AND start_time != '11:00:00'";
      else
        timeCondition =
            "start_time >= '16:00:00'"
            "AND start_time < '23:00:00'"
            "AND start_time != '19:00:00'";

      final slotsQuery =
          "SELECT slot_number FROM ref_slots WHERE $timeCondition ORDER BY start_time ASC";

      final slotsResult = await db.query(slotsQuery);

      if (slotsResult.numOfRows <= 0)
        return Result.failure(
          AppError(
            AppErrorType.badRequest,
            "Não existem slots configurados para este horário.",
          ),
        );

      final List<int> allowedSlots = slotsResult.rows
          .map((r) => int.parse(r['slot_number'].toString()))
          .toList();

      final modulesQuery = """
        SELECT cm.classes_modules_id, m.module_id, m.duration
        FROM classes_modules cm
        JOIN courses_modules crm ON cm.courses_modules_id = crm.courses_modules_id
        JOIN modules m ON crm.module_id = m.module_id
        WHERE cm.class_id = ?
      """;

      final modulesResult = await db.query(
        modulesQuery,
        whereValues: [dto.classId],
        isStmt: true,
      );

      if (modulesResult.numOfRows <= 0)
        return Result.failure(
          AppError(AppErrorType.notFound, "Turma sem módulos associados."),
        );

      DateTime currentDateCursor = dto.startDate;

      await db.transaction((txn) async {
        for (var row in modulesResult.rowsAssoc) {
          final data = row.assoc();
          final String classModuleId = data['classes_modules_id'].toString();
          final String moduleId = data['module_id'].toString();
          final String moduleName = data['name']?.toString() ?? moduleId;
          double hoursRemaining =
              double.tryParse(data['duration'].toString()) ?? 0.0;

          while (hoursRemaining > 0) {
            if (currentDateCursor.weekday != DateTime.sunday) {
              for (int slotNum in allowedSlots) {
                if (hoursRemaining <= 0) break;

                final sqlDate = _toSqlDate(currentDateCursor);
                final onlineVal = dto.isOnline ? 1 : 0;
                final classId = dto.classId.trim();

                final callQuery =
                    "CALL sp_book_slot_if_available('$classId', '$moduleId', '$classModuleId', '$sqlDate', $slotNum, $onlineVal, @success)";

                await txn.query(callQuery);

                final res = await txn.query("SELECT @success as success");
                final val = res.rows.first['success'];
                final bool booked = (val == 1 || val == '1' || val == true);

                if (booked) {
                  hoursRemaining -= 1.0;
                  await txn.query(
                    "UPDATE classes_modules SET current_duration = current_duration + 1 WHERE classes_modules_id = ?",
                    whereValues: [classModuleId],
                  );
                }
              }
            }

            if (hoursRemaining > 0)
              currentDateCursor = currentDateCursor.add(Duration(days: 1));
          }
        }
      });

      return Result.success(true);
    } catch (e) {
      return Result.failure(
        AppError(AppErrorType.internal, "Erro ao gerar horário: $e"),
      );
    }
  }
}
