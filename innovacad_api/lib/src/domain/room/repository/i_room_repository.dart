import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';

abstract class IRoomRepository {
  Future<Result<List<OutputRoomDao>>> getAll();
  Future<Result<OutputRoomDao>> getById(String id);
  Future<Result<OutputRoomDao>> create(CreateRoomDto dto);
  Future<Result<OutputRoomDao>> update(String id, UpdateRoomDto dto);
  Future<Result<OutputRoomDao>> delete(String id);
}
