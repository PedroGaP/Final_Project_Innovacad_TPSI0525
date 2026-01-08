import 'package:innovacad_api/src/domain/dtos/room/room_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/room/room_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/room.dart';
import 'package:innovacad_api/src/domain/repositories/room_repository.dart';
import 'package:vaden/vaden.dart';

@Repository()
class RoomRepositoryImpl implements IRoomRepository {
  @override
  Future<List<Room>?> getAll() {
    throw UnimplementedError();
  }

  @override
  Future<Room?> getById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Room?> create(RoomCreateDto dto) {
    throw UnimplementedError();
  }

  @override
  Future<Room?> update(RoomUpdateDto dto) {
    throw UnimplementedError();
  }

  @override
  Future<Room?> delete(String id) {
    throw UnimplementedError();
  }
}
