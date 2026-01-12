import 'package:innovacad_api/src/domain/dtos/room/room_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/room/room_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/room.dart';

abstract interface class IRoomRepository {
  Future<List<Room>?> getAll();
  Future<Room?> getById(String id);
  Future<Room?> create(RoomCreateDto dto);
  Future<Room?> update(RoomUpdateDto dto);
  Future<Room?> delete(String id);
}
