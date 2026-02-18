import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/data/room/dao/output/output_public_room_dao.dart';
import 'package:innovacad_api/src/data/room/dao/output/output_room_busy_dao.dart';

abstract class IRoomService {
  Future<Result<List<OutputRoomDao>>> getAll();
  Future<Result<List<OutputPublicRoomDao>>> getAllPublic();
  Future<Result<OutputRoomDao>> getById(String id);
  Future<Result<OutputRoomDao>> create(CreateRoomDto dto);
  Future<Result<OutputRoomDao>> update(String id, UpdateRoomDto dto);
  Future<Result<OutputRoomDao>> delete(String dto);
  Future<Result<List<OutputRoomBusyDao>>> checkAvailability(
    String roomId,
    String date,
  );
}
