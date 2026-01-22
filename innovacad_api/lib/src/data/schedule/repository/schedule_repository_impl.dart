import 'dart:math';

import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/schedule/repository/i_schedule_repository.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:vaden/vaden.dart';

@Repository()
class ScheduleRepositoryImpl implements IScheduleRepository {
  final String table = "schedules";

  @override
  Future<Result<List<OutputScheduleDao>>> getAll() async {
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.connect();

      final results = await db.getAll(table: table);

      final items = results.map((data) {
        return OutputScheduleDao.fromJson(data);
      }).toList();

      return Result.success(items);
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while fetching the schedules...",
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

      final result =
          await db.getOne(table: table, where: {"schedule_id": id})
              as Map<String, dynamic>;

      if (result.isEmpty)
        return Result.failure(
          AppError(AppErrorType.notFound, "Schedule not found"),
        );

      return Result.success(OutputScheduleDao.fromJson(result));
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while fetching the schedule...",
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
        table: table,
        insertData: {
          "class_module_id": dto.classModuleId,
          "trainer_id": dto.trainerId,
          "availability_id": dto.availabilityId,
          "room_id": dto.roomId,
          "online": dto.online,
          "start_date_timestamp": dto.startDateTimestamp.toIso8601String(),
          "end_date_timestamp": dto.endDateTimestamp.toIso8601String(),
        },
      );

      final created =
          await db.getOne(
                table: table,
                where: {
                  "class_module_id": dto.classModuleId,
                  "trainer_id": dto.trainerId,
                  "availability_id": dto.availabilityId,
                },
              )
              as Map<String, dynamic>;

      if (created.isEmpty)
        return Result.failure(
          AppError(
            AppErrorType.internal,
            "Created Schedule could not be retrieved",
          ),
        );

      return Result.success(OutputScheduleDao.fromJson(created));
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while creating the schedule...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
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

      final existingSchedule = await getById(id);

      if (existingSchedule.isFailure || existingSchedule.data == null)
        return existingSchedule;

      final updateData = <String, dynamic>{};

      if (dto.classModuleId != null &&
          dto.classModuleId != existingSchedule.data!.classModuleId)
        updateData["class_module_id"] = dto.classModuleId;

      if (dto.trainerId != null &&
          dto.trainerId != existingSchedule.data!.trainerId)
        updateData["trainer_id"] = dto.trainerId;

      if (dto.availabilityId != null &&
          dto.availabilityId != existingSchedule.data!.availabilityId)
        updateData["availability_id"] = dto.availabilityId;

      if (dto.roomId != null && dto.roomId != existingSchedule.data!.roomId)
        updateData["room_id"] = dto.roomId;

      if (dto.online != null && dto.online != existingSchedule.data!.online)
        updateData["online"] = dto.online;

      if (dto.startDateTimestamp != null &&
          dto.startDateTimestamp != existingSchedule.data!.startDateTimestamp)
        updateData["start_date_timestamp"] = dto.startDateTimestamp!
            .toIso8601String();

      if (dto.endDateTimestamp != null &&
          dto.endDateTimestamp != existingSchedule.data!.endDateTimestamp)
        updateData["end_date_timestamp"] = dto.endDateTimestamp!
            .toIso8601String();

      if (updateData.isEmpty) return existingSchedule;

      await db.update(
        table: table,
        updateData: updateData,
        where: {"schedule_id": id},
      );

      return await getById(id);
    } catch (e, s) {
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
      final existingSchedule = await getById(id);

      if (existingSchedule.isFailure || existingSchedule.data == null)
        return existingSchedule;

      db = await MysqlConfiguration.connect();

      await db.delete(table: table, where: {"schedule_id": id});

      return existingSchedule;
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while deleting the schedule...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }
}
