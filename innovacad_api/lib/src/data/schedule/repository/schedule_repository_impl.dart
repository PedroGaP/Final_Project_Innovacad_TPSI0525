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

      final items = results.map((row) {
        final onlineVal = row["online"];
        final bool online =
            onlineVal == 1 || onlineVal == true || onlineVal == '1';

        final roomIdVal = row["room_id"];
        int? roomId;
        if (roomIdVal != null) {
          roomId = roomIdVal is int
              ? roomIdVal
              : int.tryParse(roomIdVal.toString());
        }

        return OutputScheduleDao(
          scheduleId: row["id"].toString(),
          classModuleId: row["class_module_id"].toString(),
          trainerId: row["trainer_id"].toString(),
          availabilityId: row["availability_id"].toString(),
          roomId: roomId,
          online: online,
          startDateTimestamp: DateTime.parse(
            row["start_date_timestamp"].toString(),
          ),
          endDateTimestamp: DateTime.parse(
            row["end_date_timestamp"].toString(),
          ),
        );
      }).toList();

      return Result.success(items);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputScheduleDao>> getById(String id) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      final result = await db.getOne(table: table, where: {"id": id});

      if (result.isEmpty) {
        return Result.failure(
          AppError(AppErrorType.notFound, "Schedule not found"),
        );
      }

      final onlineVal = result["online"];
      final bool online =
          onlineVal == 1 || onlineVal == true || onlineVal == '1';

      final roomIdVal = result["room_id"];
      int? roomId;
      if (roomIdVal != null) {
        roomId = roomIdVal is int
            ? roomIdVal
            : int.tryParse(roomIdVal.toString());
      }

      final dao = OutputScheduleDao(
        scheduleId: result["id"].toString(),
        classModuleId: result["class_module_id"].toString(),
        trainerId: result["trainer_id"].toString(),
        availabilityId: result["availability_id"].toString(),
        roomId: roomId,
        online: online,
        startDateTimestamp: DateTime.parse(
          result["start_date_timestamp"].toString(),
        ),
        endDateTimestamp: DateTime.parse(
          result["end_date_timestamp"].toString(),
        ),
      );

      return Result.success(dao);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputScheduleDao>> create(CreateScheduleDto dto) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();

      await db.insert(
        table: table,
        insertData: {
          "class_module_id": dto.classModuleId,
          "trainer_id": dto.trainerId,
          "availability_id": dto.availabilityId,
          "room_id": dto.roomId,
          "online": dto.online ? 1 : 0,
          "start_date_timestamp": dto.startDateTimestamp.toIso8601String(),
          "end_date_timestamp": dto.endDateTimestamp.toIso8601String(),
        },
      );

      final Map<String, dynamic> where = {
        "class_module_id": dto.classModuleId,
        "trainer_id": dto.trainerId,
        "availability_id": dto.availabilityId,
      };

      final created = await db.getOne(table: table, where: where);

      if (created.isEmpty) {
        return Result.failure(
          AppError(
            AppErrorType.internal,
            "Created Schedule could not be retrieved",
          ),
        );
      }

      final onlineVal = created["online"];
      final bool online =
          onlineVal == 1 || onlineVal == true || onlineVal == '1';

      final roomIdVal = created["room_id"];
      int? roomId;
      if (roomIdVal != null) {
        roomId = roomIdVal is int
            ? roomIdVal
            : int.tryParse(roomIdVal.toString());
      }

      return Result.success(
        OutputScheduleDao(
          scheduleId: created["id"].toString(),
          classModuleId: created["class_module_id"].toString(),
          trainerId: created["trainer_id"].toString(),
          availabilityId: created["availability_id"].toString(),
          roomId: roomId,
          online: online,
          startDateTimestamp: DateTime.parse(
            created["start_date_timestamp"].toString(),
          ),
          endDateTimestamp: DateTime.parse(
            created["end_date_timestamp"].toString(),
          ),
        ),
      );
    } catch (e) {
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
      db = await MysqlConfiguration.connect();

      final updateData = <String, dynamic>{};
      if (dto.classModuleId != null)
        updateData["class_module_id"] = dto.classModuleId;
      if (dto.trainerId != null) updateData["trainer_id"] = dto.trainerId;
      if (dto.availabilityId != null)
        updateData["availability_id"] = dto.availabilityId;
      if (dto.roomId != null) updateData["room_id"] = dto.roomId;
      if (dto.online != null) updateData["online"] = dto.online! ? 1 : 0;
      if (dto.startDateTimestamp != null)
        updateData["start_date_timestamp"] = dto.startDateTimestamp!
            .toIso8601String();
      if (dto.endDateTimestamp != null)
        updateData["end_date_timestamp"] = dto.endDateTimestamp!
            .toIso8601String();

      if (updateData.isEmpty) {
        return getById(id);
      }

      await db.update(table: table, updateData: updateData, where: {"id": id});

      return getById(id);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputScheduleDao>> delete(String id) async {
    MysqlUtils? db;
    try {
      final existingRes = await getById(id);
      if (existingRes.isFailure) return existingRes;

      db = await MysqlConfiguration.connect();
      await db.delete(table: table, where: {"id": id});

      return existingRes;
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }
}
