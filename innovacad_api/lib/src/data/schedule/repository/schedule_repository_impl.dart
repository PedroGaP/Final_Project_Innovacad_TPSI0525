import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/schedule/repository/i_schedule_repository.dart';
import 'package:mysql_utils/mysql_utils.dart';
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
      a.date_day, 
      rs.start_time, 
      rs.end_time, 
      IF(s.is_online, 'online', r.room_name) AS room_name,
      s.class_module_id, s.trainer_id, s.room_id, s.is_online, s.regime_type, s.total_hours
      FROM schedules s
      JOIN classes_modules classm ON s.class_module_id = classm.classes_modules_id
      JOIN courses_modules coursem ON classm.courses_modules_id = coursem.courses_modules_id
      JOIN modules m ON coursem.module_id = m.module_id
      JOIN trainers t ON s.trainer_id = t.trainer_id
      JOIN user u ON t.user_id = u.id
      JOIN schedule_slots ss ON s.schedule_id = ss.schedule_id
      JOIN availabilities a ON ss.availability_id = a.availability_id
      JOIN ref_slots rs ON a.slot_number = rs.slot_number
      LEFT JOIN rooms r ON s.room_id = r.room_id""";

  @override
  Future<Result<List<OutputScheduleDao>>> getAll() async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();

      final results = await db.query(scheduleQuerySql);

      final items = results.rowsAssoc
          .toList()
          .map((data) => OutputScheduleDao.fromJson(data.assoc()))
          .toList();

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
  Future<Result<OutputScheduleDao>> getById(String id) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();

      final result = await db.query(
        "$scheduleQuerySql WHERE s.schedule_id = ?",
        isStmt: true,
        whereValues: [id],
      );

      if (result.numOfRows <= 0)
        return Result.failure(
          AppError(AppErrorType.notFound, "Schedule not found"),
        );

      return Result.success(
        OutputScheduleDao.fromJson(
          result.rowsAssoc.first.assoc() as Map<String, dynamic>,
        ),
      );
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Error fetching schedule",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputScheduleDao>> create(CreateScheduleDto dto) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      await db.startTrans();

      await db.insert(
        table: schedulesTable,
        insertData: {
          "class_module_id": dto.classModuleId,
          "trainer_id": dto.trainerId,
          "room_id": dto.roomId,
          "is_online": dto.isOnline,
          "regime_type": dto.regimeType,
          "total_hours": dto.totalHours,
        },
      );

      final existingSchedule =
          await db.getOne(
                table: schedulesTable,
                order: "created_at desc",
                where: {
                  "class_module_id": dto.classModuleId,
                  "trainer_id": dto.trainerId,
                  "room_id": dto.roomId,
                  "is_online": dto.isOnline,
                  "regime_type": dto.regimeType,
                  "total_hours": dto.totalHours,
                },
              )
              as Map<String, dynamic>;

      if (existingSchedule.isEmpty)
        throw Exception("Schedule insertion failed");

      final scheduleId = existingSchedule["schedule_id"];

      await db.insert(
        table: schedulesSlotsTable,
        insertData: {
          "schedule_id": scheduleId,
          "availability_id": dto.availabilityId,
        },
      );

      await db.update(
        table: "availabilities",
        updateData: {"is_booked": 1},
        where: {"availability_id": dto.availabilityId},
      );

      final res = await db.query(
        "$scheduleQuerySql WHERE s.schedule_id = ?",
        isStmt: true,
        whereValues: [scheduleId],
      );

      final schedule = OutputScheduleDao.fromJson(
        res.rowsAssoc.first.assoc() as Map<String, dynamic>,
      );

      await db.commit();
      return Result.success(schedule);
    } catch (e, s) {
      await db?.rollback();

      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Failed to create schedule",
          details: {"error": e.toString(), "stackTrace": s},
        ),
      );
    }
  }

  @override
  Future<Result<OutputScheduleDao>> update(
    String id,
    UpdateScheduleDto dto,
  ) async {
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.connect();
      await db.startTrans();

      final existingResult =
          await db.getOne(table: schedulesTable, where: {"schedule_id": id})
              as Map<String, dynamic>;

      final existing = OutputSimpleScheduleDao.fromJson(existingResult);

      print(existing.toJson());

      final updateData = <String, dynamic>{};

      void addIfChanged(String key, dynamic newValue, dynamic oldValue) {
        if (newValue != null && newValue != oldValue) 
          updateData[key] = newValue;
        print("Key: $key | newValue: $newValue | oldValue: $oldValue");
      }

      addIfChanged("class_module_id", dto.classModuleId, existing.classModuleId);
      addIfChanged("trainer_id", dto.trainerId, existing.trainerId);
      addIfChanged("room_id", dto.roomId, existing.roomId);
      addIfChanged("is_online", dto.isOnline, existing.isOnline);
      addIfChanged("total_hours", dto.totalHours, existing.totalHours);

      print(updateData.toString());

      if (updateData.isEmpty) {
        await db.commit();
        return await getById(id);
      }

      final rowsAffected = await db.update(
        table: schedulesTable,
        updateData: updateData,
        where: {"schedule_id": id},
      );

      if (rowsAffected == 0) {
        throw Exception("No rows were updated. Record may have been deleted.");
      }

      await db.commit();
      return await getById(id);
    } catch (e, s) {
      await db?.rollback();
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while updating the schedule...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputScheduleDao>> delete(String id) async {
    MysqlUtils? db;

    try {
      final existingResult = await getById(id);
      if (existingResult.isFailure) return existingResult;

      db = await MysqlConfiguration.connect();
      await db.startTrans();

      final slotRecord = await db.getOne(
        table: schedulesSlotsTable,
        where: {"schedule_id": id},
      );

      if (slotRecord.isNotEmpty) {
        final availabilityId = slotRecord["availability_id"];

        await db.update(
          table: "availabilities",
          updateData: {"is_booked": 0},
          where: {"availability_id": availabilityId},
        );
      }

      await db.delete(table: schedulesTable, where: {"schedule_id": id});

      await db.commit();
      return existingResult;
    } catch (e, s) {
      await db?.rollback();

      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Delete failed",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }
}
