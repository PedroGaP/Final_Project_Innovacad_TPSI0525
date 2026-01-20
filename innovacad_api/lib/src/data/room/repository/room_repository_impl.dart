import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/room/repository/i_room_repository.dart';
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
      
      final rooms = results.map((row) {
         return OutputRoomDao(
            roomId: row["id"] is int ? row["id"] : int.parse(row["id"].toString()), 
            // Assuming 'id' is the column name. Handle potential type mismatch if driver returns string for int.
            roomName: row["room_name"],
            capacity: row["capacity"] is int ? row["capacity"] : int.parse(row["capacity"].toString())
         );
      }).toList();
      
      return Result.success(rooms);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputRoomDao>> getById(int id) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      final result = await db.getOne(table: table, where: {"id": id});
      
      if (result.isEmpty) {
         return Result.failure(AppError(AppErrorType.notFound, "Room not found"));
      }

      final dao = OutputRoomDao(
         roomId: result["id"] is int ? result["id"] : int.parse(result["id"].toString()),
         roomName: result["room_name"],
         capacity: result["capacity"] is int ? result["capacity"] : int.parse(result["capacity"].toString())
      );
      
      return Result.success(dao);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputRoomDao>> create(CreateRoomDto dto) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      
      await db.insert(
         table: table,
         insertData: {
            "room_name": dto.roomName,
            "capacity": dto.capacity
         }
      );
      
      // Retrieval strategy: Assuming room_name unique? 
      // Ideally retrieve by LAST_INSERT_ID logic, but MysqlUtils abstract it.
      // Trying to get by name.
      final created = await db.getOne(table: table, where: {"room_name": dto.roomName}); 
       
      if (created.isEmpty) {
          // Fallback if name not unique or failed
          return Result.failure(AppError(AppErrorType.internal, "Created room could not be retrieved"));
      }
      
      return Result.success(OutputRoomDao(
         roomId: created["id"] is int ? created["id"] : int.parse(created["id"].toString()), 
         roomName: created["room_name"], 
         capacity: created["capacity"] is int ? created["capacity"] : int.parse(created["capacity"].toString())
      ));
      
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputRoomDao>> update(UpdateRoomDto dto) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      
      final updateData = <String, dynamic>{};
      if (dto.roomName != null) updateData["room_name"] = dto.roomName;
      if (dto.capacity != null) updateData["capacity"] = dto.capacity;
      
      if (updateData.isEmpty) {
          return getById(dto.roomId);
      }
      
      await db.update(
         table: table,
         updateData: updateData,
         where: {"id": dto.roomId}
      );
      
      return getById(dto.roomId);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputRoomDao>> delete(DeleteRoomDto dto) async {
    MysqlUtils? db;
    try {
      final existingRes = await getById(dto.roomId);
      if (existingRes.isFailure) return existingRes;
      
      db = await MysqlConfiguration.connect();
      await db.delete(table: table, where: {"id": dto.roomId});
      
      return existingRes;
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }
}
