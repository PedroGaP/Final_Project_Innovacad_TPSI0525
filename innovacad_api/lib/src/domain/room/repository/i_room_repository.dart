import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';

abstract class IRoomRepository {
  Future<Result<List<OutputRoomDao>>> getAll();
  Future<Result<OutputRoomDao>> getById(int id); // Changed to int based on entity
  Future<Result<OutputRoomDao>> create(CreateRoomDto dto);
  Future<Result<OutputRoomDao>> update(UpdateRoomDto dto);
  Future<Result<OutputRoomDao>> delete(DeleteRoomDto dto);
}
