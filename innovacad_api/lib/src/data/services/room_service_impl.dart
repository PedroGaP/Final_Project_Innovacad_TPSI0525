import 'package:innovacad_api/src/data/repositories/room_repository_impl.dart';
import 'package:innovacad_api/src/domain/dtos/room/room_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/room/room_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/room.dart';
import 'package:innovacad_api/src/domain/services/room_service.dart';
import 'package:vaden/vaden.dart';

@Service()
class RoomServiceImpl implements IRoomService {
  final RoomRepositoryImpl _repository;

  RoomServiceImpl(this._repository);

  @override
  Future<List<Room>?> getAll() async {
    return await _repository.getAll();
  }

  @override
  Future<Room?> getById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<Room?> create(RoomCreateDto dto) async {
    return await _repository.create(dto);
  }

  @override
  Future<Room?> update(RoomUpdateDto dto) async {
    return await _repository.update(dto);
  }

  @override
  Future<Room?> delete(String id) async {
    return await _repository.delete(id);
  }
}
