import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:vaden/vaden.dart';

@Repository()
class RoomRepositoryImpl implements IRoomRepository {
  final String table = "rooms";

  @override
  Future<Result<List<OutputRoomDao>>> getAll() async {
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.connect();

      final results = await db.getAll(table: table);

      final rooms = results.map((data) {
        return OutputRoomDao.fromJson(data);
      }).toList();

      return Result.success(rooms);
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
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.connect();

      final result =
          await db.getOne(table: table, where: {"room_id": id})
              as Map<String, dynamic>;

      if (result.isEmpty)
        return Result.failure(
          AppError(AppErrorType.notFound, "Room not found..."),
        );

      return Result.success(OutputRoomDao.fromJson(result));
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
      db = await MysqlConfiguration.connect();

      await db.insert(
        table: table,
        insertData: {"room_name": dto.roomName, "capacity": dto.capacity},
      );

      final created =
          await db.getOne(table: table, where: {"room_name": dto.roomName})
              as Map<String, dynamic>;

      if (created.isEmpty)
        return Result.failure(
          AppError(
            AppErrorType.internal,
            "Created room could not be retrieved...",
          ),
        );

      return Result.success(OutputRoomDao.fromJson(created));
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while creating the room...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputRoomDao>> update(String id, UpdateRoomDto dto) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();

      final existingRoom = await getById(id);

      if (existingRoom.isFailure || existingRoom.data == null)
        return existingRoom;

      final updateData = <String, dynamic>{};

      if (dto.roomName != null && existingRoom.data!.roomName != dto.roomName)
        updateData["room_name"] = dto.roomName;

      if (dto.capacity != null && existingRoom.data!.capacity != dto.capacity)
        updateData["capacity"] = dto.capacity;

      if (updateData.isEmpty) return existingRoom;

      await db.update(
        table: table,
        updateData: updateData,
        where: {"room_id": id},
      );

      return await getById(id);
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
    MysqlUtils? db;

    try {
      final existingRoom = await getById(id);

      if (existingRoom.isFailure || existingRoom.data == null)
        return existingRoom;

      db = await MysqlConfiguration.connect();

      await db.delete(table: table, where: {"room_id": id});

      return existingRoom;
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
}
