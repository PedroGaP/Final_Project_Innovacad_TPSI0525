import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/data/room/dao/output/output_room_busy_dao.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:vaden/vaden.dart';

@Repository()
class RoomRepositoryImpl implements IRoomRepository {
  final String table = "rooms";

  @override
  Future<Result<List<OutputRoomDao>>> getAll() async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final results = await db.getAll(table: table);

        final rooms = results.map((data) {
          return OutputRoomDao.fromJson(data);
        }).toList();

        return Result.success(rooms);
      });
    } catch (e, stackTrace) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while fetching the rooms...",
          details: {"error": e.toString(), "stackTrace": stackTrace.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputRoomDao>> getById(String id) async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final result =
            await db.getOne(table: table, where: {"room_id": id})
                as Map<String, dynamic>;

        if (result.isEmpty)
          return Result.failure(
            AppError(AppErrorType.notFound, "Room not found..."),
          );

        return Result.success(OutputRoomDao.fromJson(result));
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while fetching the room...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputRoomDao>> create(CreateRoomDto dto) async {
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.getConnection();

      await db.startTrans();

      await db.insert(
        table: table,
        insertData: {
          "room_name": dto.roomName,
          "capacity": dto.capacity,
          "has_computers": dto.hasComputers,
          "has_projector": dto.hasProjector,
          "has_whiteboard": dto.hasWhiteboard,
          "has_smartboard": dto.hasSmartboard,
        },
      );

      final created =
          await db.getOne(table: table, where: {"room_name": dto.roomName})
              as Map<String, dynamic>;

      await db.commit();

      if (created.isEmpty)
        return Result.failure(
          AppError(
            AppErrorType.internal,
            "Created room could not be retrieved...",
          ),
        );

      return Result.success(OutputRoomDao.fromJson(created));
    } catch (e, s) {
      if (db != null) await db.rollback();
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while creating the room...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    } finally {
      await MysqlConfiguration.closeConnection(db);
    }
  }

  @override
  Future<Result<OutputRoomDao>> update(String id, UpdateRoomDto dto) async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final existingRoom = await getById(id);

        if (existingRoom.isFailure || existingRoom.data == null)
          return existingRoom;

        final updateData = <String, dynamic>{};

        if (dto.roomName != null && existingRoom.data!.roomName != dto.roomName)
          updateData["room_name"] = dto.roomName;

        if (dto.capacity != null && existingRoom.data!.capacity != dto.capacity)
          updateData["capacity"] = dto.capacity;

        if (dto.hasComputers != null &&
            existingRoom.data!.hasComputers != dto.hasComputers)
          updateData["has_computers"] = dto.hasComputers;

        if (dto.hasProjector != null &&
            existingRoom.data!.hasProjector != dto.hasProjector)
          updateData["has_projector"] = dto.hasProjector;

        if (dto.hasWhiteboard != null &&
            existingRoom.data!.hasWhiteboard != dto.hasWhiteboard)
          updateData["has_whiteboard"] = dto.hasWhiteboard;

        if (dto.hasSmartboard != null &&
            existingRoom.data!.hasSmartboard != dto.hasSmartboard)
          updateData["has_smartboard"] = dto.hasSmartboard;

        if (updateData.isEmpty) return existingRoom;

        await db.update(
          table: table,
          updateData: updateData,
          where: {"room_id": id},
        );

        return await getById(id);
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while updating the room...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputRoomDao>> delete(String id) async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final existingRoom = await getById(id);

        if (existingRoom.isFailure || existingRoom.data == null)
          return existingRoom;

        await db.delete(table: table, where: {"room_id": id});

        return existingRoom;
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while deleting the room...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<List<OutputRoomBusyDao>>> checkAvailability(
    String roomId,
    DateTime date,
  ) async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final dateSql = date.toIso8601String().split('T')[0];

        final query = """
          SELECT
            s.room_id,
            s.schedule_id, 
            s.start_date_timestamp AS start_time,
            s.end_date_timestamp AS end_time,
            m.name AS module_name
          FROM schedules s
          LEFT JOIN classes_modules cm ON s.class_module_id = cm.classes_modules_id
          LEFT JOIN courses_modules crm ON cm.courses_modules_id = crm.courses_modules_id
          LEFT JOIN modules m ON crm.module_id = m.module_id
          WHERE s.room_id = ?
          AND (
            DATE(s.start_date_timestamp) = DATE(?)
            OR DATE(s.end_date_timestamp) = DATE(?)
          )
          ORDER BY s.start_date_timestamp
        """;

        final results = await db.query(
          query,
          whereValues: [roomId, dateSql, dateSql],
          isStmt: true,
        );

        final busySlots = results.rowsAssoc
            .map((row) => OutputRoomBusyDao.fromJson(row.assoc()))
            .toList();

        return Result.success(busySlots);
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Error checking room availability",
          details: {"error": e.toString(), "stack": s.toString()},
        ),
      );
    }
  }
}
