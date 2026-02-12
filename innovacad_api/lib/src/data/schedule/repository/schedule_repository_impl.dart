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
      t.trainer_id as trainer_id,
      u.email as trainer_email,
      s.start_date_timestamp,
      s.end_date_timestamp,
      IF(s.is_online, 'online', r.room_name) AS room_name,
      s.class_module_id, s.trainer_id, s.room_id, s.is_online, s.regime_type, s.total_hours,
      CONCAT(co.identifier, ' ', c.location, ' ', c.identifier) AS class_name,
      classm.current_duration AS current_duration,
      m.duration AS total_duration
      FROM schedules s
      JOIN classes_modules classm ON s.class_module_id = classm.classes_modules_id
      JOIN courses_modules coursem ON classm.courses_modules_id = coursem.courses_modules_id
      JOIN modules m ON coursem.module_id = m.module_id
      JOIN trainers t ON s.trainer_id = t.trainer_id
      JOIN user u ON t.user_id = u.id
      JOIN classes c ON classm.class_id = c.class_id
      JOIN courses co ON c.course_id = co.course_id
      LEFT JOIN rooms r ON s.room_id = r.room_id""";

  String _toSqlDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return "$y-$m-$d $h:$min:$s";
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
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final results = await db.query(scheduleQuerySql);

        final items = results.rowsAssoc.map((data) {
          return _mapRowToDao(data.assoc());
        }).toList();

        return Result.success(items);
      });
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
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
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
      });
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
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final result = await db.query(
          "$scheduleQuerySql WHERE s.schedule_id = ?",
          isStmt: true,
          whereValues: [scheduleId],
        );
        if (result.numOfRows < 1)
          return Result.failure(
            AppError(
              AppErrorType.notFound,
              "Schedule with id '$scheduleId' not found",
            ),
          );
        return Result.success(_mapRowToDao(result.rowsAssoc.first.assoc()));
      });
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputScheduleDao>> create(CreateScheduleDto dto) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.getConnection();

      if (dto.startTime.isAfter(dto.endTime) ||
          dto.startTime.isAtSameMomentAs(dto.endTime)) {
        return Result.failure(
          AppError(
            AppErrorType.badRequest,
            "End time must be after start time.",
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
              "Module started by another trainer. Use override.",
            ),
          );
        }
      }

      final conflictTrainer = await db.query(
        """SELECT schedule_id FROM schedules WHERE trainer_id = ? AND (
            (start_date_timestamp < ? AND end_date_timestamp > ?) OR 
            (start_date_timestamp < ? AND end_date_timestamp > ?) OR 
            (start_date_timestamp >= ? AND end_date_timestamp <= ?)
        ) LIMIT 1""",
        whereValues: [
          dto.trainerId,
          _toSqlDate(dto.endTime),
          _toSqlDate(dto.startTime),
          _toSqlDate(dto.endTime),
          _toSqlDate(dto.startTime),
          _toSqlDate(dto.startTime),
          _toSqlDate(dto.endTime),
        ],
        isStmt: true,
      );
      if (conflictTrainer.numOfRows > 0)
        return Result.failure(
          AppError(AppErrorType.conflict, "Trainer has a conflict."),
        );

      final classInfo = await db.getOne(
        table: 'classes_modules',
        where: {'classes_modules_id': dto.classModuleId},
      );
      final classId = classInfo['class_id'];

      final conflictClass = await db.query(
        """SELECT s.schedule_id FROM schedules s JOIN classes_modules cm ON s.class_module_id = cm.classes_modules_id
        WHERE cm.class_id = ? AND (
            (s.start_date_timestamp < ? AND s.end_date_timestamp > ?) OR
            (s.start_date_timestamp < ? AND s.end_date_timestamp > ?) OR
            (s.start_date_timestamp >= ? AND s.end_date_timestamp <= ?)
        ) LIMIT 1""",
        whereValues: [
          classId,
          _toSqlDate(dto.endTime),
          _toSqlDate(dto.startTime),
          _toSqlDate(dto.endTime),
          _toSqlDate(dto.startTime),
          _toSqlDate(dto.startTime),
          _toSqlDate(dto.endTime),
        ],
        isStmt: true,
      );
      if (conflictClass.numOfRows > 0)
        return Result.failure(
          AppError(AppErrorType.conflict, "Class has a conflict."),
        );

      final availabilitySql = """
        SELECT rs.start_time, rs.end_time, a.availability_id, a.is_booked
        FROM availabilities a JOIN ref_slots rs ON a.slot_number = rs.slot_number
        WHERE a.trainer_id = ? AND DATE(a.date_day) = DATE(?) ORDER BY rs.start_time ASC
      """;
      final availResults = await db.query(
        availabilitySql,
        whereValues: [dto.trainerId, dto.startTime],
        isStmt: true,
      );

      if (availResults.numOfRows < 1)
        return Result.failure(
          AppError(AppErrorType.conflict, "No availability found."),
        );

      List<String> availabilitiesToBook = [];
      for (var row in availResults.rowsAssoc) {
        final data = row.assoc();
        final isBooked = (data['is_booked'] == 1 || data['is_booked'] == true);
        final sStart = _combineDateAndTime(dto.startTime, data['start_time']);
        final sEnd = _combineDateAndTime(dto.startTime, data['end_time']);

        if (sStart.isBefore(dto.endTime) && sEnd.isAfter(dto.startTime)) {
          if (isBooked) continue;
          availabilitiesToBook.add(data['availability_id'].toString());
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
          AppError(AppErrorType.conflict, "Trainer unavailable or booked."),
        );
      }

      final scheduleId = Uuid().v4();
      final duration = dto.endTime.difference(dto.startTime).inMinutes / 60.0;

      availabilitiesToBook.sort();

      await db.transaction((txn) async {
        await txn.query(
          """INSERT INTO schedules (schedule_id, class_module_id, trainer_id, room_id, start_date_timestamp, end_date_timestamp, total_hours, regime_type, is_online)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)""",
          whereValues: [
            scheduleId,
            dto.classModuleId,
            dto.trainerId,
            dto.roomId,
            _toSqlDate(dto.startTime),
            _toSqlDate(dto.endTime),
            duration,
            0,
            0,
          ],
          isStmt: true,
        );

        await txn.query(
          "UPDATE classes_modules SET current_duration = current_duration + ? WHERE classes_modules_id = ?",
          whereValues: [duration, dto.classModuleId],
          isStmt: true,
        );

        if (availabilitiesToBook.isNotEmpty) {
          final slotsValues = <String>[];
          for (final availId in availabilitiesToBook) {
            final slotId = Uuid().v4();
            slotsValues.add("('$slotId', '$scheduleId', '$availId', 1)");
          }

          await txn.query(
            "INSERT INTO schedule_slots (slot_id, schedule_id, availability_id, slot_status) VALUES ${slotsValues.join(',')}",
          );

          final idsList = availabilitiesToBook.map((id) => "'$id'").join(',');
          await txn.query(
            "UPDATE availabilities SET is_booked = 1 WHERE availability_id IN ($idsList)",
          );
        }
      });

      return await _getSingleScheduleById(scheduleId);
    } catch (e, s) {
      print("CRITICAL DB ERROR: $e");
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
      print(dto.toJson());

      db = await MysqlConfiguration.getConnection();
      await db.query("SET SESSION innodb_lock_wait_timeout = 10");

      final rawCurrent = await db.query(
        "SELECT schedule_id, trainer_id, class_module_id, "
        "start_date_timestamp, end_date_timestamp "
        "FROM schedules WHERE schedule_id = ? FOR UPDATE",
        whereValues: [id],
        isStmt: true,
      );

      if (rawCurrent.numOfRows == 0) {
        return Result.failure(
          AppError(AppErrorType.notFound, "Schedule not found"),
        );
      }

      final current = rawCurrent.rowsAssoc.first.assoc();
      final String oldTrainerId = current['trainer_id'];
      final DateTime oldStartTime = DateTime.parse(
        current['start_date_timestamp'].toString(),
      );
      final DateTime oldEndTime = DateTime.parse(
        current['end_date_timestamp'].toString(),
      );

      final bool isTrainerChanged =
          dto.trainerId != null && dto.trainerId != oldTrainerId;
      final bool isTimeChanged =
          dto.startTime != null &&
          dto.endTime != null &&
          (dto.startTime != oldStartTime || dto.endTime != oldEndTime);

      final updateData = <String, dynamic>{};
      if (dto.roomId != null) updateData['room_id'] = dto.roomId;
      if (dto.isOnline != null) updateData['is_online'] = dto.isOnline! ? 1 : 0;
      if (dto.regimeType != null) updateData['regime_type'] = dto.regimeType;

      final targetTrainerId = dto.trainerId ?? oldTrainerId;
      final targetStart = dto.startTime ?? oldStartTime;
      final targetEnd = dto.endTime ?? oldEndTime;

      if (!isTrainerChanged && !isTimeChanged) {
        if (updateData.isEmpty) {
          return await _getSingleScheduleById(id);
        }

        await db.update(
          table: schedulesTable,
          updateData: updateData,
          where: {'schedule_id': id},
        );

        return await _getSingleScheduleById(id);
      }

      List<String> newAvailabilityIds = [];

      await db.transaction((txn) async {
        final oldSlotsResult = await txn.query(
          "SELECT availability_id FROM schedule_slots "
          "WHERE schedule_id = ? ORDER BY availability_id FOR UPDATE",
          whereValues: [id],
          isStmt: true,
        );

        List<String> oldAvailabilityIds = [];
        for (var row in oldSlotsResult.rows) {
          oldAvailabilityIds.add(row['availability_id'].toString());
        }

        final availSql = """
        SELECT a.availability_id, a.is_booked, rs.start_time, rs.end_time
        FROM availabilities a
        JOIN ref_slots rs ON a.slot_number = rs.slot_number
        WHERE a.trainer_id = ? 
          AND DATE(a.date_day) = DATE(?)
        ORDER BY a.availability_id ASC
        FOR UPDATE SKIP LOCKED
      """;

        final availResult = await txn.query(
          availSql,
          whereValues: [targetTrainerId, targetStart],
          isStmt: true,
        );

        for (var row in availResult.rowsAssoc) {
          final data = row.assoc();
          final sStart = _combineDateAndTime(targetStart, data['start_time']);
          final sEnd = _combineDateAndTime(targetStart, data['end_time']);
          final isBooked =
              (data['is_booked'] == 1 || data['is_booked'] == true);
          final availId = data['availability_id'].toString();

          if (sStart.isBefore(targetEnd) && sEnd.isAfter(targetStart)) {
            if (!isBooked || oldAvailabilityIds.contains(availId)) {
              newAvailabilityIds.add(availId);
            }
          }
        }

        if (newAvailabilityIds.isEmpty) {
          throw AppError(AppErrorType.conflict, "Não há slots disponíveis.");
        }

        final idsToFree = oldAvailabilityIds
            .where((id) => !newAvailabilityIds.contains(id))
            .toList();

        final idsToBook = newAvailabilityIds
            .where((id) => !oldAvailabilityIds.contains(id))
            .toList();

        await txn.query(
          "DELETE FROM schedule_slots WHERE schedule_id = ?",
          whereValues: [id],
          isStmt: true,
        );

        if (idsToFree.isNotEmpty) {
          final placeholders = idsToFree.map((_) => '?').join(',');
          await txn.query(
            "UPDATE availabilities SET is_booked = 0 "
            "WHERE availability_id IN ($placeholders)",
            whereValues: idsToFree,
            isStmt: true,
          );
        }

        if (idsToBook.isNotEmpty) {
          final placeholders = idsToBook.map((_) => '?').join(',');

          final recheckResult = await txn.query(
            "SELECT availability_id FROM availabilities "
            "WHERE availability_id IN ($placeholders) "
            "AND is_booked = 0 "
            "FOR UPDATE",
            whereValues: idsToBook,
            isStmt: true,
          );

          final foundIds = recheckResult.rows
              .map((r) => r['availability_id'].toString())
              .toSet();

          final missingIds = idsToBook
              .where((id) => !foundIds.contains(id))
              .toList();

          if (missingIds.isNotEmpty) {
            throw AppError(
              AppErrorType.conflict,
              "Slots ${missingIds.join(', ')} já foram reservados por outro agendamento.",
            );
          }

          await txn.query(
            "UPDATE availabilities SET is_booked = 1 "
            "WHERE availability_id IN ($placeholders)",
            whereValues: idsToBook,
            isStmt: true,
          );
        }

        if (newAvailabilityIds.isNotEmpty) {
          final values = newAvailabilityIds
              .map((availId) {
                final slotId = Uuid().v4();
                return "('$slotId', '$id', '$availId', 1)";
              })
              .join(',');

          await txn.query(
            "INSERT INTO schedule_slots "
            "(slot_id, schedule_id, availability_id, slot_status) "
            "VALUES $values",
          );
        }

        if (isTrainerChanged) updateData['trainer_id'] = targetTrainerId;
        if (isTimeChanged) {
          updateData['start_date_timestamp'] = _toSqlDate(targetStart);
          updateData['end_date_timestamp'] = _toSqlDate(targetEnd);
          updateData['total_hours'] =
              targetEnd.difference(targetStart).inMinutes / 60.0;
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
      print("Update Error: $e\n$s");
      if (e is AppError) return Result.failure(e);
      return Result.failure(
        AppError(AppErrorType.internal, "Update failed: $e"),
      );
    }
  }

  @override
  Future<Result<List<OutputScheduleDao>>> getByUser(String userId) async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final String fullQuery = """
          SELECT 
            s.schedule_id, 
            IF(s.regime_type = 0, 'daytime', 'post-work') AS regime_type, 
            m.name AS module_name, 
            u.name AS trainer_name, 
            t.trainer_id as trainer_id,
            u.email as trainer_email,
            s.start_date_timestamp,
            s.end_date_timestamp,
            IF(s.is_online, 'online', r.room_name) AS room_name,
            s.class_module_id, s.trainer_id, s.room_id, s.is_online, s.regime_type, s.total_hours,
            CONCAT(co.identifier, ' ', c.location, ' ', c.identifier) AS class_name,
            classm.current_duration AS current_duration,
            m.duration AS total_duration
          FROM schedules s
          JOIN classes_modules classm ON s.class_module_id = classm.classes_modules_id
          JOIN courses_modules coursem ON classm.courses_modules_id = coursem.courses_modules_id
          JOIN modules m ON coursem.module_id = m.module_id
          JOIN trainers t ON s.trainer_id = t.trainer_id
          JOIN user u ON t.user_id = u.id
          JOIN classes c ON classm.class_id = c.class_id
          JOIN courses co ON c.course_id = co.course_id
          LEFT JOIN rooms r ON s.room_id = r.room_id
          WHERE 
            -- CONDIÇÃO A: O utilizador logado é o formador desta aula
            t.user_id = ? 
            OR 
            -- CONDIÇÃO B: O utilizador logado está inscrito nesta turma como aluno
            classm.class_id IN (
              SELECT e.class_id 
              FROM enrollments e 
              JOIN trainees tr ON e.trainee_id = tr.trainee_id 
              WHERE tr.user_id = ?
            )
          ORDER BY s.start_date_timestamp ASC
        """;

        final result = await db.query(
          fullQuery,
          isStmt: true,
          whereValues: [userId, userId],
          debug: true,
        );

        if (result.numOfRows <= 0) {
          return Result.success([]);
        }

        final list = result.rowsAssoc
            .map((row) => _mapRowToDao(row.assoc()))
            .toList();

        return Result.success(list);
      });
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

      db = await MysqlConfiguration.getConnection();

      final rawData = await db.getOne(
        table: schedulesTable,
        where: {'schedule_id': id},
      );
      final classModuleId = rawData['class_module_id'];
      final double hoursToRemove =
          double.tryParse(rawData['total_hours'].toString()) ?? 0.0;

      final slots = await db.query(
        "SELECT availability_id FROM schedule_slots WHERE schedule_id = ?",
        whereValues: [id],
        isStmt: true,
      );
      List<String> availIdsToFree = [];
      for (var row in slots.rows) {
        availIdsToFree.add("'${row['availability_id']}'");
      }

      await db.transaction((txn) async {
        if (availIdsToFree.isNotEmpty) {
          await txn.query(
            "UPDATE availabilities SET is_booked = 0 WHERE availability_id IN (${availIdsToFree.join(',')})",
          );
        }

        await txn.delete(table: schedulesTable, where: {"schedule_id": id});

        await txn.query(
          "UPDATE classes_modules SET current_duration = current_duration - ? WHERE classes_modules_id = ?",
          whereValues: [hoursToRemove, classModuleId],
          isStmt: true,
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
      className: row['class_name'].toString(),
      currentDuration:
          double.tryParse(row['current_duration'].toString()) ?? 0.0,
      totalDuration: double.tryParse(row['total_duration'].toString()) ?? 0.0,
      scheduleId: row['schedule_id'].toString(),
      moduleName: row['module_name'].toString(),
      trainerName: row['trainer_name'].toString(),
      trainerEmail: row['trainer_email'].toString(),
      trainerId: row['trainer_id'].toString(),
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

      print("🚀 [AutoSchedule] Iniciando...");

      String timeCondition = dto.regimeType == 0
          ? "start_time >= '08:00:00' AND start_time <= '14:00:00' AND start_time != '11:00:00'"
          : "start_time >= '16:00:00' AND start_time < '23:00:00' AND start_time != '19:00:00'";

      final slotsResult = await db.query(
        "SELECT slot_number FROM ref_slots WHERE $timeCondition ORDER BY start_time ASC",
      );

      if (slotsResult.numOfRows == 0)
        return Result.failure(AppError(AppErrorType.badRequest, "Sem slots."));

      final List<int> allowedSlots = slotsResult.rows
          .map((r) => int.parse(r['slot_number'].toString()))
          .toList();

      final modulesQuery = """

        SELECT 

            cm.classes_modules_id, 

            cm.current_duration,

            m.module_id, 

            m.name, 

            m.duration,

            crm.sequence_course_module_id,

            (SELECT cm_prev.classes_modules_id 

             FROM classes_modules cm_prev 

             WHERE cm_prev.class_id = cm.class_id 

             AND cm_prev.courses_modules_id = crm.sequence_course_module_id) as dependency_id

        FROM classes_modules cm

        JOIN courses_modules crm ON cm.courses_modules_id = crm.courses_modules_id

        JOIN modules m ON crm.module_id = m.module_id

        WHERE cm.class_id = ?

        ORDER BY crm.sequence_course_module_id ASC

      """;

      final allModulesResult = await db.query(
        modulesQuery,

        whereValues: [dto.classId],

        isStmt: true,
      );

      List<Map<String, dynamic>> modulesList = [];

      for (var row in allModulesResult.rowsAssoc) {
        modulesList.add(Map<String, dynamic>.from(row.assoc()));
      }

      Map<String, DateTime> completionDates = {};

      DateTime globalStartDate = dto.startDate;

      bool madeProgress = true;

      while (modulesList.any((m) => _getHoursRemaining(m) > 0) &&
          madeProgress) {
        madeProgress = false;

        for (var mod in modulesList) {
          double hoursRemaining = _getHoursRemaining(mod);

          String classModId = mod['classes_modules_id'].toString();

          if (hoursRemaining <= 0) {
            if (!completionDates.containsKey(classModId)) {
              completionDates[classModId] = globalStartDate;
            }

            continue;
          }

          String? depId = mod['dependency_id']?.toString();

          DateTime startDateForThisModule = globalStartDate;

          if (depId != null && depId != 'null' && depId.isNotEmpty) {
            if (!completionDates.containsKey(depId)) {
              continue;
            }

            startDateForThisModule = completionDates[depId]!.add(
              Duration(days: 1),
            );
          }

          print(
            "📅 Agendando '${mod['name']}' a partir de ${_toSqlDate(startDateForThisModule)}",
          );

          await db.startTrans();

          try {
            String? lastScheduleId;

            int lastSlotNumber = -999;

            DateTime? lastDate;

            DateTime moduleDateCursor = startDateForThisModule;

            final DateTime safetyLimit = moduleDateCursor.add(
              Duration(days: 120),
            );

            while (hoursRemaining > 0) {
              if (moduleDateCursor.isAfter(safetyLimit)) break;

              if (moduleDateCursor.weekday != DateTime.sunday) {
                for (int slotNum in allowedSlots) {
                  if (hoursRemaining <= 0) break;

                  final sqlDate = _toSqlDate(moduleDateCursor);

                  String paramExtendId = "NULL";

                  if (lastScheduleId != null &&
                      _isSameDay(lastDate, moduleDateCursor) &&
                      slotNum == lastSlotNumber + 1) {
                    paramExtendId = "'$lastScheduleId'";
                  } else {
                    lastScheduleId = null;

                    paramExtendId = "NULL";
                  }

                  final callQuery =
                      "CALL sp_book_slot_if_available('${dto.classId}', '${mod['module_id']}', '$classModId', '$sqlDate', $slotNum, ${dto.isOnline ? 1 : 0}, $paramExtendId, @success, @new_schedule_id)";

                  await db.query(callQuery);

                  final res = await db.query(
                    "SELECT @success as success, @new_schedule_id as sched_id",
                  );

                  final bool booked = (res.rows.first['success'] == 1);

                  final String? returnedId = res.rows.first['sched_id']
                      ?.toString();

                  if (booked) {
                    hoursRemaining -= 1.0;

                    lastScheduleId = returnedId;

                    lastSlotNumber = slotNum;

                    lastDate = moduleDateCursor;

                    await db.query(
                      "UPDATE classes_modules SET current_duration = current_duration + 1 WHERE classes_modules_id = ?",

                      whereValues: [classModId],

                      isStmt: true,
                    );
                  } else {
                    lastScheduleId = null;
                  }
                }
              }

              if (hoursRemaining > 0) {
                moduleDateCursor = moduleDateCursor.add(Duration(days: 1));

                lastScheduleId = null;

                lastSlotNumber = -999;
              }
            }

            await db.commit();

            mod['current_duration'] = double.parse(mod['duration'].toString());

            completionDates[classModId] = moduleDateCursor;

            madeProgress = true;
          } catch (e) {
            print("Erro no módulo ${mod['name']}: $e");

            await db.rollback();
          }
        }
      }

      print("✅ Geração concluída.");

      return Result.success(true);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, "Erro: $e"));
    }
  }

  double _getHoursRemaining(Map<String, dynamic> mod) {
    double total = double.tryParse(mod['duration'].toString()) ?? 0.0;
    double current = double.tryParse(mod['current_duration'].toString()) ?? 0.0;
    return total - current;
  }

  bool _isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
